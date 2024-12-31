
# Merge Results for Summaries -----------------------------------

# Comparing different automated methods with expert scores


## Load data -----------------------

all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))

# Averaged expert measurements from eu-policy-feedback/existing_measurements/nanou_2017/extract_expert_measurements.R
nanou_2017_mpolicy_lrscale3 <- readRDS(here("existing_measurements", "nanou_2017", "nanou_2017_mpolicy_lrscale3.rds"))

# Mapped subject matters with broad policy area
policy_area_moodley_subj_matter_mpolicy <- readRDS(here("data", "evaluation", "policy_area_moodley_subj_matter_mpolicy.rds")) # eu-policy-feedback/evaluation/policy_area_moodley_subj_matter_mpolicy.R

# Import Calculated measurements
glove_polarity_scores_preamble_econ <- readRDS(here("data", "lss", "glove_polarity_scores_preamble_econ.rds"))
glove_polarity_scores_preamble_social <- readRDS(here("data", "lss", "glove_polarity_scores_preamble_social.rds"))
hix_hoyland_data <- readRDS(here("existing_measurements", "hix_hoyland_2024", "hix_hoyland_data.rds"))
hix_hoyland_data <- hix_hoyland_data %>% distinct(CELEX, .keep_all = T) # Remove duplicate
llama_preamble_0_shot <- readRDS(here("data", "llm_0_shot", "llama_preamble_0_shot.rds"))
chatgpt_preamble_0_shot <- readRDS(here("data", "llm_0_shot", "chatgpt_preamble_0_shot.rds"))


## Add Subject Matter to all_dir_reg -----------------------

# Import and clean
moodley <- read.csv(here("data", "data_collection", "eu_regulations_metadata_1971_2022.csv"), stringsAsFactors = F)
moodley <- moodley %>% 
  select(celex, subject_matters) %>% 
  rename(subject_matter_moodley = subject_matters) %>%
  rename(CELEX = celex) %>% 
  mutate(subject_matter_moodley = gsub(" \\| ", "; ", subject_matter_moodley)) %>%
  mutate(subject_matter_moodley = tolower(subject_matter_moodley)) %>% 
  distinct(CELEX, .keep_all = T)

all_dir_reg <- all_dir_reg %>% left_join(moodley, by = "CELEX")


## Preprocess Data -----------------------

# Perform standardization of data (z-scoring)

nanou_2017_mpolicy_lrscale3 <- nanou_2017_mpolicy_lrscale3 %>% 
  mutate(lrscale3_avg_z_score = standardize(lrscale3_avg))

glove_polarity_scores_preamble_econ <- glove_polarity_scores_preamble_econ %>% 
  # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
  mutate(avg_glove_polarity_scores = avg_glove_polarity_scores * -1) %>% 
  mutate(avg_lss_econ_z_score = standardize(avg_glove_polarity_scores))

glove_polarity_scores_preamble_social <- glove_polarity_scores_preamble_social %>% 
  # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
  mutate(avg_glove_polarity_scores = avg_glove_polarity_scores * -1) %>% 
  mutate(avg_lss_social_z_score = standardize(avg_glove_polarity_scores))

hix_hoyland_data <- hix_hoyland_data %>% 
  mutate(RoBERT_left_right_z_score = standardize(RoBERT_left_right)) %>% 
  mutate(bakker_hobolt_econ_z_score = standardize(bakker_hobolt_econ)) %>% 
  mutate(bakker_hobolt_social_z_score = standardize(bakker_hobolt_social)) %>% 
  mutate(cmp_left_right_z_score = standardize(cmp_left_right))

llama_preamble_0_shot <- llama_preamble_0_shot %>%
  mutate(llama_preamble_0_shot_z_score = standardize(response))

chatgpt_preamble_0_shot <- chatgpt_preamble_0_shot %>%
  mutate(chatgpt_preamble_0_shot_z_score = standardize(GPT_Output))


## Connect a Law's Subject Matter with the Broad Policy Area from Nanou 2017 -----------------------

# Function to match subject matter terms to broad policy areas, accounting for match frequency
# Take string and check it against every keyword in lookup_df to see if there is a match

match_policy_area <- function(subject_matter, lookup_df) {
  # Initialize a named vector to store the count of matches per broad policy area
  match_count <- setNames(rep(0, length(unique(lookup_df$mpolicy))), 
                          unique(lookup_df$mpolicy))
  
  # Loop through each subject matter term in the lookup table
  for (i in seq_along(lookup_df$subject_matter)) {
    if (grepl(lookup_df$subject_matter[i], subject_matter, ignore.case = TRUE)) {
      # Increment the count for the corresponding broad policy area
      match_count[lookup_df$mpolicy[i]] <- match_count[lookup_df$mpolicy[i]] + 1
    }
  }
  
  # Filter out broad policy areas with no matches
  matched_areas <- match_count[match_count > 0]
  
  # Sort the matched areas by the number of matches in descending order
  matched_areas <- sort(matched_areas, decreasing = TRUE)
  
  # Return the matched broad policy areas in order of frequency
  if (length(matched_areas) == 0) {
    return(NA)  # Return NA if no match is found
  } else {
    return(paste(names(matched_areas), collapse = "; "))
  }
}

all_dir_reg$broad_policy_area_mpolicy_moodley <- sapply(all_dir_reg$subject_matter_moodley,
                                                        match_policy_area,
                                                        lookup_df = policy_area_moodley_subj_matter_mpolicy)


## Calculate Averages per Time Period and Broad Policy Area ---------------------------------

# Create a dataframe that allows us to calculate the average score per time period and broad policy area

# Preprocess data and add calculated scores
broad_policy_mpolicy_avg_df <- all_dir_reg %>% 
  select(CELEX, Date_document, broad_policy_area_mpolicy_moodley) %>% 
  mutate(year = as.numeric(format(Date_document, "%Y"))) %>% 
  select(-Date_document) %>% 
  drop_na(broad_policy_area_mpolicy_moodley) %>% 
  separate_rows(broad_policy_area_mpolicy_moodley, sep = "; ") %>% # Place each Broad Policy Area on its own row
  distinct(CELEX, broad_policy_area_mpolicy_moodley, .keep_all = T) %>% 
  # Add calculated scores
  left_join(select(glove_polarity_scores_preamble_econ, CELEX, avg_lss_econ_z_score), by = "CELEX") %>% 
  left_join(select(glove_polarity_scores_preamble_social, CELEX, avg_lss_social_z_score), by = "CELEX") %>% 
  left_join(select(hix_hoyland_data, CELEX, RoBERT_left_right_z_score, bakker_hobolt_econ_z_score, bakker_hobolt_social_z_score, cmp_left_right_z_score), by = "CELEX") %>% 
  left_join(select(llama_preamble_0_shot, CELEX, llama_preamble_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(chatgpt_preamble_0_shot, CELEX, chatgpt_preamble_0_shot_z_score), by = "CELEX")

# Save raw results to file for evaluation
saveRDS(broad_policy_mpolicy_avg_df, file = here("data", "evaluation", "broad_policy_mpolicy_avg_df_preamble_raw_results.rds"))

# Calcualate averages based on time periods
broad_policy_mpolicy_avg_df <- broad_policy_mpolicy_avg_df %>%
  mutate(period = case_when(
    year %in% 1989:1990 ~ "1989-1990",
    year %in% 1991:1995 ~ "1991-1995",
    year %in% 1996:2000 ~ "1996-2000",
    year %in% 2001:2005 ~ "2001-2005",
    year %in% 2006:2010 ~ "2006-2010",
    year %in% 2011:2014 ~ "2011-2014",
    year %in% 2014:2024 ~ "2014-2024",
    TRUE ~ NA_character_)) %>% 
  drop_na(period) %>%
  group_by(broad_policy_area_mpolicy_moodley, period) %>%
  summarize(across(contains("z_score"), ~ mean(.x, na.rm = TRUE)), .groups = "drop") %>% 
  ungroup()

# Add Nanou 2017
broad_policy_mpolicy_avg_df <- broad_policy_mpolicy_avg_df %>% 
  left_join(select(nanou_2017_mpolicy_lrscale3, broad_policy_area, period, lrscale3_avg_z_score), by = c("broad_policy_area_mpolicy_moodley" = "broad_policy_area", "period")) %>% 
  rename(nanou_2017_mpolicy_lrscale3 = lrscale3_avg_z_score)

# Save to file
saveRDS(broad_policy_mpolicy_avg_df, file = here("data", "evaluation", "broad_policy_mpolicy_avg_df_preamble.rds"))
