
# Load Data ---------------------------------------------------------------

# ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_240711_04.rds")) # Sample of 24 summaries
# ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "all_dir_reg_summaries.rds"))
all_dir_reg <- readRDS(file = here("existing_measurements", "hix_hoyland_2024", "all_dir_reg_preamble.rds")) # Preamble
# all_dir_reg <- all_dir_reg %>% slice_sample(n = 100)
all_dir_reg <- all_dir_reg %>% drop_na(CELEX) %>% distinct(CELEX, .keep_all = T)


# Indexing ---------------------------------------------------------------

# Create a dataframe that lists two different CELEX IDs per row
celex_index <- all_dir_reg %>% 
  select(CELEX) %>% # Only select CELEX
  rename(CELEX_1 = CELEX)
celex_index <- bind_rows(replicate(5, celex_index, simplify = F)) # Repeat same row 5 times

# Function to shuffle and ensure no duplicates in the same row
create_shuffled_column <- function(df) {
  original <- df$CELEX_1
  shuffled <- sample(original)
  
  # Check and reshuffle until no duplicates are on the same row
  while(any(original == shuffled)) {
    shuffled <- sample(original)
  }
  
  df$CELEX_2 <- shuffled
  return(df)
}

# Apply the function to create the new column
celex_index <- create_shuffled_column(celex_index)


# Create Prompt Dataframe ---------------------------------------------------------------

system_prompt <- "You are an expert in European Union policies. Answer questions and provide information based on that expertise.\n\n"


## Prompt for economic *left* ---------------------------------------------------------------

prompt_start <- "I’m going to show you two EU policies, and I need to determine which policy is more economically left-leaning. Please analyze the beginning of the policies' preamble based on principles commonly associated with economically left policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights.\n\n"

prompt_end <- "Which policy is more economically left? Please return only '1' or '2'."

prompt_df <- celex_index %>% 
  left_join(all_dir_reg, by = c("CELEX_1" = "CELEX")) %>% 
  rename(preamble_1 = preamble) %>% 
  left_join(all_dir_reg, by = c("CELEX_2" = "CELEX")) %>% 
  rename(preamble_2 = preamble) %>% 
  mutate(id_var = paste0(CELEX_1, "_", CELEX_2)) %>% # ID for each row
  mutate(prompt_role_var = "user") %>% # Set role
  # Put together prompt
  mutate(prompt_content_var = paste0(system_prompt, 
                                     prompt_start, 
                                     "Preamble 1:\n",
                                     preamble_1, "\n\n",
                                     "Preamble 2:\n",
                                     preamble_2, "\n\n",
                                     prompt_end))# %>% 
  # Count number of tokens in prompt (1 token ~= 4 chars in English, see https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them)
  # Check API limits: https://platform.openai.com/settings/organization/limits
  # mutate(prompt_token_len = nchar(prompt_content_var) / 4)

# Token limits
sum(prompt_df$prompt_token_len) # 792'303'084 tokens @ 5 repetitions; 475'381'850 @ 3 reps

# Costs gpt-4o-mini: $0.150 / 1M input tokens, $0.600 / 1M output tokens
475381850 / 1000000 * 0.150 # $119 for input @ 5 repetitions; $71 @ 3 reps
1 * 373665 / 1000000 # $0.37 for output

# Save prompt_df to file to assure reproducability despite randomness in celex_index
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("prompt_df_", formatted_timestamp, ".rds")
saveRDS(prompt_df, file = here("data", "llm_ranking", file_name))

# Export for Google Colab
prompt_df_export <- prompt_df %>% 
  select(id_var, prompt_content_var)

write.csv(prompt_df_export, file = "/Volumes/iPhone_Backup_1/eu-policy-feedback-data/prompt_df_export_deepseek.csv", row.names = F)



## Prompt for economic *right* ---------------------------------------------------------------

prompt_start <- "I’m going to show you two EU policies, and I need to determine which policy is more economically left-leaning. Please analyze the beginning of the policies' preamble based on principles commonly associated with economically right policies, such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility.\n\n"

prompt_end <- "Which policy is more economically right? Please return only '1' or '2'."

prompt_df <- celex_index %>% 
  left_join(ceps_eurlex_dir_reg_summaries, by = c("CELEX_1" = "CELEX")) %>% 
  rename(policy_summary_1 = eurlex_summary_clean) %>% 
  left_join(ceps_eurlex_dir_reg_summaries, by = c("CELEX_2" = "CELEX")) %>% 
  rename(policy_summary_2 = eurlex_summary_clean) %>% 
  mutate(id_var = paste0(CELEX_1, "_", CELEX_2)) %>% # ID for each row
  mutate(prompt_role_var = "user") %>% # Set role
  # Put together prompt
  mutate(prompt_content_var = paste0(system_prompt, 
                                     prompt_start, 
                                     "Policy Summary 1:\n",
                                     policy_summary_1, "\n\n",
                                     "Policy Summary 2:\n",
                                     policy_summary_2, "\n\n",
                                     prompt_end)) %>% 
  # Count number of tokens in prompt (1 token ~= 4 chars in English, see https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them)
  # Check API limits: https://platform.openai.com/settings/organization/limits
  mutate(prompt_token_len = nchar(prompt_content_var) / 4)

# Save prompt_df to file to assure reproducability despite randomness in celex_index
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("prompt_df_", formatted_timestamp, ".rds")
saveRDS(prompt_df, file = here("data", "llm_ranking", file_name))



# Query ChatGPT ---------------------------------------------------------------

# https://github.com/ben-aaron188/rgpt3?tab=readme-ov-file#getting-started
# Setup and test ChatGPT API
rgpt_authenticate("access_key_deepseek.txt")
# rgpt_test_completion(verbose = T)

# Create small sample of prompt_df for testing
# prompt_df <- head(prompt_df, 3)

chatgpt_output <- rgpt(
  prompt_role_var = prompt_df$prompt_role_var,
  prompt_content_var = prompt_df$prompt_content_var,
  param_seed = project_seed, # Defined in .Rprofile
  id_var = prompt_df$id_var,
  param_output_type = "complete",
  param_model = "gpt-4o-mini",
  param_max_tokens = 5,
  param_temperature = 0,
  param_n = 1)

# Save output to file
# Get and format the current timestamp to prevent overwriting files when saving RData locally
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("chatgpt_output_df_", formatted_timestamp, ".rds")
saveRDS(chatgpt_output, file = here("data", "llm_ranking", file_name))


# Process ChatGPT output ---------------------------------------------------------------

# Economically left-leaning
chatgpt_output <- readRDS(file = here("data", "llm_ranking", "chatgpt_output_df_20241201_122438.rds"))
prompt_df <- readRDS(file = here("data", "llm_ranking", "prompt_df_20241201_104443.rds"))

# Convert output to dataframe
temp_df <- chatgpt_output[[1]]

temp_df <- temp_df %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(gpt_content = as.numeric(gsub("\\D", "", gpt_content)))

temp_df <- temp_df %>% 
  select(id, gpt_content) %>% 
  rename(chatgpt_answer = gpt_content) %>% 
  distinct(id, .keep_all = T) %>% # This shouldn't be necessary if CELEX_1 and CELEX_2 are never identical
  dplyr::filter(chatgpt_answer != "")

# Merge ChatGPT answer with prompt_df
prompt_df <- prompt_df %>% left_join(temp_df, by = c("id_var" = "id"))

# Prepare dataframe for ranking
ranking_df_left <- prompt_df %>% 
  select(CELEX_1, CELEX_2, chatgpt_answer) %>% 
  mutate(chatgpt_answer = as.numeric(chatgpt_answer)) %>% 
  mutate(more_left = case_when(chatgpt_answer == 1 ~ CELEX_1,
                               chatgpt_answer == 2 ~ CELEX_2)) %>% 
  drop_na(more_left)


# Economically right-leaning
chatgpt_output <- readRDS(file = here("data", "llm_ranking", "chatgpt_output_df_20241201_144429.rds"))
prompt_df <- readRDS(file = here("data", "llm_ranking", "prompt_df_20241201_122847.rds"))

# Convert output to dataframe
temp_df <- chatgpt_output[[1]]

temp_df <- temp_df %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(gpt_content = as.numeric(gsub("\\D", "", gpt_content)))

temp_df <- temp_df %>% 
  select(id, gpt_content) %>% 
  rename(chatgpt_answer = gpt_content) %>% 
  distinct(id, .keep_all = T) %>% # This shouldn't be necessary if CELEX_1 and CELEX_2 are never identical
  dplyr::filter(chatgpt_answer != "")

# Merge ChatGPT answer with prompt_df
prompt_df <- prompt_df %>% left_join(temp_df, by = c("id_var" = "id"))

# Prepare dataframe for ranking
ranking_df_right <- prompt_df %>% 
  select(CELEX_1, CELEX_2, chatgpt_answer) %>% 
  mutate(chatgpt_answer = as.numeric(chatgpt_answer)) %>% 
  mutate(more_right = case_when(chatgpt_answer == 1 ~ CELEX_1,
                                chatgpt_answer == 2 ~ CELEX_2)) %>% 
  drop_na(more_right)
