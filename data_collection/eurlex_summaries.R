
# Scrape EURLEX Summaries --------------------------


## Prepare Dataset --------------------------

# Load original dataset
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))

# Load directives and regulations subset
ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))
ceps_eurlex_dir_reg <- ceps_eurlex_dir_reg %>% select(CELEX)

# Add EURLEX URL to directives and regulations subset
ceps_eurlex_dir_reg <- ceps_eurlex_dir_reg %>% 
  left_join(select(ceps_eurlex, CELEX, Date_document, Act_type, Eurlex_link), by = "CELEX")

# Create summaries link 
ceps_eurlex_dir_reg_summaries <- ceps_eurlex_dir_reg %>% 
  # Replace `/ALL/` in string with `/LSU/`
  mutate(eurlex_link_summary = str_replace(Eurlex_link, "/ALL/", "/LSU/")) %>% 
  # Adjust link to explicitly detect redirects if summary is not available
  mutate(eurlex_link_summary = str_replace(eurlex_link_summary, "CELEX:", "CELEX%3A"))

# For testing purposes: Create sample of ceps_eurlex_dir_reg
ceps_eurlex_dir_reg_summaries <- ceps_eurlex_dir_reg_summaries %>%
  dplyr::filter(Date_document >= "2019-01-01") %>% 
  dplyr::filter(Act_type == "Directive") %>% 
  slice_sample(n = 10, replace = F)


# Scrape Summaries ----------------------------------------------------------------

all_links <- ceps_eurlex_dir_reg_summaries$eurlex_link_summary

# User-Agent string with your name and email
user_agent_string <- "Fabian Aiolfi [fabian.aiolfi@gess.ethz.ch]"

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
  Sys.sleep(3) # Be polite and do not overload the server
  counter <<- counter + 1
  return(eurlex_summary)
})


# Clean Up Summaries ----------------------------------------------------------------

ceps_eurlex_dir_reg_summaries <- ceps_eurlex_dir_reg_summaries %>% 
  mutate(eurlex_summary_clean = str_squish(eurlex_summary)) %>% # Remove excessive whitespace
  mutate(eurlex_summary_clean = str_replace_all(eurlex_summary_clean, "\n", " ")) %>% # Replace newline characters with space
  mutate(eurlex_summary_clean = str_replace_all(eurlex_summary_clean, "\\s{2,}", " ")) %>% # Replace multiple spaces with a single space
  mutate(eurlex_summary_clean = str_trim(eurlex_summary_clean)) %>% # Trim leading and trailing whitespace
  select(CELEX, eurlex_summary_clean)


# Save to file ----------------------------------------------------------------

# saveRDS(ceps_eurlex_dir_reg_summaries, file = here("data", "data_collection", "ceps_eurlex_dir_reg_summaries_240711.rds"))
