
# Scrape Remaining Legislations (2019 -- August 2024) -------------------------

# CEPS only contains legislations up until 2019.
# More recent legislations have to be scraped manually.


## Get date of most recent CEPS legislation ----------------------------

ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))

ceps_eurlex_dir_reg <- ceps_eurlex_dir_reg %>% 
  left_join(select(ceps_eurlex, CELEX, Date_document), by = "CELEX") %>% 
  mutate(Date_document = as.Date(Date_document, format = "%Y-%m-%d")) # Convert date to date format

ceps_most_recent_date <- max(ceps_eurlex_dir_reg$Date_document) # "2019-09-20"


# Scrape missing legislations ---------------------------
# Source: https://michalovadek.github.io/eurlex/

## Create query ---------------

# Directives
query_dir <- elx_make_query(resource_type = "directive",
                            include_celex = T,
                            include_date = T)

# Regulations
query_reg <- elx_make_query(resource_type = "regulation",
                            include_celex = T,
                            include_date = T)

## Execute query -------------------------

# Directives
query_dir <- elx_run_query(query_dir)

query_dir <- query_dir %>% 
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>% # Convert date to date format
  # Only get directives after ceps_most_recent_date
  dplyr::filter(date >= ceps_most_recent_date)

scraped_dir <- query_dir %>% 
  mutate(work = paste("http://publications.europa.eu/resource/cellar/", work, sep = "")) %>% 
  # possibly() catches errors in case there is a server issue
  mutate(title = map_chr(work, possibly(elx_fetch_data, otherwise = NA_character_), "title")) %>% 
  mutate(text = map_chr(work, possibly(elx_fetch_data, otherwise = NA_character_), "text"))

saveRDS(scraped_dir, file = here("data", "data_collection", "scraped_dir.rds")) 

# Regulations
query_reg <- elx_run_query(query_reg)

query_reg <- query_reg %>% 
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>% # Convert date to date format
  # Only get regulations after ceps_most_recent_date
  dplyr::filter(date >= ceps_most_recent_date)


# NOT RUN YET: RUN ON 240815 IN AFTERNOON/EVENING!!!!!!!!!!!
scraped_reg <- query_reg %>% 
  mutate(work = paste("http://publications.europa.eu/resource/cellar/", work, sep = "")) %>% 
  # possibly() catches errors in case there is a server issue
  mutate(title = map_chr(work, possibly(elx_fetch_data, otherwise = NA_character_), "title")) %>% 
  mutate(text = map_chr(work, possibly(elx_fetch_data, otherwise = NA_character_), "text"))

saveRDS(scraped_reg, file = here("data", "data_collection", "scraped_reg.rds"))


# Merge directives and regulations --------------------------

# TO DO
scraped_dir_reg <- scraped_dir %>% 
  rbind(scraped_reg)

saveRDS(scraped_dir_reg, file = here("data", "data_collection", "scraped_dir_reg.rds"))


# Save meta data (CELEX, date, type) --------------------

meta_scraped_dir_reg <- query_dir %>%
  rbind(query_reg) %>%
  select(-work) %>% 
  mutate(type = case_when(type == "DIR" ~ "Directive",
                          type == "DIR_DEL" ~ "Directive",
                          type == "DIR_IMPL" ~ "Directive",
                          type == "REG" ~ "Regulation",
                          type == "REG_DEL" ~ "Regulation",
                          type == "REG_IMPL" ~ "Regulation"
                          )) %>% 
  rename(Act_type = type,
         CELEX = celex,
         Date_document = date)

saveRDS(meta_scraped_dir_reg, file = here("data", "data_collection", "meta_scraped_dir_reg.rds"))
