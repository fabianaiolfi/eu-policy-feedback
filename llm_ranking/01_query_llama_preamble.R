
# Load Data ---------------------------------------------------------------

all_dir_reg <- readRDS(file = here("existing_measurements", "hix_hoyland_2024", "all_dir_reg_preamble.rds")) # Preamble
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

prompt_end <- "Which policy is more economically left? Please answer ONLY '1' or '2', NOTHING ELSE UNDER NO CIRCUMSTANCES."

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
                                     prompt_end))

# Save prompt_df to file to assure reproducability despite randomness in celex_index
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("prompt_df_llama_ranking_preamble_", formatted_timestamp, ".rds")
saveRDS(prompt_df, file = here("data", "llm_ranking", file_name))


## Prompt for economic *right* ---------------------------------------------------------------

prompt_start <- "I’m going to show you two EU policies, and I need to determine which policy is more economically left-leaning. Please analyze the beginning of the policies' preamble based on principles commonly associated with economically right policies, such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility.\n\n"

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

# Initialize the output file
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("llama_output_df_", formatted_timestamp, ".csv")
output_file <- paste0("/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/", file_name)

# Write the header of the CSV file (if the file doesn't exist)
if (!file.exists(output_file)) {
  write.csv(data.frame(CELEX = character(), GPT_Output = character()), 
            file = output_file, row.names = FALSE)
}

# Define the API URL
url <- 'http://localhost:11434/api/generate'

# Loop through query_df
for (i in 1:nrow(prompt_df)) {
  
  # Define the payload (data)
  data <- list(
    model = "llama3.2:1b",
    prompt = prompt_df$prompt_content_var[i],
    stream = F,
    options = list(
      seed = project_seed, # Reference project_seed directly without quotes
      num_predict = 1
    )
  )
  
  # Convert the data to JSON format
  json_data <- toJSON(data, auto_unbox = TRUE)
  
  # Make the POST request
  response <- POST(url, body = json_data)
  
  # Print the response content
  temp <- content(response, type = "application/json")
  llama_output <- temp$response
  
  # Create a temporary dataframe for the current result
  result_row <- data.frame(CELEX = prompt_df$id_var[i], Llama_Output = llama_output)
  
  # Append the result to the CSV file
  write.table(result_row, file = output_file, append = TRUE, 
              sep = ",", col.names = FALSE, row.names = FALSE)
  
  # Message to screen
  cat("Query", i, "of", nrow(prompt_df), "completed\n")
}


# Process Output ---------------------------------------------------------------

# Economically left-leaning
prompt_df <- readRDS(file = here("data", "llm_ranking", "llama_output_df_20241103_204609.rds"))

# Prepare dataframe for ranking
ranking_df_left <- prompt_df %>% 
  select(CELEX_1, CELEX_2, response) %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(response = as.numeric(gsub("\\D", "", response))) %>% 
  dplyr::filter(response <= 2) %>% #  Only keep responses '1' or '2'; Clean LLM output: Somewhat brute approach that could be optimised
  mutate(more_left = case_when(response == 1 ~ CELEX_1,
                               response == 2 ~ CELEX_2)) %>% 
  drop_na(response)

# Economically right-leaning
prompt_df <- readRDS(file = here("data", "llm_ranking", "llama_output_df_20241104_132306.rds"))

# Prepare dataframe for ranking
ranking_df_right <- prompt_df %>% 
  select(CELEX_1, CELEX_2, response) %>% 
  # remove any non-digit characters from string "response" and convert to numeric
  mutate(response = as.numeric(gsub("\\D", "", response))) %>% 
  dplyr::filter(response <= 2) %>% #  Only keep responses '1' or '2'; Clean LLM output: Somewhat brute approach that could be optimised
  mutate(more_right = case_when(response == 1 ~ CELEX_1,
                                response == 2 ~ CELEX_2)) %>%
  drop_na(response)
