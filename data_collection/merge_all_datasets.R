
# Merge All Datasets ---------------------------------------

# Create a comprehensive dataset with all directives and regulations that includes all scores
# Columns:

# -------- [Meta]
# --CELEX 
# --Date
# --act_raw_text
# --Summary (if applicable)
# --Act_type
# --original eurlex policy area
# --Policy area from the Nanou, Zapryanova, and Toth (2017) Dataset
# -------- [Scores]
# --RoBERT_left_right preamble
# --bakker_hobolt_econ preamble
# --bakker_hobolt_social preamble
# --cmp_left_right preamble
# --RoBERT_left_right summary
# --bakker_hobolt_econ summary
# --bakker_hobolt_social summary
# --cmp_left_right summary
# --LSS econ preamble
# --LSS social preamble
# --ChatGPT 0-Shot preamble
# --ChatGPT 0-Shot summary
# --ChatGPT Ranking summary
# --Llama Economic Ranking summary
# --Deepseek Economic Ranking summary
# --Deepseek Social Ranking summary


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


# Load Scores ---------------------------------------

# Hix & Høyland
hix_hoyland_preamble <- readRDS(here("existing_measurements", "hix_hoyland_2024", "hix_hoyland_data.rds"))
hix_hoyland_preamble <- hix_hoyland_preamble %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(hix_hoyland_robert_left_right_preamble = RoBERT_left_right,
         hix_hoyland_bakker_hobolt_econ_preamble = bakker_hobolt_econ,
         hix_hoyland_bakker_hobolt_social_preamble = bakker_hobolt_social,
         hix_hoyland_cmp_left_right_preamble = cmp_left_right)

hix_hoyland_summary <- readRDS(here("existing_measurements", "hix_hoyland_2024", "hix_hoyland_data_summaries.rds"))
hix_hoyland_summary <- hix_hoyland_summary %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(hix_hoyland_robert_left_right_summary = RoBERT_left_right,
         hix_hoyland_bakker_hobolt_econ_summary = bakker_hobolt_econ,
         hix_hoyland_bakker_hobolt_social_summary = bakker_hobolt_social,
         hix_hoyland_cmp_left_right_summary = cmp_left_right)

# LSS
lss_econ_preamble <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_econ.rds"))
lss_econ_preamble <- lss_econ_preamble %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(lss_econ_preamble = avg_glove_polarity_scores)

lss_social_preamble <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_social.rds"))
lss_social_preamble <- lss_social_preamble %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(lss_social_preamble = avg_glove_polarity_scores)

lss_econ_summary <- readRDS(here("data", "lss", "glove_polarity_scores_summaries_econ.rds"))
lss_econ_summary <- lss_econ_summary %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(lss_econ_summary = avg_glove_polarity_scores)

lss_social_summary <- readRDS(here("data", "lss", "glove_polarity_scores_summaries_social.rds"))
lss_social_summary <- lss_social_summary %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(lss_social_summary = avg_glove_polarity_scores)

# ChatGPT 0-Shot
chatgpt_preamble_0_shot <- readRDS(here("data", "llm_0_shot", "chatgpt_preamble_0_shot.rds"))
chatgpt_preamble_0_shot <- chatgpt_preamble_0_shot %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(chatgpt_0_shot_econ_preamble = GPT_Output)

chatgpt_summary_0_shot <- readRDS(here("data", "llm_0_shot", "chatgpt_summary_0_shot.rds"))
chatgpt_summary_0_shot <- chatgpt_summary_0_shot %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(chatgpt_0_shot_econ_summary = chatgpt_answer)

# Llama 0-Shot
llama_preamble_0_shot <- readRDS(here("data", "llm_0_shot", "llama_preamble_0_shot.rds"))
llama_preamble_0_shot <- llama_preamble_0_shot %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(llama_0_shot_econ_preamble = response)

llama_summary_0_shot <- readRDS(here("data", "llm_0_shot", "llama_summary_0_shot.rds"))
llama_summary_0_shot <- llama_summary_0_shot %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>% 
  rename(llama_0_shot_econ_summary = avg_score)

# Deepseek 0-Shot
deepseek_summary_0_shot_econ <- read.csv(here("data", "llm_0_shot", "deepseek_llm_output_0_shot_summaries_econ.csv"))
deepseek_summary_0_shot_econ <- deepseek_summary_0_shot_econ %>% 
  rename(CELEX = id_var,
         deepseek_0_shot_econ_summary = output) %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T)

deepseek_summary_0_shot_social <- read.csv(here("data", "llm_0_shot", "deepseek_llm_output_0_shot_summaries_social.csv"))
deepseek_summary_0_shot_social <- deepseek_summary_0_shot_social %>% 
  rename(CELEX = id_var,
         deepseek_0_shot_social_summary = output) %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T)

# ChatGPT Ranking
chatgpt_ranking_combined <- readRDS(here("data", "llm_ranking", "chatgpt_combined_rating.rds"))
chatgpt_ranking_combined <- chatgpt_ranking_combined %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>%
  rename(chatgpt_ranking_econ_summary_z_score = llm_ranking_z_score)

# Llama Ranking 
llama_econ_ranking_summary <- readRDS("/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/llama_combined_rating.rds")
llama_econ_ranking_summary <- llama_econ_ranking_summary %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>%
  rename(llama_ranking_econ_summary_z_score = llm_ranking_z_score)

# Deepseek Ranking
deepseek_econ_ranking_summary <- readRDS("/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/deepseek_combined_rating_summaries.rds")
deepseek_econ_ranking_summary <- deepseek_econ_ranking_summary %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>%
  rename(deepseek_ranking_econ_summary_z_score = llm_ranking_z_score)

deepseek_social_ranking_summary <- readRDS("/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/deepseek_combined_social_ranking_summaries.rds")
deepseek_social_ranking_summary <- deepseek_social_ranking_summary %>% 
  drop_na(CELEX) %>% 
  distinct(CELEX, .keep_all = T) %>%
  rename(deepseek_ranking_social_summary_z_score = llm_ranking_z_score)

# Merge scores
all_data <- all_data %>% 
  left_join(hix_hoyland_preamble, by = "CELEX") %>% 
  left_join(hix_hoyland_summary, by = "CELEX") %>% 
  left_join(lss_econ_preamble, by = "CELEX") %>% 
  left_join(lss_social_preamble, by = "CELEX") %>% 
  left_join(lss_econ_summary, by = "CELEX") %>% 
  left_join(lss_social_summary, by = "CELEX") %>% 
  left_join(chatgpt_preamble_0_shot, by = "CELEX") %>% 
  left_join(chatgpt_summary_0_shot, by = "CELEX") %>% 
  left_join(llama_preamble_0_shot, by = "CELEX") %>% 
  left_join(llama_summary_0_shot, by = "CELEX") %>% 
  left_join(chatgpt_ranking_combined, by = "CELEX") %>% 
  left_join(llama_econ_ranking_summary, by = "CELEX") %>% 
  left_join(deepseek_econ_ranking_summary, by = "CELEX") %>% 
  left_join(deepseek_social_ranking_summary, by = "CELEX") %>% 
  left_join(deepseek_summary_0_shot_econ, by = "CELEX") %>% 
  left_join(deepseek_summary_0_shot_social, by = "CELEX")
  
# Check for consistent column naming
# colnames(all_data)

# Save to file
saveRDS(all_data, file = here("data", "data_collection", "all_data.rds"))
