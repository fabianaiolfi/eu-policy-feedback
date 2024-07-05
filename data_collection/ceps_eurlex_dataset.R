
# CEPS EurLex dataset ---------------------------------------

# Source: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/0EGYWY (retrieved 7 June 2024)
# Documentation: https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/0EGYWY/RVEJU9&version=2.0

# Import dataset and save as RDS

# Import CSV
# ceps_eurlex <- read.csv("/Volumes/iPhone_Backup_1/eu-policy-feedback-data/EurLex_all.csv", stringsAsFactors = FALSE)

# Save as RDS
# saveRDS(ceps_eurlex, file = "/Volumes/iPhone_Backup_1/eu-policy-feedback-data/ceps_eurlex.rds")

# Load RDS
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))

# Create subset of directives and regulations --------------------------
ceps_eurlex_dir_reg <- ceps_eurlex %>% 
  mutate(Date_document = as.Date(Date_document, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_document >= "1989-01-01") %>%
  dplyr::filter(str_detect(Act_type, "Regulation|Directive")) %>%
  select(CELEX, act_raw_text, Act_type) %>%
  # Remove rows where act_raw_text is the string "nan"
  dplyr::filter(act_raw_text != "nan")

saveRDS(ceps_eurlex_dir_reg, file = here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))

# Create subset of directives and regulations with keywords (EUROVOC and subject matter) --------------------------
ceps_eurlex_dir_reg_keywords <- ceps_eurlex %>% 
  mutate(Date_document = as.Date(Date_document, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_document >= "1989-01-01") %>%
  dplyr::filter(str_detect(Act_type, "Directive|Regulation")) %>% 
  select(CELEX, EUROVOC, Subject_matter)

saveRDS(ceps_eurlex_dir_reg_keywords, file = here("data", "data_collection", "ceps_eurlex_dir_reg_keywords.rds"))
