
# LSS Evaluation --------------------------

# Is there a correlation between ideology and subject matter?

# Load data with subject matter
ceps_eurlex_dir_reg_subject_matter <- readRDS(here("data", "ceps_eurlex_dir_reg_subject_matter.rds"))

test_df <- glove_polarity_scores %>% 
  left_join(ceps_eurlex_dir_reg_subject_matter, by = "CELEX")
