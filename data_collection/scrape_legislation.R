
# Scrape Remaining Legislations (2019 -- August 2024) -------------------------

# CEPS only contains legislations up until 2019.
# More recent legislations have to be scraped manually.


## Get date of most recent CEPS legislation ----------------------------

ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))

ceps_eurlex_dir_reg <- ceps_eurlex_dir_reg %>% 
  left_join(select(ceps_eurlex, CELEX, Date_document), by = "CELEX") %>% 
  mutate(Date_document = as.Date(Date_document, format = "%Y-%m-%d")) # Convert date to date format

max(ceps_eurlex_dir_reg$Date_document) # "2019-09-20"


# Scrape missing legislations
