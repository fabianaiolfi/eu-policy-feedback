
# Create complete dataset ----------------------
# Merge CEPS Eurlex dataset with manually scraped legislations


# Load separate data files ----------------------

ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))
scraped_dir_reg <- readRDS(here("data", "data_collection", "scraped_dir_reg.rds"))


# Create dataset including all data ----------------------

# Merge into single dataframe
all_dir_reg <- ceps_eurlex_dir_reg
  # TO DO
  
# Save to file
# TO DO
saveRDS(all_dir_reg, file = here("data", "data_collection", "all_dir_reg.rds"))


# Create meta data dataset (CELEX, date, type) --------------------
# Used for summary scraping

meta_scraped_dir_reg <- readRDS(here("data", "data_collection", "meta_scraped_dir_reg.rds"))

meta_dir_reg <- ceps_eurlex_dir_reg %>% 
  select(-act_raw_text) %>% 
  rbind(meta_scraped_dir_reg)

saveRDS(meta_dir_reg, file = here("data", "data_collection", "meta_dir_reg.rds"))
