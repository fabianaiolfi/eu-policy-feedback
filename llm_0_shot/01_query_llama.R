
# Load Data ---------------------------------------------------------------

# all_dir_reg <- readRDS(file = here("data", "data_collection", "all_dir_reg_summaries.rds")) # Summaries
all_dir_reg <- readRDS(file = here("existing_measurements", "hix_hoyland_2024", "all_dir_reg_preamble.rds")) # Preamble

# Create sample for testing
# all_dir_reg <- all_dir_reg %>% slice_sample(n = 100) # 2min 28sec -> 150 / 100 * 75567 / 60 / 60 -> 31h for all
# all_dir_reg <- all_dir_reg %>% slice_sample(n = 200) # 6min 35sec 
# all_dir_reg <- all_dir_reg %>% slice_sample(n = 30) # 150 with token len 1: 4min 49sec | 2min 17s -> 19h

# Create sample due to time constraints: This should take about 10h
all_dir_reg <- all_dir_reg %>% slice_sample(n = 36000)


# Pre-process data -----------------------------------------------------------

# all_dir_reg <- all_dir_reg %>%
#   # head(5) %>% # Subset for testing
#   uncount(5) # Repeat rows
# 
# # Shuffle rows
# all_dir_reg <- slice(all_dir_reg, sample(1:n()))


# Create Prompt Dataframe ---------------------------------------------------------------

system_prompt <- "You are an expert in European Union policies. Answer questions and provide information based on that expertise.\n\n"


## Create Prompt ---------------------------------------------------------------

# prompt_summary <- "I’m going to show you a summary of an EU policy. Please score the policy on a scale of 0 to 100. A score of 0 represents economic left-wing policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. A score of 100 represents economic right-wing policies such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. Please only return the score. Here’s the summary:\n\n"
prompt_preamble <- "I’m going to show you the beginning of a preamble of an EU policy. Please score the policy on a scale of 0 to 100. 0 represents economic left-wing policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. 100 represents economic right-wing policies such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. Please only return the score. Here’s the preamble:\n\n"


prompt_df <- all_dir_reg %>% 
  mutate(prompt_role_var = "user") %>% # Set role
  # Put together prompt
  mutate(prompt_content_var = paste0(system_prompt, 
                                     # Summary -----
                                     # prompt_summary,
                                     # eurlex_summary_clean
                                     # Preamble -----
                                     prompt_preamble,
                                     preamble
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

# Load Llama output
prompt_df <- readRDS(file = here("data", "llm_0_shot", "llama_output_df_20241231_054228.rds"))

prompt_clean_df <- prompt_df %>% 
  select(-preamble, -prompt_role_var, -prompt_content_var) %>% 
  # Check for non-numeric output
  mutate(numeric = str_detect(response, "^\\s*\\d+\\s*$")) %>%
  dplyr::filter(numeric == T) %>%
  select(-numeric) %>% 
  mutate(response = as.numeric(response)) %>% 
  dplyr::filter(response <= 100) %>%
  drop_na(CELEX)

# Save output
saveRDS(prompt_clean_df, file = here("data", "llm_0_shot", "llama_preamble_0_shot.rds"))
