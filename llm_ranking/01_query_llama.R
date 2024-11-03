
# Load Data ---------------------------------------------------------------

# ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_240711_04.rds"))
ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "all_dir_reg_summaries.rds"))


# Indexing ---------------------------------------------------------------

# Create a dataframe that lists two different CELEX IDs per row
celex_index <- ceps_eurlex_dir_reg_summaries %>% 
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

prompt_start <- "I have two summaries of EU policies, and I need to determine which policy is more economically left-leaning. Please analyze the summaries based on principles commonly associated with economically left policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights.\n\n"
prompt_end <- "Which policy is more economically left? Please answer ONLY '1' or '2', NOTHING ELSE UNDER NO CIRCUMSTANCES."

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
                                     prompt_end))# %>% 
  # Count number of tokens in prompt (1 token ~= 4 chars in English, see https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them)
  # Check API limits: https://platform.openai.com/settings/organization/limits
  # mutate(prompt_token_len = nchar(prompt_content_var) / 4)

# Save prompt_df to file to assure reproducability despite randomness in celex_index
# timestamp <- Sys.time()
# formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
# file_name <- paste0("prompt_df_", formatted_timestamp, ".rds")
# saveRDS(prompt_df, file = here("data", "ranking", file_name))


## Prompt for economic *right* ---------------------------------------------------------------

prompt_start <- "I have two summaries of EU policies, and I need to determine which policy is more economically right-leaning. Please analyze the summaries based on principles commonly associated with economically right policies, such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility.\n\n"
prompt_end <- "Which policy is more economically right? Please answer ONLY USING THE NUMBERS '1' or '2', NOTHING ELSE UNDER NO CIRCUMSTANCES."

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
                                     prompt_end)) #%>%
#   # Count number of tokens in prompt (1 token ~= 4 chars in English, see https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them)
#   # Check API limits: https://platform.openai.com/settings/organization/limits
#   mutate(prompt_token_len = nchar(prompt_content_var) / 4)
# 
# # Save prompt_df to file to assure reproducability despite randomness in celex_index
# timestamp <- Sys.time()
# formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
# file_name <- paste0("prompt_df_", formatted_timestamp, ".rds")
# saveRDS(prompt_df, file = here("data", "ranking", file_name))



# Query llama --------------------------------

# Define the API URL
url <- 'http://localhost:11434/api/generate'

# Loop through query_df
for (i in 1:nrow(prompt_df)) {
  
  # Define the payload (data)
  data <- list(
    model = "llama3.2:1b",
    prompt = prompt_df$prompt_content_var[i],
    stream = F
    # options = list(
    #   seed = project_seed # Reference project_seed directly without quotes
    # )
  )
  
  # Convert the data to JSON format
  json_data <- toJSON(data, auto_unbox = TRUE)
  
  # Make the POST request
  response <- POST(url, body = json_data)
  
  # Print the response content
  temp <- content(response, type = "application/json")
  
  # Save the response to a dataframe with the prompt
  prompt_df$response[i] <- temp$response # column name not initialised
  
  # Message to screen
  cat("Query", i, "of", nrow(prompt_df), "completed\n")
}

# Save output to file
# Get and format the current timestamp to prevent overwriting files when saving RData locally
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("llama_output_df_", formatted_timestamp, ".rds")
saveRDS(prompt_df, file = here("data", "llm_ranking", file_name))


# Process Output ---------------------------------------------------------------

prompt_df <- readRDS(file = here("data", "llm_ranking", "llama_output_df_20241103_144501.rds"))

# prompt_df <- prompt_df %>% 
#   select(CELEX_1, CELEX_2, response) %>% 
#   # remove any non-digit characters from string "response" and convert to numeric
#   mutate(response = as.numeric(gsub("\\D", "", response)))

# Prepare dataframe for ranking
ranking_df <- prompt_df %>% 
  select(CELEX_1, CELEX_2, response) %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(response = as.numeric(gsub("\\D", "", response))) %>% 
  # mutate(chatgpt_answer = as.numeric(chatgpt_answer)) %>% 
  # Adjust accordingly
  # mutate(more_left = case_when(response == 1 ~ CELEX_1,
  #                              response == 2 ~ CELEX_2))
  mutate(more_right = case_when(response == 1 ~ CELEX_1,
                                response == 2 ~ CELEX_2)) %>% 
  drop_na(response)



# Process ChatGPT output ---------------------------------------------------------------

# chatgpt_output <- readRDS(file = here("data", "ranking", "chatgpt_output_df_20240712_143525.rds"))
# prompt_df <- readRDS(file = here("data", "ranking", "prompt_df_20240712_142655.rds"))
# 
# # Convert output to dataframe
# temp_df <- chatgpt_output[[1]]
# temp_df <- temp_df %>% 
#   select(id, gpt_content) %>% 
#   rename(chatgpt_answer = gpt_content) %>% 
#   distinct(id, .keep_all = T) # This shouldn't be necessary if CELEX_1 and CELEX_2 are never identical
# 
# # Merge ChatGPT answer with prompt_df
# prompt_df <- prompt_df %>% left_join(temp_df, by = c("id_var" = "id"))
# 
# # Prepare dataframe for ranking
# ranking_df <- prompt_df %>% 
#   select(CELEX_1, CELEX_2, chatgpt_answer) %>% 
#   mutate(chatgpt_answer = as.numeric(chatgpt_answer)) %>% 
#   # Adjust accordingly
#   # mutate(more_left = case_when(chatgpt_answer == 1 ~ CELEX_1,
#   #                              chatgpt_answer == 2 ~ CELEX_2))
#   mutate(more_right = case_when(chatgpt_answer == 1 ~ CELEX_1,
#                                chatgpt_answer == 2 ~ CELEX_2))
