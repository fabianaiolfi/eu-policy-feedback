
# Overall Evaluation -----------------------------------

# Comparing different automated methods with expert scores


## Load data -----------------------

nanou_2017_lrscale3 <- readRDS(here("existing_measurements", "nanou_2017", "nanou_2017_lrscale3.rds")) # Averaged expert measurements from extract_expert_measurements.R
all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))
all_dir_reg <- all_dir_reg %>% slice_sample(n = 1000)

# source(here("evaluation", "policy_area_subj_matter.R")) # Run script
policy_area_subj_matter <- readRDS(here("data", "evaluation", "policy_area_subj_matter.rds")) # Load data

# Import Calculated measurements
glove_polarity_scores_all_dir_reg_econ <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_econ.rds"))
glove_polarity_scores_all_dir_reg_social <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_social.rds"))
hix_hoyland_data <- readRDS(here("existing_measurements", "hix_hoyland_2024", "hix_hoyland_data.rds"))

# Directive/Regulation Summaries Only (ChatGPT)
chatgpt_preamble_0_shot <- readRDS(here("data", "chatgpt_0_shot", "chatgpt_preamble_0_shot.rds"))
chatgpt_summary_0_shot <- readRDS(here("data", "chatgpt_0_shot", "chatgpt_summary_0_shot.rds"))
all_dir_reg <- chatgpt_preamble_0_shot %>% 
  select(CELEX) %>% 
  left_join(all_dir_reg, by = "CELEX")

# Add Subject Matter to all_dir_reg
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
ceps_eurlex <- ceps_eurlex %>% select(CELEX, Subject_matter)
all_dir_reg <- all_dir_reg %>% left_join(ceps_eurlex, by = "CELEX")


## Preprocess Data -----------------------

nanou_2017_lrscale3 <- nanou_2017_lrscale3 %>% 
  # Perform standardization of data (z-scoring)
  mutate(lrscale3_avg_z_score = standardize(lrscale3_avg))

glove_polarity_scores_all_dir_reg_econ <- glove_polarity_scores_all_dir_reg_econ %>% 
  # Perform standardization of data (z-scoring)
  mutate(avg_lss_econ_z_score = standardize(avg_glove_polarity_scores))

glove_polarity_scores_all_dir_reg_social <- glove_polarity_scores_all_dir_reg_social %>% 
  # Perform standardization of data (z-scoring)
  mutate(avg_lss_social_z_score = standardize(avg_glove_polarity_scores))

hix_hoyland_data <- hix_hoyland_data %>% 
  # Perform standardization of data (z-scoring)
  mutate(RoBERT_left_right_z_score = standardize(RoBERT_left_right)) %>% 
  mutate(bakker_hobolt_econ_z_score = standardize(bakker_hobolt_econ)) %>% 
  mutate(bakker_hobolt_social_z_score = standardize(bakker_hobolt_social)) %>% 
  mutate(cmp_left_right_z_score = standardize(cmp_left_right))

chatgpt_preamble_0_shot <- chatgpt_preamble_0_shot %>% 
  # Perform standardization of data (z-scoring)
  mutate(chatgpt_preamble_0_shot_z_score = standardize(chatgpt_answer))

chatgpt_summary_0_shot <- chatgpt_summary_0_shot %>% 
  # Perform standardization of data (z-scoring)
  mutate(chatgpt_summary_0_shot_z_score = standardize(chatgpt_answer))


## Connect a Law's Subject Matter with the Broad Policy Area from Nanou 2017 -----------------------

# Function to match subject matter terms to broad policy areas, accounting for match frequency
match_policy_area <- function(subject_matter, lookup_df) {
  # Initialize a named vector to store the count of matches per broad policy area
  match_count <- setNames(rep(0, length(unique(lookup_df$broad_policy_area))), 
                          unique(lookup_df$broad_policy_area))
  
  # Loop through each subject matter term in the lookup table
  for (i in seq_along(lookup_df$subject_matter)) {
    if (grepl(lookup_df$subject_matter[i], subject_matter, ignore.case = TRUE)) {
      # Increment the count for the corresponding broad policy area
      match_count[lookup_df$broad_policy_area[i]] <- match_count[lookup_df$broad_policy_area[i]] + 1
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

all_dir_reg$broad_policy_area <- sapply(all_dir_reg$Subject_matter, match_policy_area, lookup_df = policy_area_subj_matter)


## Calculate Averages per Time Period and Broad Policy Area ---------------------------------

# Create a dataframe that allows us to calculate the average score per time period and broad policy area

# Preprocess data and add calculated scores
broad_policy_avg_df <- all_dir_reg %>% 
  select(CELEX, Date_document, broad_policy_area) %>% 
  mutate(year = as.numeric(format(Date_document, "%Y"))) %>% 
  select(-Date_document) %>% 
  drop_na(broad_policy_area) %>% 
  separate_rows(broad_policy_area, sep = "; ") %>% # Place each Broad Policy Area on its own row
  # Add calculated scores
  left_join(select(glove_polarity_scores_all_dir_reg_econ, CELEX, avg_lss_econ_z_score), by = "CELEX") %>% 
  left_join(select(glove_polarity_scores_all_dir_reg_social, CELEX, avg_lss_social_z_score), by = "CELEX") %>% 
  left_join(select(hix_hoyland_data, CELEX, RoBERT_left_right_z_score, bakker_hobolt_econ_z_score, bakker_hobolt_social_z_score, cmp_left_right_z_score), by = "CELEX") %>% 
  left_join(select(chatgpt_preamble_0_shot, CELEX, chatgpt_preamble_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(chatgpt_summary_0_shot, CELEX, chatgpt_summary_0_shot_z_score), by = "CELEX")

# Calcualate averages based on time periods
broad_policy_avg_df <- broad_policy_avg_df %>%
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
  group_by(broad_policy_area, period) %>%
  summarize(across(contains("z_score"), ~ mean(.x, na.rm = TRUE)), .groups = "drop") %>% 
  ungroup()

# Add Nanou 2017
broad_policy_avg_df <- broad_policy_avg_df %>% 
  left_join(select(nanou_2017_lrscale3, broad_policy_area, period, lrscale3_avg_z_score), by = c("broad_policy_area", "period")) %>% 
  rename(nanou_2017_z_score = lrscale3_avg_z_score)


## Examine Complete Dataframe -----------------------

# Correlations
cor_df <- broad_policy_avg_df %>% select(-broad_policy_area, -period)
correlation_matrix <- cor(cor_df, use = "pairwise.complete.obs")
correlation_melt <- melt(correlation_matrix) # Convert the correlation matrix into long format for ggplot2

# Correlations heatmap
ggplot(data = correlation_melt, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name="Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust = 1)) +
  coord_fixed() +
  xlab("") + ylab("")

plot(broad_policy_avg_df$bakker_hobolt_social_z_score, broad_policy_avg_df$nanou_2017_z_score)

# Variance between own measurments and expert survey
variance_df <- broad_policy_avg_df %>%
  select(-broad_policy_area, -period) %>% 
  summarise(across(everything(), ~ var(.x - nanou_2017_z_score, na.rm = T)))

## CONTINUE HERE ##
# - measurements based on chatgpt summaries seem to provide best variance and correlation values compared to expert surveys. examine this further! maybe also calculate measurements based on entire regulation/directive, not just summary.
# - other ways to compare expert survey and own measurements?
