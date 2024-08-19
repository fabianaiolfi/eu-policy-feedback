
# Scrape EURLEX Summaries --------------------------

# Define the folder path where the text files will be saved
# folder_path <- "data/data_collection/eurlex_summaries/" # Github Repo
folder_path <- "/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/eurlex_summaries/" # Dropbox


## Prepare Dataset --------------------------

# Load original dataset
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))

# Load directives and regulations subset
# ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))
# ceps_eurlex_dir_reg <- ceps_eurlex_dir_reg %>% select(CELEX)

# Load meta file
meta_dir_reg <- readRDS(here("data", "data_collection", "meta_dir_reg.rds"))

# Add EURLEX URL to directives and regulations subset
meta_dir_reg <- meta_dir_reg %>% 
  left_join(select(ceps_eurlex, CELEX, Eurlex_link), by = "CELEX") %>% 
  drop_na(CELEX) %>% 
  mutate(Eurlex_link = case_when(is.na(Eurlex_link) ~ paste0("https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:", CELEX),
                   T ~ Eurlex_link))

# Create summaries link 
meta_dir_reg_summaries <- meta_dir_reg %>% 
  # Replace `/ALL/` in string with `/LSU/`
  mutate(eurlex_link_summary = str_replace(Eurlex_link, "/ALL/", "/LSU/")) %>% 
  # Adjust link to explicitly detect redirects if summary is not available
  # If a summary is unavailable, the link will redirect. We can detect this during scraping and then simply ignore this link
  mutate(eurlex_link_summary = str_replace(eurlex_link_summary, "CELEX:", "CELEX%3A"))

# For testing purposes: Create sample of ceps_eurlex_dir_reg
# ceps_eurlex_dir_reg_summaries <- ceps_eurlex_dir_reg_summaries %>%
  # dplyr::filter(Date_document >= "2015-01-01") %>% 
  # Directives seem to be more likely to have summaries
  # dplyr::filter(Act_type == "Directive") %>%
  # slice_sample(n = 1000, replace = F)

# Remove already scraped CELEX IDs
scraped_240714 <- read_csv(file = "/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/eurlex_summaries/scraped_240714.csv")
scraped_240716 <- read_csv(file = "/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/eurlex_summaries/scraped_240716.csv")
scraped_240717 <- read_csv(file = "/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/eurlex_summaries/scraped_240717.csv")
scraped_240818 <- read_csv(file = "/Users/aiolf1/Library/CloudStorage/Dropbox/Work/240304 Qualtrics Giorgio/03 NLP Research/data_backup/eurlex_summaries/scraped_240818.csv")
already_scraped <- bind_rows(scraped_240714, scraped_240716, scraped_240717, scraped_240818)
rm(scraped_240714, scraped_240716, scraped_240717, scraped_240818)

meta_dir_reg_summaries <- meta_dir_reg_summaries %>% 
  # Remove CELEX IDs that have been already scraped
  anti_join(already_scraped, by = "CELEX")


# Scrape Summaries ----------------------------------------------------------------

# Setup main variables
all_links <- meta_dir_reg_summaries$eurlex_link_summary
user_agent_string <- "Fabian Aiolfi [fabian.aiolfi@gess.ethz.ch]" # User-Agent string with your name and email


## Save summaries to dataframe ----------------------------------------------------------------
# Great for scraping a few summaries

# Function to scrape text from a given URL
scrape_text <- function(url, user_agent_string) {
  response <- GET(url, user_agent(user_agent_string), followlocation = TRUE)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    final_url <- response$url
    # Check if the final URL is the same as the original URL
    # A different URL indicates that there is no summary available
    if (final_url != url) {
      message("Redirection detected. Skipping link: ", url)
      return(NA)
    }
    
    page <- read_html(content(response, as = "text"))
    text <- page %>% html_nodes(xpath = '//*[(@id = "text")]') %>% html_text()
    return(text)
  } else {
    return(NA)
  }
}

# Initialize a counter for progress tracking
counter <- 1

# Create a new column in the dataframe to store the scraped text
ceps_eurlex_dir_reg_summaries$eurlex_summary <- sapply(all_links, function(link) {
  eurlex_summary <- scrape_text(link, user_agent_string)
  message("Processed file ", counter, " of ", length(all_links), "\n")
  Sys.sleep(1) # Be polite and do not overload the server
  counter <<- counter + 1
  return(eurlex_summary)
})

saveRDS(ceps_eurlex_dir_reg_summaries, file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_xx.rds"))
# ceps_eurlex_dir_reg_summaries <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_xx.rds"))


## Save each summary directly as a text file ----------------------------------------------------------------
# Attempting to scrape many summaries

# Function to scrape text from a given URL and save it to a file
scrape_and_save_text <- function(url, user_agent_string) {
  response <- GET(url, user_agent(user_agent_string), followlocation = TRUE)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    final_url <- response$url
    # Check if the final URL is the same as the original URL
    # A different URL indicates that there is no summary available
    if (final_url != url) {
      message("Redirection detected. Skipping link: ", url)
      return(FALSE)
    }
    
    page <- read_html(content(response, as = "text"))
    text <- page %>% html_nodes(xpath = '//*[(@id = "text")]') %>% html_text()
    
    # Extract the file name from the URL
    file_name <- sub(".*CELEX%3A([0-9A-Z]+).*", "\\1", url)
    file_path <- paste0(folder_path, file_name, ".txt")
    
    # Save the text to a file
    writeLines(text, file_path)
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# Initialize a counter for progress tracking
counter <- 1

# Loop over all links and save the scraped text to files
# `invisible` prevents list of results to be printed to console after scraping finishes
invisible(lapply(all_links, function(link) {
  success <- scrape_and_save_text(link, user_agent_string)
  if (success) {
    message("Processed file ", counter, " of ", length(all_links), "\n")
  } else {
    message("Failed to process file ", counter, " of ", length(all_links), "\n")
  }
  Sys.sleep(0.5) # Be polite and do not overload the server
  counter <<- counter + 1
}))

# Document which CELEX IDs have already been checked
# 240714: First 653 files of ceps_eurlex_dir_reg_summaries
# 240716: First 10275 files of ceps_eurlex_dir_reg_summaries
# 240717: First 16463 files of ceps_eurlex_dir_reg_summaries
# 240817_1: First 73 files of meta_dir_reg_summaries
# 240818: …
scraped <- meta_dir_reg_summaries %>% 
  head(n = 45777) %>% # n = number of CELEX IDs checked
  select(CELEX)
write.csv(scraped, paste0(folder_path, "scraped_240818.csv"), row.names = FALSE)


# Load saved files as a dataframe ------------------------------

# Get the list of all text files in the folder
file_list <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

# Function to read a file and return its content along with the file name
read_file_content <- function(file_path) {
  file_content <- read_file(file_path)
  file_name <- basename(file_path)
  file_name <- sub("\\.txt$", "", file_name) # Remove the .txt extension
  return(data.frame(CELEX = file_name, eurlex_summary = file_content, stringsAsFactors = FALSE))
}

# Read all files and combine them into a dataframe
ceps_eurlex_dir_reg_summaries <- bind_rows(lapply(file_list, read_file_content))



# Clean Up Summaries ----------------------------------------------------------------

ceps_eurlex_dir_reg_summaries <- ceps_eurlex_dir_reg_summaries %>% 
  mutate(eurlex_summary = as.character(eurlex_summary)) %>% 
  # replace "NA" and "character(0)" string with NA
  mutate(eurlex_summary = ifelse(eurlex_summary == "NA", NA, eurlex_summary)) %>% 
  mutate(eurlex_summary = ifelse(eurlex_summary == "character(0)", NA, eurlex_summary)) %>%
  drop_na(eurlex_summary) %>% 
  mutate(eurlex_summary_clean = str_squish(eurlex_summary)) %>% # Remove excessive whitespace
  mutate(eurlex_summary_clean = str_replace_all(eurlex_summary_clean, "\n", " ")) %>% # Replace newline characters with space
  mutate(eurlex_summary_clean = str_replace_all(eurlex_summary_clean, "\\s{2,}", " ")) %>% # Replace multiple spaces with a single space
  mutate(eurlex_summary_clean = str_trim(eurlex_summary_clean)) %>% # Trim leading and trailing whitespace
  select(CELEX, eurlex_summary_clean)


# Save to file ----------------------------------------------------------------

saveRDS(ceps_eurlex_dir_reg_summaries, file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_xx.rds"))
