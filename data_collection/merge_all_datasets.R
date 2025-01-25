
# Merge All Datasets ---------------------------------------

# Create a comprehensive dataset with all directives and regulations that includes all scores
# Columns:

# --- [Meta]
# CELEX
# Date
# act_raw_text
# Summary (if applicable)
# Act_type
# original eurlex policy area
# Policy area from the Nanou, Zapryanova, and Toth (2017) Dataset
# --- [Scores]
# RoBERT_left_right preamble
# bakker_hobolt_econ preamble
# bakker_hobolt_social preamble
# cmp_left_right preamble
# RoBERT_left_right summary
# bakker_hobolt_econ summary
# bakker_hobolt_social summary
# cmp_left_right summary
# LSS econ preamble
# LSS social preamble
# ChatGPT 0-Shot preamble
# ChatGPT 0-Shot summary
# ChatGPT Ranking summary
# Llama Economic Ranking summary
# Deepseek Economic Ranking summary
# Deepseek Social Ranking summary


# Load Meta Datasets ---------------------------------------

# All directives and regulations
all_dir_reg <- readRDS("/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/all_dir_reg.rds")
all_dir_reg <- all_dir_reg %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(date = Date_document,
         act_string = act_raw_text,
         act_type = Act_type)

# All summaries
all_summaries <- readRDS("/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/all_dir_reg_summaries.rds")
all_summaries <- all_summaries %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(act_summary = eurlex_summary_clean)

# Subject Matters (original eurlex policy area) # Import and clean Moodley
moodley <- read.csv(here("data", "data_collection", "eu_regulations_metadata_1971_2022.csv"), stringsAsFactors = F)
moodley <- moodley %>% 
  select(celex, subject_matters) %>% 
  rename(eurlex_policy_area = subject_matters) %>%
  rename(CELEX = celex) %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  mutate(eurlex_policy_area = gsub(" \\| ", "; ", eurlex_policy_area)) %>%
  mutate(eurlex_policy_area = tolower(eurlex_policy_area))

# Policy area from the Nanou, Zapryanova, and Toth (2017) Dataset
nanou_broad_policy_area <- readRDS(file = here("data", "data_collection", "nanou_broad_policy_area.rds"))
nanou_broad_policy_area <- nanou_broad_policy_area %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(nanou_broad_policy_area = broad_policy_area_mpolicy_moodley)

# Merge meta data
all_data <- all_dir_reg %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  left_join(all_summaries, by = "CELEX") %>% 
  left_join(moodley, by = "CELEX") %>% 
  left_join(nanou_broad_policy_area, by = "CELEX")

