
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
