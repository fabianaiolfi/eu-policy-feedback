
# Create complete dataset ----------------------
# Merge CEPS Eurlex dataset with manually scraped legislations

# Load separate data files
ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))
scraped_dir_reg <- readRDS(here("data", "data_collection", "scraped_dir_reg.rds"))

# Merge into single dataframe
all_dir_reg <- ceps_eurlex_dir_reg
  # TO DO
  
# Save to file
saveRDS(all_dir_reg, file = here("data", "data_collection", "all_dir_reg.rds"))