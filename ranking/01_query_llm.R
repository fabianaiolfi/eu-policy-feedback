
# Load Data ---------------------------------------------------------------

ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_240711_04.rds"))


# Query ChatGPT ---------------------------------------------------------------

rgpt_authenticate("access_key.txt")


# Create synthetic data for ranking algorithm testing ---------------------------------------------------------------

dummy_data <- ceps_eurlex_dir_reg_summaries %>% select(CELEX) # Only select CELEX
dummy_data <- bind_rows(replicate(3, dummy_data, simplify = F)) # Repeat same row 3 times
dummy_data <- dummy_data %>% 
  rename(doc1 = CELEX) %>%
  mutate(doc2 = sample(doc1)) %>% # Shuffle rows
  # randomly pick a value from doc1 or doc2 and save it in new column
  mutate(more_left = ifelse(runif(nrow(.)) > 0.5, doc1, doc2)) %>% 
  arrange(doc1)

