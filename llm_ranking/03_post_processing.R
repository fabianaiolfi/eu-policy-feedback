
# Post Process LLM Ranking ---------------------------------------------------------------

# Combine "most left" and "most right" rankings into a single metric


## Load Data -------------------------

ratings_df_left <- readRDS(file = here("data", "llm_ranking", "deepseek_ratings_df_left_20250105_005846.rds"))
ratings_df_right <- readRDS(file = here("data", "llm_ranking", "deepseek_ratings_df_right_20250105_005918.rds"))


## Post Process -------------------------

combined_rating <- ratings_df_left %>% 
  rename(left_rating = rating) %>% 
  left_join(ratings_df_right, by = "document") %>% 
  rename(right_rating = rating) %>% 
  # Meausure distance from center
  mutate(abs_left = 1000 - left_rating) %>% 
  mutate(abs_right = right_rating - 1000) %>% # Flipped because less right policies are more left
  # Calculate average between left and right distance from center
  rowwise() %>%
  mutate(center = mean(c_across(c(abs_left, abs_right)))) %>% 
  ungroup() %>% 
  # Calculate z-score
  mutate(llm_ranking_z_score = standardize(center)) %>% 
  # Clean up
  rename(CELEX = document) %>% 
  select(CELEX, llm_ranking_z_score)


## Save Data -------------------------

saveRDS(combined_rating, file = here("data", "llm_ranking", "deepseek_combined_rating_summaries.rds"))
