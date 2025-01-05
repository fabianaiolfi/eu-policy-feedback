
# Merge Results for Summaries -----------------------------------

# Comparing different automated methods with expert scores


## Load data -----------------------

all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))

# Averaged expert measurements from eu-policy-feedback/existing_measurements/nanou_2017/extract_expert_measurements.R
nanou_2017_mpolicy_lrscale3 <- readRDS(here("existing_measurements", "nanou_2017", "nanou_2017_mpolicy_lrscale3.rds"))

# Mapped subject matters with broad policy area
policy_area_moodley_subj_matter_mpolicy <- readRDS(here("data", "evaluation", "policy_area_moodley_subj_matter_mpolicy.rds")) # eu-policy-feedback/evaluation/policy_area_moodley_subj_matter_mpolicy.R

# Import Calculated measurements
glove_polarity_scores_summaries_econ <- readRDS(here("data", "lss", "glove_polarity_scores_summaries_econ.rds"))
glove_polarity_scores_summaries_social <- readRDS(here("data", "lss", "glove_polarity_scores_summaries_social.rds"))
hix_hoyland_data_summaries <- readRDS(here("existing_measurements", "hix_hoyland_2024", "hix_hoyland_data_summaries.rds"))
chatgpt_summary_0_shot <- readRDS(here("data", "llm_0_shot", "chatgpt_summary_0_shot.rds"))
chatgpt_ranking_combined <- readRDS(here("data", "llm_ranking", "chatgpt_combined_rating.rds"))
llama_summary_0_shot <- readRDS(here("data", "llm_0_shot", "llama_summary_0_shot.rds"))
llama_ranking_combined <- readRDS(here("data", "llm_ranking", "llama_combined_rating.rds"))
llama_ranking_combined_3_reps <- readRDS(here("data", "llm_ranking", "llama_combined_rating_3_reps.rds"))
deepseek_output_econ <- read.csv(here("data", "llm_0_shot", "deepseek_llm_output_0_shot_summaries_econ.csv"))
deepseek_output_social <- read.csv(here("data", "llm_0_shot", "deepseek_llm_output_0_shot_summaries_social.csv"))
deepseek_ranking_combined <- readRDS(here("data", "llm_ranking", "deepseek_combined_rating_summaries.rds"))


all_dir_reg <- llama_ranking_combined %>%
  select(CELEX) %>%
  left_join(all_dir_reg, by = "CELEX")


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

glove_polarity_scores_summaries_econ <- glove_polarity_scores_summaries_econ %>% 
  # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
  mutate(avg_glove_polarity_scores = avg_glove_polarity_scores * -1) %>% 
  mutate(avg_lss_econ_z_score = standardize(avg_glove_polarity_scores))

glove_polarity_scores_summaries_social <- glove_polarity_scores_summaries_social %>% 
  # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
  mutate(avg_glove_polarity_scores = avg_glove_polarity_scores * -1) %>% 
  mutate(avg_lss_social_z_score = standardize(avg_glove_polarity_scores))

hix_hoyland_data_summaries <- hix_hoyland_data_summaries %>% 
  mutate(RoBERT_left_right_z_score = standardize(RoBERT_left_right)) %>% 
  mutate(bakker_hobolt_econ_z_score = standardize(bakker_hobolt_econ)) %>% 
  mutate(bakker_hobolt_social_z_score = standardize(bakker_hobolt_social)) %>% 
  mutate(cmp_left_right_z_score = standardize(cmp_left_right))

chatgpt_summary_0_shot <- chatgpt_summary_0_shot %>%
  mutate(chatgpt_summary_0_shot_z_score = standardize(chatgpt_answer))

llama_summary_0_shot <- llama_summary_0_shot %>%
  mutate(llama_summary_0_shot_z_score = standardize(avg_score))

chatgpt_ranking_combined <- chatgpt_ranking_combined %>%
  rename(chatgpt_ranking_z_score = llm_ranking_z_score)

llama_ranking_combined <- llama_ranking_combined %>%
  rename(llama_ranking_z_score = llm_ranking_z_score)

llama_ranking_combined_3_reps <- llama_ranking_combined_3_reps %>%
  rename(llama_ranking_z_score_3_reps = llm_ranking_z_score)

deepseek_output_econ <- deepseek_output_econ %>%
  rename(deepseek_econ_0_shot_z_score = output) %>% 
  mutate(deepseek_econ_0_shot_z_score = standardize(deepseek_econ_0_shot_z_score)) %>% 
  rename(CELEX = id_var)

deepseek_output_social <- deepseek_output_social %>%
  rename(deepseek_social_0_shot_z_score = output) %>% 
  mutate(deepseek_social_0_shot_z_score = standardize(deepseek_social_0_shot_z_score)) %>% 
  rename(CELEX = id_var)

deepseek_ranking_combined <- deepseek_ranking_combined %>%
  rename(deepseek_ranking_z_score = llm_ranking_z_score) %>% 
  mutate(deepseek_ranking_z_score = standardize(deepseek_ranking_z_score))


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
  left_join(select(glove_polarity_scores_summaries_econ, CELEX, avg_lss_econ_z_score), by = "CELEX") %>% 
  left_join(select(glove_polarity_scores_summaries_social, CELEX, avg_lss_social_z_score), by = "CELEX") %>% 
  left_join(select(hix_hoyland_data_summaries, CELEX, RoBERT_left_right_z_score, bakker_hobolt_econ_z_score, bakker_hobolt_social_z_score, cmp_left_right_z_score), by = "CELEX") %>% 
  left_join(select(chatgpt_summary_0_shot, CELEX, chatgpt_summary_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(llama_summary_0_shot, CELEX, llama_summary_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(chatgpt_ranking_combined, CELEX, chatgpt_ranking_z_score), by = "CELEX") %>%
  left_join(select(llama_ranking_combined, CELEX, llama_ranking_z_score), by = "CELEX") %>% 
  left_join(select(llama_ranking_combined_3_reps, CELEX, llama_ranking_z_score_3_reps), by = "CELEX") %>% 
  left_join(select(deepseek_output_econ, CELEX, deepseek_econ_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(deepseek_output_social, CELEX, deepseek_social_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(deepseek_ranking_combined, CELEX, deepseek_ranking_z_score), by = "CELEX")

# Save raw results to file for evaluation
saveRDS(broad_policy_mpolicy_avg_df, file = here("data", "evaluation", "broad_policy_mpolicy_avg_df_summaries_raw_results.rds"))

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
saveRDS(broad_policy_mpolicy_avg_df, file = here("data", "evaluation", "broad_policy_mpolicy_avg_df_summaries.rds"))
