
# CEPS EurLex dataset ---------------------------------------

# Source: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/0EGYWY (retrieved 7 June 2024)
# Documentation: https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/0EGYWY/RVEJU9&version=2.0

# Import dataset and save as RDS

# Import CSV
# ceps_eurlex <- read.csv("/Volumes/iPhone_Backup_1/eu-policy-feedback-data/EurLex_all.csv", stringsAsFactors = FALSE)

# Save as RDS
# saveRDS(ceps_eurlex, file = "/Volumes/iPhone_Backup_1/eu-policy-feedback-data/ceps_eurlex.rds")

# Load RDS
ceps_eurlex <- readRDS(here("data", "ceps_eurlex.rds"))

# Create subset of directives and regulations --------------------------
ceps_eurlex_dir_reg <- ceps_eurlex %>% 
  mutate(Date_publication = as.Date(Date_publication, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_publication >= "1989-01-01") %>%
  dplyr::filter(str_detect(Act_type, "Directive|Regulation")) %>% 
  select(CELEX, act_raw_text) %>%
  # Remove rows where act_raw_text is the string "nan"
  dplyr::filter(act_raw_text != "nan")

saveRDS(ceps_eurlex_dir_reg, file = here("data", "ceps_eurlex_dir_reg.rds"))

# Create subset of directives and regulations with subject matter --------------------------
ceps_eurlex_dir_reg_subject_matter <- ceps_eurlex %>% 
  mutate(Date_publication = as.Date(Date_publication, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_publication >= "1989-01-01") %>%
  dplyr::filter(str_detect(Act_type, "Directive|Regulation")) %>% 
  select(CELEX, Subject_matter)

saveRDS(ceps_eurlex_dir_reg_subject_matter, file = here("data", "ceps_eurlex_dir_reg_subject_matter.rds"))
