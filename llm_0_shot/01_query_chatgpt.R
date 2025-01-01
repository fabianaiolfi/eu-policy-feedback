
# Load Data ---------------------------------------------------------------

# all_dir_reg <- readRDS(file = here("data", "data_collection", "all_dir_reg_summaries.rds")) # Summaries
all_dir_reg <- readRDS(file = here("existing_measurements", "hix_hoyland_2024", "all_dir_reg_preamble.rds")) # Preamble
all_dir_reg <- all_dir_reg %>% drop_na(CELEX)

# Create Subsets -----------------------------------------------------------

# Subset: 
all_dir_reg <- all_dir_reg %>% tail(nrow(all_dir_reg) - 1250) # Remove policies done in chatgpt_output_20241231_170956.csv

# Subset of directives and regulations that have summaires (n = 1637)
# all_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "all_dir_reg_summaries.rds"))
# all_dir_reg <- all_dir_reg_summaries %>% 
#   select(CELEX) %>% 
#   left_join(all_dir_reg, by = "CELEX")


# Create Prompt Dataframe ---------------------------------------------------------------

system_prompt <- "You are an expert in European Union policies. Answer questions and provide information based on that expertise.\n\n"


## Create Prompt ---------------------------------------------------------------

# prompt_summary <- "I’m going to show you a summary of an EU policy. Please score the policy on a scale of 0 to 100. 0 represents economic left-wing policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. 100 represents economic right-wing policies such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. Please only return the score. Here’s the summary:\n\n"
prompt_preamble <- "I’m going to show you the beginning of a preamble of an EU policy. Please score the policy on a scale of 0 to 100. 0 represents economic left-wing policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. 100 represents economic right-wing policies such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. Please *only* return the score and absolutely nothing else. Here’s the preamble:\n\n"

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


# Query ChatGPT ---------------------------------------------------------------

# https://github.com/ben-aaron188/rgpt3?tab=readme-ov-file#getting-started
rgpt_authenticate("access_key.txt")

# Initialize the output file
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("chatgpt_output_", formatted_timestamp, ".csv")
output_file <- paste0("/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/", file_name)

# Write the header of the CSV file (if the file doesn't exist)
if (!file.exists(output_file)) {
  write.csv(data.frame(CELEX = character(), GPT_Output = character()), 
            file = output_file, row.names = FALSE)
}

# Loop through each row in prompt_df
for (i in seq_len(nrow(prompt_df))) {
  # Start with a flag to track if the row was processed successfully
  success <- FALSE
  
  # Attempt to process the row
  while (!success) {
    # Query the API
    chatgpt_output <- try(
      rgpt(
        prompt_role_var = prompt_df$prompt_role_var[i],
        prompt_content_var = prompt_df$prompt_content_var[i],
        param_seed = project_seed, 
        id_var = prompt_df$CELEX[i],
        param_output_type = "complete",
        param_model = "gpt-4o-mini",
        param_max_tokens = 1, 
        param_temperature = 0,
        param_n = 1
      ), silent = TRUE
    )
    
    # Check if the API call succeeded
    if (inherits(chatgpt_output, "try-error")) {
      message(sprintf("Error querying API for row %d: %s", 
                      i, as.character(chatgpt_output)))
      success <- TRUE # Skip this row and continue
    } else {
      # Extract the response safely
      temp_df <- try(chatgpt_output[[1]], silent = TRUE)
      
      if (inherits(temp_df, "try-error") || is.null(temp_df$gpt_content) || length(temp_df$gpt_content) == 0) {
        message(sprintf("Invalid response for row %d. Skipping.", i))
        success <- TRUE # Skip this row and continue
      } else {
        # Write the valid result to the output file
        result_row <- data.frame(CELEX = prompt_df$CELEX[i], GPT_Output = temp_df$gpt_content)
        write.table(result_row, file = output_file, append = TRUE, 
                    sep = ",", col.names = FALSE, row.names = FALSE)
        success <- TRUE
      }
    }
  }
  message(i, " of ", nrow(prompt_df))
}


# Process ChatGPT output ---------------------------------------------------------------

# chatgpt_output <- readRDS(file = here("data", "ranking", "chatgpt_output_df_20240712_143525.rds"))
# prompt_df <- readRDS(file = here("data", "ranking", "prompt_df_20240712_142655.rds"))

# Convert output to dataframe
# temp_df <- chatgpt_output[[1]]
# temp_df <- temp_df %>% 
#   select(id, gpt_content) %>% 
#   rename(chatgpt_answer = gpt_content) %>% 
#   distinct(id, .keep_all = T) # This shouldn't be necessary if CELEX_1 and CELEX_2 are never identical


# Merge ChatGPT answer with prompt_df
# prompt_df <- prompt_df %>% left_join(temp_df, by = c("CELEX" = "id"))

chatgpt_output_1 <- read.csv(here("data", "llm_0_shot", "chatgpt_output_20241231_170956.csv"))
chatgpt_output_2 <- read.csv(here("data", "llm_0_shot", "chatgpt_output_20241231_183631.csv"))

chatgpt_output <- rbind(chatgpt_output_1, chatgpt_output_2)

# Clean up ChatGPT answers
unique(chatgpt_output$GPT_Output) # Examine the output

# prompt_df <- prompt_df %>% 
#   # Remove any non-numeric characters from answer
#   mutate(chatgpt_answer = str_extract(chatgpt_answer, "[0-9]+")) %>% 
#   mutate(chatgpt_answer = as.numeric(chatgpt_answer))

# Save output
# chatgpt_preamble_0_shot <- prompt_df %>% select(CELEX, chatgpt_answer)
saveRDS(chatgpt_output, file = here("data", "llm_0_shot", "chatgpt_preamble_0_shot.rds"))
