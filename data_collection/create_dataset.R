
# Create complete dataset ----------------------
# Merge CEPS Eurlex dataset with manually scraped legislations


# Load separate data files ----------------------

ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))
scraped_dir_reg <- readRDS(here("data", "data_collection", "scraped_dir_reg.rds"))


# Create dataset including all data ----------------------

# Merge into single dataframe
all_dir_reg <- scraped_dir_reg %>% 
  select(celex, date, text, type) %>% 
  rename(CELEX = celex,
         Date_document = date,
         act_raw_text = text,
         Act_type = type) %>% 
  rbind(ceps_eurlex_dir_reg) %>% 
  mutate(Act_type = case_when(Act_type == "DIR" ~ "Directive",
                              Act_type == "DIR_DEL" ~ "Directive",
                              Act_type == "DIR_IMPL" ~ "Directive",
                              Act_type == "REG" ~ "Regulation",
                              Act_type == "REG_DEL" ~ "Regulation",
                              Act_type == "REG_IMPL" ~ "Regulation",
                              Act_type == "Delegated Regulation" ~ "Regulation",
                              Act_type == "Directive_DEL" ~ "Directive",
                              Act_type == "Directive_IMPL" ~ "Directive",
                              Act_type == "Implementing Regulation" ~ "Regulation",
                              Act_type == "Regulation_FINANC" ~ "Regulation",
                              T ~ Act_type))

# Problem: Some new legislations contain a meta data-like section at the beginning of the text.
# This causes an error with RoBERTa-RILE in hix_hoyland_2024.R.
# Solution: Remove this section.

# Function to remove meta data
remove_meta_data <- function(text) {
  # Check if the text is NA
  if (is.na(text)) {
    return(NA)
  }
  
  # Use regex to find the first occurrence of a double line break
  match <- regexpr("\n\n", text)
  
  # If the double line break is found, truncate the string to start from the match
  if (match[1] != -1) {
    return(substr(text, match[1] + 2, nchar(text))) # +2 to exclude the line break itself
  } else {
    return(text)
  }
}

# Apply the function
all_dir_reg <- all_dir_reg %>%
  mutate(act_raw_text = sapply(act_raw_text, remove_meta_data))

# Save to file
saveRDS(all_dir_reg, file = here("data", "data_collection", "all_dir_reg.rds"))


# Create meta data dataset (CELEX, date, type) --------------------
# Used for summary scraping

meta_scraped_dir_reg <- readRDS(here("data", "data_collection", "meta_scraped_dir_reg.rds"))

meta_dir_reg <- ceps_eurlex_dir_reg %>% 
  select(-act_raw_text) %>% 
  rbind(meta_scraped_dir_reg)

saveRDS(meta_dir_reg, file = here("data", "data_collection", "meta_dir_reg.rds"))
