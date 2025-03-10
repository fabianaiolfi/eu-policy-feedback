
# Overall Evaluation -----------------------------------

# Comparing different automated methods with expert scores


## Load data -----------------------

# Averaged expert measurements from eu-policy-feedback/existing_measurements/nanou_2017/extract_expert_measurements.R
nanou_2017_mpolicy_lrscale3 <- readRDS(here("existing_measurements", "nanou_2017", "nanou_2017_mpolicy_lrscale3.rds"))
# nanou_2017_spolicy_lrscale3 <- readRDS(here("existing_measurements", "nanou_2017", "nanou_2017_spolicy_lrscale3.rds"))
all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))
# all_dir_reg <- all_dir_reg %>% slice_sample(n = 100)

# policy_area_ceps_eurlex_subj_matter_mpolicy <- readRDS(here("data", "evaluation", "policy_area_ceps_eurlex_subj_matter_mpolicy.rds")) # eu-policy-feedback/evaluation/policy_area_ceps_eurlex_subj_matter_mpolicy.R
policy_area_moodley_subj_matter_mpolicy <- readRDS(here("data", "evaluation", "policy_area_moodley_subj_matter_mpolicy.rds")) # eu-policy-feedback/evaluation/policy_area_moodley_subj_matter_mpolicy.R
# policy_area_subj_matter_spolicy <- readRDS(here("data", "evaluation", "policy_area_subj_matter_spolicy.rds")) # eu-policy-feedback/evaluation/policy_area_subj_matter_spolicy.R

# Import Calculated measurements
glove_polarity_scores_all_dir_reg_econ <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_econ.rds"))
glove_polarity_scores_all_dir_reg_social <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_social.rds"))
hix_hoyland_data <- readRDS(here("existing_measurements", "hix_hoyland_2024", "hix_hoyland_data.rds"))

# Directive/Regulation Summaries Only (ChatGPT)
chatgpt_preamble_0_shot <- readRDS(here("data", "llm_0_shot", "chatgpt_preamble_0_shot.rds"))
chatgpt_summary_0_shot <- readRDS(here("data", "llm_0_shot", "chatgpt_summary_0_shot.rds"))
llama_summary_0_shot <- readRDS(here("data", "llm_0_shot", "llama_summary_0_shot.rds"))

chatgpt_ranking_combined <- readRDS(here("data", "llm_ranking", "chatgpt_combined_rating.rds"))

llama_ranking_combined <- readRDS(here("data", "llm_ranking", "llama_combined_rating.rds"))
llama_ranking_combined <- llama_ranking_combined %>% rename(llama_ranking_z_score = llm_ranking_z_score)

# all_dir_reg <- hix_hoyland_data %>%
#   select(CELEX) %>%
#   left_join(all_dir_reg, by = "CELEX")

# When working with summaries only
# all_dir_reg <- llama_ranking_combined %>%
#   select(CELEX) %>%
#   left_join(all_dir_reg, by = "CELEX")

## Add Subject Matter to all_dir_reg -----------------------

# Import and clean CEPS Eurlex
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
ceps_eurlex <- ceps_eurlex %>%
  select(CELEX, Subject_matter) %>% 
  rename(subject_matter_ceps = Subject_matter) %>% 
  mutate(subject_matter_ceps = gsub("  ", " ", subject_matter_ceps)) %>% 
  mutate(subject_matter_ceps = tolower(subject_matter_ceps))

# Import and clean Moodley
moodley <- read.csv(here("data", "data_collection", "eu_regulations_metadata_1971_2022.csv"), stringsAsFactors = F)
moodley <- moodley %>% 
  select(celex, subject_matters) %>% 
  rename(subject_matter_moodley = subject_matters) %>%
  rename(CELEX = celex) %>% 
  mutate(subject_matter_moodley = gsub(" \\| ", "; ", subject_matter_moodley)) %>%
  mutate(subject_matter_moodley = tolower(subject_matter_moodley))

all_dir_reg <- all_dir_reg %>%
  left_join(ceps_eurlex, by = "CELEX") %>% 
  left_join(moodley, by = "CELEX")


## Preprocess Data -----------------------

nanou_2017_mpolicy_lrscale3 <- nanou_2017_mpolicy_lrscale3 %>% 
  # Perform standardization of data (z-scoring)
  mutate(lrscale3_avg_z_score = standardize(lrscale3_avg))

# nanou_2017_spolicy_lrscale3 <- nanou_2017_spolicy_lrscale3 %>% 
  # Perform standardization of data (z-scoring)
  # mutate(lrscale3_avg_z_score = standardize(lrscale3_avg))

glove_polarity_scores_all_dir_reg_econ <- glove_polarity_scores_all_dir_reg_econ %>% 
  # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
  mutate(avg_glove_polarity_scores = avg_glove_polarity_scores * -1) %>% 
  # Perform standardization of data (z-scoring)
  mutate(avg_lss_econ_z_score = standardize(avg_glove_polarity_scores))

glove_polarity_scores_all_dir_reg_social <- glove_polarity_scores_all_dir_reg_social %>% 
  # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
  mutate(avg_glove_polarity_scores = avg_glove_polarity_scores * -1) %>% 
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
  mutate(chatgpt_preamble_0_shot_z_score = standardize(GPT_Output))

chatgpt_summary_0_shot <- chatgpt_summary_0_shot %>%
  # Perform standardization of data (z-scoring)
  mutate(chatgpt_summary_0_shot_z_score = standardize(chatgpt_answer))

llama_summary_0_shot <- llama_summary_0_shot %>%
  # Perform standardization of data (z-scoring)
  mutate(llama_summary_0_shot_z_score = standardize(avg_score))

chatgpt_ranking_combined <- chatgpt_ranking_combined %>%
  rename(chatgpt_ranking_z_score = llm_ranking_z_score)

# chatgpt_ranking_left <- chatgpt_ranking_left %>%
#   # Perform standardization of data (z-scoring)
#   mutate(chatgpt_ranking_left_z_score = standardize(rating)) %>% 
#   # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
#   mutate(chatgpt_ranking_left_z_score = chatgpt_ranking_left_z_score * -1)

# chatgpt_ranking_right <- chatgpt_ranking_right %>%
#   # Perform standardization of data (z-scoring)
#   mutate(chatgpt_ranking_right_z_score = standardize(rating))

# llama_ranking_left <- llama_ranking_left %>%
#   # Perform standardization of data (z-scoring)
#   mutate(llama_ranking_left_z_score = standardize(rating)) %>% 
#   # Reverse scale so that it aligns with Hix Høyland method: >0: More right; <0: More left
#   mutate(llama_ranking_left_z_score = llama_ranking_left_z_score * -1)


## Connect a Law's Subject Matter with the Broad Policy Area from Nanou 2017 -----------------------

# Please switch manually between mpolicy (broad policy area) and spolicy (detailed policy area)

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

all_dir_reg$broad_policy_area_mpolicy_moodley <- sapply(all_dir_reg$subject_matter_moodley, match_policy_area, lookup_df = policy_area_moodley_subj_matter_mpolicy)
# all_dir_reg$broad_policy_area_spolicy <- sapply(all_dir_reg$Subject_matter, match_policy_area, lookup_df = policy_area_subj_matter_spolicy)

# Save for merge_all_datasets.R
nanou_broad_policy_area <- all_dir_reg %>% 
  select(CELEX, broad_policy_area_mpolicy_moodley) %>% 
  drop_na(CELEX)

saveRDS(nanou_broad_policy_area, file = here("data", "data_collection", "nanou_broad_policy_area.rds"))

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
  left_join(select(glove_polarity_scores_all_dir_reg_econ, CELEX, avg_lss_econ_z_score), by = "CELEX") %>% 
  left_join(select(glove_polarity_scores_all_dir_reg_social, CELEX, avg_lss_social_z_score), by = "CELEX") %>% 
  left_join(select(hix_hoyland_data, CELEX, RoBERT_left_right_z_score, bakker_hobolt_econ_z_score, bakker_hobolt_social_z_score, cmp_left_right_z_score), by = "CELEX") %>% 
  left_join(select(chatgpt_preamble_0_shot, CELEX, chatgpt_preamble_0_shot_z_score), by = "CELEX") %>%
  left_join(select(chatgpt_summary_0_shot, CELEX, chatgpt_summary_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(llama_summary_0_shot, CELEX, llama_summary_0_shot_z_score), by = "CELEX") %>% 
  left_join(select(chatgpt_ranking_combined, CELEX, chatgpt_ranking_z_score), by = "CELEX") %>%
  left_join(select(llama_ranking_combined, CELEX, llama_ranking_z_score), by = "CELEX")

# broad_policy_spolicy_avg_df <- all_dir_reg %>% 
#   select(CELEX, Date_document, broad_policy_area_spolicy) %>% 
#   mutate(year = as.numeric(format(Date_document, "%Y"))) %>% 
#   select(-Date_document) %>% 
#   drop_na(broad_policy_area_spolicy) %>% 
#   separate_rows(broad_policy_area_spolicy, sep = "; ") %>% # Place each Broad Policy Area on its own row
#   distinct(CELEX, broad_policy_area_spolicy, .keep_all = T) %>% 
#   # Add calculated scores
#   left_join(select(glove_polarity_scores_all_dir_reg_econ, CELEX, avg_lss_econ_z_score), by = "CELEX") %>% 
#   left_join(select(glove_polarity_scores_all_dir_reg_social, CELEX, avg_lss_social_z_score), by = "CELEX") %>% 
#   left_join(select(hix_hoyland_data, CELEX, RoBERT_left_right_z_score, bakker_hobolt_econ_z_score, bakker_hobolt_social_z_score, cmp_left_right_z_score), by = "CELEX") %>% 
#   left_join(select(chatgpt_preamble_0_shot, CELEX, chatgpt_preamble_0_shot_z_score), by = "CELEX") %>%
#   left_join(select(chatgpt_summary_0_shot, CELEX, chatgpt_summary_0_shot_z_score), by = "CELEX") %>% 
#   left_join(select(chatgpt_ranking_combined, CELEX, llm_ranking_z_score), by = "CELEX") %>% 
#   left_join(select(llama_ranking_left, CELEX, llama_ranking_left_z_score), by = "CELEX")

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

# broad_policy_spolicy_avg_df <- broad_policy_spolicy_avg_df %>%
#   mutate(period = case_when(
#     year %in% 1989:1990 ~ "1989-1990",
#     year %in% 1991:1995 ~ "1991-1995",
#     year %in% 1996:2000 ~ "1996-2000",
#     year %in% 2001:2005 ~ "2001-2005",
#     year %in% 2006:2010 ~ "2006-2010",
#     year %in% 2011:2014 ~ "2011-2014",
#     year %in% 2014:2024 ~ "2014-2024",
#     TRUE ~ NA_character_)) %>% 
#   drop_na(period) %>%
#   group_by(broad_policy_area_spolicy, period) %>%
#   summarize(across(contains("z_score"), ~ mean(.x, na.rm = TRUE)), .groups = "drop") %>% 
#   ungroup()

# Add Nanou 2017
broad_policy_mpolicy_avg_df <- broad_policy_mpolicy_avg_df %>% 
  left_join(select(nanou_2017_mpolicy_lrscale3, broad_policy_area, period, lrscale3_avg_z_score), by = c("broad_policy_area_mpolicy_moodley" = "broad_policy_area", "period")) %>% 
  rename(nanou_2017_mpolicy_lrscale3 = lrscale3_avg_z_score)

# broad_policy_spolicy_avg_df <- broad_policy_spolicy_avg_df %>% 
#   left_join(select(nanou_2017_spolicy_lrscale3, broad_policy_area, period, lrscale3_avg_z_score), by = c("broad_policy_area_spolicy" = "broad_policy_area", "period")) %>% 
#   rename(nanou_2017_spolicy_lrscale3 = lrscale3_avg_z_score)


## Examine Complete Dataframe -----------------------

# Please switch manually between mpolicy and spolicy

# Correlations
cor_df <- broad_policy_mpolicy_avg_df %>% select(-broad_policy_area_mpolicy_moodley, -period)
correlation_matrix <- cor(cor_df, use = "pairwise.complete.obs")
correlation_melt <- melt(correlation_matrix) # Convert the correlation matrix into long format for ggplot2

# Correlation heatmap
ggplot(correlation_melt, aes(x = Var1, y = Var2, fill = value)) +
  ggtitle(label = "Correlation Heatmap (mpolicy)") + #,
          # subtitle = "Analysis covers 75,570 directives and legislations") +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1, 1), space = "Lab", 
                       name="Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust = 1)) +
  coord_fixed() +
  xlab("") + ylab("")

ggsave(
  "correlation_heatmap_mpolicy.png",
  plot = last_plot(),
  path = here("evaluation", "results"),
  scale = 1,
  units = "px",
  dpi = 300,
  bg = "white"
)

# Histograms
broad_policy_long_hist <- broad_policy_mpolicy_avg_df %>%
  select(nanou_2017_mpolicy_lrscale3, contains("z_score")) %>%
  mutate(nanou_2017_mpolicy_lrscale3 = as.numeric(nanou_2017_mpolicy_lrscale3)) %>% 
  pivot_longer(cols = everything(),
               names_to = "z_score_measurement", 
               values_to = "z_score_value")

ggplot(broad_policy_long_hist, aes(x = z_score_value)) +
  geom_histogram() +
  facet_wrap(~ z_score_measurement) +
  theme_minimal()

# Correlation scatter plot
broad_policy_long <- broad_policy_mpolicy_avg_df %>%
  select(nanou_2017_mpolicy_lrscale3, contains("z_score")) %>%
  pivot_longer(cols = -nanou_2017_mpolicy_lrscale3,  # Exclude nanou_2017_mpolicy_lrscale3 from pivoting
               names_to = "z_score_measurement", 
               values_to = "z_score_value")

ggplot(broad_policy_long, aes(x = z_score_value, y = nanou_2017_mpolicy_lrscale3)) +
  ggtitle(label = "Correlation Scatter Plot",
          subtitle = "Analysis covers 75,570 directives and legislations\nY Axis: Expert Evaluation (mpolicy)\nX Axis: Calculated Measurements\nGray diagonal line serves as a reference for perfect correlation") +
  geom_point() +
  geom_smooth(method = 'lm', formula = y ~ x, se = F) +
  geom_abline(intercept = 0, slope = 1, color = "gray") +
  theme_minimal() +
  facet_wrap(~ z_score_measurement) +
  xlab("")



ggsave(
  "correlation_scatter_plot_mpolicy.png",
  plot = last_plot(),
  path = here("evaluation", "results"),
  scale = 1,
  units = "px",
  dpi = 300,
  bg = "white"
)

# Variance between own measurments and expert survey
# If the variance is low, the values in X are generally close to nanou_2017_mpolicy_lrscale3 (small differences).
# If the variance is high, the values in X deviate significantly from nanou_2017_mpolicy_lrscale3 (large differences).
variance_df <- broad_policy_mpolicy_avg_df %>%
  select(-broad_policy_area_mpolicy_moodley, -period) %>% 
  summarise(across(everything(), ~ var(.x - nanou_2017_mpolicy_lrscale3, na.rm = T))) %>% 
  pivot_longer(cols = everything(),  # Select all columns to transform
               names_to = "measurement",  # New column for the original column names
               values_to = "variance") %>% 
  arrange(variance)

write.table(variance_df,
            here("evaluation", "results", "variance_mpolicy.csv"),
            sep = ",",
            row.names = F)
