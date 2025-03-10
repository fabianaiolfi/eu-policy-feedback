
# Load Data ---------------------------------------------------------------

# ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_240711_04.rds")) # Sample of 24 summaries
ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "all_dir_reg_summaries.rds"))


# Indexing ---------------------------------------------------------------

# Create a dataframe that lists two different CELEX IDs per row
celex_index <- ceps_eurlex_dir_reg_summaries %>% 
  select(CELEX) %>% # Only select CELEX
  rename(CELEX_1 = CELEX)
celex_index <- bind_rows(replicate(5, celex_index, simplify = F)) # Repeat same row 3 times

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

prompt_start <- "I have two summaries of EU policies, and I need to determine which policy is more economically left-leaning. Please analyze the summaries based on principles commonly associated with economically left policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights.\n\n"
prompt_end <- "Which policy is more economically left? Please return only '1' or '2'."

## Prompt for social *left* ---------------------------------------------------------------

prompt_start <- "I have two summaries of EU policies, and I need to determine which policy is more socially progressive. Please analyze the summaries based on principles commonly associated with socially progressive policies, such as support for LGBTQ+ rights, gender equality, racial justice, reproductive rights, inclusive social policies, expansive immigration policies, criminal justice reform, environmental justice, secularism in governance, and multiculturalism.\n\n"
prompt_end <- "Which policy is more socially left? Please return only '1' or '2'."

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

# Token limits
sum(prompt_df$prompt_token_len) # 26'044'801 tokens

# Costs gpt-4o-mini: $0.150 / 1M input tokens, $0.600 / 1M output tokens
26044801 / 1000000 * 0.150 # $3.90 for input
1 * 8185 / 1000000 # $0.008 for output

# Export for Google Colab
prompt_df_export <- prompt_df %>% 
  select(id_var, prompt_content_var)

write.csv(prompt_df_export, here("data", "llm_ranking", "prompt_df_ranking_export_social_left_summaries.csv"), row.names = F)

# Save prompt_df to file to assure reproducability despite randomness in celex_index
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("prompt_df_", formatted_timestamp, ".rds")
saveRDS(prompt_df, file = here("data", "llm_ranking", file_name))


## Prompt for economic *right* ---------------------------------------------------------------

prompt_start <- "I have two summaries of EU policies, and I need to determine which policy is more economically right-leaning. Please analyze the summaries based on principles commonly associated with economically right policies, such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility.\n\n"
prompt_end <- "Which policy is more economically right? Please return only '1' or '2'."


## Prompt for social *right* ---------------------------------------------------------------

prompt_start <- "I have two summaries of EU policies, and I need to determine which policy is more socially conservative. Please analyze the summaries based on principles commonly associated with socially conservative policies, such as emphasis on traditional family values, opposition to same-sex marriage, restrictions on reproductive rights, stricter immigration controls, prioritization of national identity, opposition to multiculturalism, support for tough-on-crime policies, environmental skepticism, and the promotion of religion in public life.\n\n"
prompt_end <- "Which policy is more socially right? Please return only '1' or '2'."

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

# Export for Google Colab
prompt_df_export <- prompt_df %>% 
  select(id_var, prompt_content_var)

write.csv(prompt_df_export, here("data", "llm_ranking", "prompt_df_ranking_export_social_right_summaries.csv"), row.names = F)

# Save prompt_df to file to assure reproducability despite randomness in celex_index
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("prompt_df_", formatted_timestamp, ".rds")
saveRDS(prompt_df, file = here("data", "llm_ranking", file_name))



# Query ChatGPT ---------------------------------------------------------------

# https://github.com/ben-aaron188/rgpt3?tab=readme-ov-file#getting-started
# Setup and test ChatGPT API
rgpt_authenticate("access_key.txt")
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



# Process Deepseek Output ---------------------------------------------------------------

# Economically left-leaning
deepseek_output <- read.csv(file = here("data", "llm_ranking", "deepseek_output_0_shot_left_summaries.csv"))

ranking_df_left <- deepseek_output %>% 
  separate(id_var, into = c("CELEX_1", "CELEX_2"), sep = "_") %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(output = as.numeric(gsub("\\D", "", output))) %>% 
  dplyr::filter(output <= 2) %>% #  Only keep responses '1' or '2'; Clean LLM output: Somewhat brute approach that could be optimised
  mutate(more_left = case_when(output == 1 ~ CELEX_1,
                               output == 2 ~ CELEX_2)) %>% 
  drop_na(output)

# Socially left-leaning
deepseek_output <- read.csv(file = here("data", "llm_ranking", "deepseek_output_ranking_social_left_summaries.csv"))

ranking_df_left <- deepseek_output %>% 
  separate(id_var, into = c("CELEX_1", "CELEX_2"), sep = "_") %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(output = as.numeric(gsub("\\D", "", output))) %>% 
  dplyr::filter(output <= 2) %>% #  Only keep responses '1' or '2'; Clean LLM output: Somewhat brute approach that could be optimised
  mutate(more_left = case_when(output == 1 ~ CELEX_1,
                               output == 2 ~ CELEX_2)) %>% 
  drop_na(output)

# Economically right-leaning
deepseek_output <- read.csv(file = here("data", "llm_ranking", "deepseek_output_0_shot_right_summaries.csv"))

ranking_df_right <- deepseek_output %>% 
  separate(id_var, into = c("CELEX_1", "CELEX_2"), sep = "_") %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(output = as.numeric(gsub("\\D", "", output))) %>% 
  dplyr::filter(output <= 2) %>% #  Only keep responses '1' or '2'; Clean LLM output: Somewhat brute approach that could be optimised
  mutate(more_right = case_when(output == 1 ~ CELEX_1,
                               output == 2 ~ CELEX_2)) %>% 
  drop_na(output)

# Socially right-leaning
deepseek_output <- read.csv(file = here("data", "llm_ranking", "deepseek_output_ranking_social_right_summaries.csv"))

ranking_df_right <- deepseek_output %>% 
  separate(id_var, into = c("CELEX_1", "CELEX_2"), sep = "_") %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(output = as.numeric(gsub("\\D", "", output))) %>% 
  dplyr::filter(output <= 2) %>% #  Only keep responses '1' or '2'; Clean LLM output: Somewhat brute approach that could be optimised
  mutate(more_right = case_when(output == 1 ~ CELEX_1,
                               output == 2 ~ CELEX_2)) %>% 
  drop_na(output)

