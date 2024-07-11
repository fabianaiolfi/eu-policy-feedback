
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
ceps_eurlex_dir_reg <- ceps_eurlex_dir_reg %>% 
  # Replace `/ALL/` in string with `/LSU/`
  mutate(Eurlex_link_summary = str_replace(Eurlex_link, "/ALL/", "/LSU/"))

# For testing purposes: Create sample of ceps_eurlex_dir_reg
set.seed(5)
ceps_eurlex_dir_reg_sample <- ceps_eurlex_dir_reg %>%
  dplyr::filter(Date_document >= "2019-01-01") %>% 
  dplyr::filter(Act_type == "Directive") %>% 
  slice_sample(n = 10, replace = F)


# Scrape Summaries ----------------------------------------------------------------

library(rvest)
library(xml2)
library(httr)

# Assume ceps_eurlex_dir_reg_sample is already loaded
all_links <- ceps_eurlex_dir_reg_sample$Eurlex_link_summary

# User-Agent string with your name and email
user_agent_string <- "Fabian Aiolfi [fabian.aiolfi@gess.ethz.ch]"

# Function to scrape text from a given URL
scrape_text <- function(url, user_agent_string) {
  response <- GET(url, user_agent(user_agent_string))
  
  # Check if the request was successful
  if (status_code(response) == 200) {
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
ceps_eurlex_dir_reg_sample$eurlex_summary <- sapply(all_links, function(link) {
  eurlex_summary <- scrape_text(link, user_agent_string)
  cat("Processed file", counter, "of", length(all_links), "\n")
  Sys.sleep(2) # Be polite and do not overload the server
  counter <<- counter + 1
  return(eurlex_summary)
})



