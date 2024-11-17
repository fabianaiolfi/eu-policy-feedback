
# Load Data ---------------------------------------------------------------

all_dir_reg <- readRDS(file = here("data", "data_collection", "all_dir_reg_summaries.rds")) # Summaries
# all_dir_reg <- readRDS(file = here("existing_measurements", "hix_hoyland_2024", "all_dir_reg_preamble.rds")) # Preamble


# Pre-process data -----------------------------------------------------------

all_dir_reg <- all_dir_reg %>%
  # head(5) %>% # Subset for testing
  uncount(5) # Repeat rows

# Shuffle rows
all_dir_reg <- slice(all_dir_reg, sample(1:n()))


# Create Prompt Dataframe ---------------------------------------------------------------

system_prompt <- "You are an expert in European Union policies. Answer questions and provide information based on that expertise.\n\n"


## Create Prompt ---------------------------------------------------------------

prompt_summary <- "I’m going to show you a summary of an EU policy. Please score the policy on a scale of 0 to 100. A score of 0 represents economic left-wing policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. A score of 100 represents economic right-wing policies such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. Please only return the score. Here’s the summary:\n\n"
# prompt_preamble <- "I’m going to show you the beginning of a preamble of an EU policy. Please score the policy on a scale of 0 to 100. 0 represents economic left-wing policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. 100 represents economic right-wing policies such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. Please only return the score. Here’s the preamble:\n\n"

prompt_df <- all_dir_reg %>% 
  mutate(prompt_role_var = "user") %>% # Set role
  # Put together prompt
  mutate(prompt_content_var = paste0(system_prompt, 
                                     # Summary -----
                                     prompt_summary,
                                     eurlex_summary_clean
                                     # Preamble -----
                                     # prompt_preamble,
                                     # preamble 
                                     ))# %>% 
  # Count number of tokens in prompt (1 token ~= 4 chars in English, see https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them)
  # Check API limits: https://platform.openai.com/settings/organization/limits
  # mutate(prompt_token_len = nchar(prompt_content_var) / 4)

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
saveRDS(prompt_df, file = here("data", "llm_0_shot", file_name))


# Process Llama output ---------------------------------------------------------------

prompt_df <- readRDS(file = here("data", "llm_0_shot", "llama_output_df_20241117_193847.rds"))

unique(prompt_df$response)




# # Process ChatGPT output ---------------------------------------------------------------
# 
# # chatgpt_output <- readRDS(file = here("data", "ranking", "chatgpt_output_df_20240712_143525.rds"))
# # prompt_df <- readRDS(file = here("data", "ranking", "prompt_df_20240712_142655.rds"))
# 
# # Convert output to dataframe
# temp_df <- chatgpt_output[[1]]
# temp_df <- temp_df %>% 
#   select(id, gpt_content) %>% 
#   rename(chatgpt_answer = gpt_content) %>% 
#   distinct(id, .keep_all = T) # This shouldn't be necessary if CELEX_1 and CELEX_2 are never identical
# 
# # Merge ChatGPT answer with prompt_df
# prompt_df <- prompt_df %>% left_join(temp_df, by = c("CELEX" = "id"))
# 
# # Clean up ChatGPT answers
# unique(prompt_df$chatgpt_answer) # Examine the output
# 
# prompt_df <- prompt_df %>% 
#   # Remove any non-numeric characters from answer
#   mutate(chatgpt_answer = str_extract(chatgpt_answer, "[0-9]+")) %>% 
#   mutate(chatgpt_answer = as.numeric(chatgpt_answer))
# 
# # Save output
# chatgpt_preamble_0_shot <- prompt_df %>% select(CELEX, chatgpt_answer)
# saveRDS(chatgpt_preamble_0_shot, file = here("data", "chatgpt_0_shot", "chatgpt_preamble_0_shot.rds"))
