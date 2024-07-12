
# Load Data ---------------------------------------------------------------

ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_240711_04.rds"))


# Indexing ---------------------------------------------------------------

# Create a dataframe that lists two different CELEX IDs per row
celex_index <- ceps_eurlex_dir_reg_summaries %>% 
  select(CELEX) %>% # Only select CELEX
  rename(CELEX_1 = CELEX)
celex_index <- bind_rows(replicate(3, celex_index, simplify = F)) # Repeat same row 3 times

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
prompt_start <- "I have two summaries of EU policies, and I need to determine which policy is more economically left-leaning. Please analyze the summaries based on principles commonly associated with economically left policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights.\n\n"
prompt_end <- "Which policy is more economically left? Please return only '1' or '2'."

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
  mutate(prompt_token_len = nchar(prompt_content_var) / 4)




# Query ChatGPT ---------------------------------------------------------------

# https://github.com/ben-aaron188/rgpt3?tab=readme-ov-file#getting-started
# Setup and test ChatGPT API
rgpt_authenticate("access_key.txt")
# rgpt_test_completion(verbose = T)

# Create small sample of prompt_df
prompt_df <- head(prompt_df, 3)

rgpt(
  prompt_role_var = prompt_df$prompt_role_var,
  prompt_content_var = prompt_df$prompt_content_var,
  …
)











