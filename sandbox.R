
ceps_eurlex$act_raw_text[33]
ceps_eurlex$CELEX[33]

ceps_eurlex$act_raw_text[335]
ceps_eurlex$EUROVOC[335]
ceps_eurlex$Subject_matter[335]


table(ceps_eurlex$Act_type)
act_types <- ceps_eurlex %>% count(Act_type) %>% arrange(-n)

table(ceps_eurlex_dir_reg$Act_type)
act_types <- ceps_eurlex_dir_reg %>% count(Act_type) %>% arrange(-n)


regulations <- ceps_eurlex %>% 
  dplyr::filter(Act_type == "Regulation") %>% 
  # distinct(Date_document) %>% 
  # sort by date descending
  arrange(desc(Date_document))

head(regulations$Date_document)


# scrape summaries

# Load RDS
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))


# Create subset of directives and regulations --------------------------

ceps_eurlex_dir_reg <- ceps_eurlex %>% 
  mutate(Date_document = as.Date(Date_document, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_document >= "1989-01-01") %>%
  dplyr::filter(str_detect(Act_type, "Regulation|Directive")) %>%
  # select(CELEX, act_raw_text, Act_type) %>%
  # Remove rows where act_raw_text is the string "nan"
  dplyr::filter(act_raw_text != "nan")

colnames(ceps_eurlex_dir_reg)

df_scrape <- ceps_eurlex_dir_reg %>% 
  select(CELEX, Date_document, Act_type, Eurlex_link, Oeil_link)# %>% 
  # dplyr::filter(Oeil_link != "")

table(df_scrape$Act_type)
min(df_scrape$Date_document)
max(df_scrape$Date_document)


# search for "_" in column
ceps_eurlex %>% 
  dplyr::filter(str_detect(CELEX, "_")) %>% 
  select(CELEX)

# get original index in 01_query_llm
recreate_df <- prompt_df %>% 
  select(id_var) %>% 
  separate(id_var, c("CELEX_1", "CELEX_2"), sep = "_")
celex_index <- recreate_df


### evaluate ranking

# Define the two lists
list1 <- c("A", "B", "C")
list2 <- c("A", "C", "B")

# Function to calculate the difference metric
calculate_difference <- function(list1, list2) {
  n <- length(list1)
  total_difference <- 0
  
  for (i in 1:n) {
    element <- list1[i]
    position_in_list2 <- match(element, list2)
    total_difference <- total_difference + abs(i - position_in_list2)
  }
  
  return(total_difference)
}

# Calculate the difference between the two lists
difference <- calculate_difference(list1, list2)







round(log(0 + 0.5) - log(4 + 0.5), 2) # …88
round(log(4 + 0.5) - log(22 + 0.5), 2) # …23
round(log(6 + 0.5) - log(1 + 0.5), 2) # …95

df

(0.00794 * 200) - 0.49603



###############

# eurlex: Retrieve Data on European Union Law 
# https://michalovadek.github.io/eurlex/

install.packages("eurlex")

# load library
library(eurlex)

# create query
query <- elx_make_query("directive", include_original_language = TRUE)

# execute query
results <- elx_run_query(query)

examples_paper
services_elx <- elx_fetch_data(url = "http://publications.europa.eu/resource/celex/32011L0095", type = "text")
services_elx <- as.data.frame(services_elx)

# # Function to clean text using quanteda
# clean_text_quanteda <- function(text) {
#   text %>%
#     str_replace_all("\n", " ") %>%  # replace "\n" with " "
#     str_replace_all("\\s{2,}", " ") %>%  # remove double and triple whitespaces
#     tolower() %>%  # convert to lowercase
#     str_replace_all(",(?=[^\\s])", ", ") %>%  # add a whitespace after a comma if the comma is followed by a non-whitespace character
#     tokens() %>%  # tokenize the text
#     # tokens_remove(pattern = "\\d+", valuetype = "regex") %>%  # remove all numbers
#     # tokens_remove(pattern = "\\([^\\)]*\\)", valuetype = "regex") %>%  # remove all brackets ( )
#     # tokens_remove(pattern = "//.*?//", valuetype = "regex") %>%  # remove all double slashes
#     as.character() %>%  # convert tokens back to character
#     paste(collapse = " ")  # collapse tokens into a single string
# }
# 
# # Apply the function using dplyr and quanteda
# services_elx <- services_elx %>%
#   mutate(services_elx_clean = sapply(services_elx, clean_text_quanteda)) %>% 
#   mutate(services_elx_clean = str_extract(services_elx_clean, "(?i).*?(?=Adopted this directive|Adopted this regulation)"))

# services_elx$services_elx_clean

# BEST RESULT SO FAR
# services_elx <- services_elx %>%
#   # Experiment with different text manipulations in order to get same results as Hix Hoyland
#   mutate(services_elx = str_replace_all(services_elx, "\n", " ")) %>% # replace "\n" with " "
#   mutate(services_elx = str_replace_all(services_elx, "\\s{2,}", " ")) %>% # remove double and triple whitespaces
#   mutate(services_elx = tolower(services_elx)) %>%
#   # add a whitespace after a comma if the comma is followed by a non-whitespace character
#   mutate(services_elx = str_replace_all(services_elx, ",(?=[^\\s])", ", ")) %>%
#   # remove all numbers
#   mutate(services_elx = str_remove_all(services_elx, "\\d+")) %>%
#   # remove all brackets ( )
#   mutate(services_elx = str_remove_all(services_elx, "\\(.*?\\)")) %>%
#   # remove all double slashes //
#   mutate(services_elx = str_remove_all(services_elx, "//.*?//")) %>%
#   mutate(services_elx = str_extract(services_elx, "(?i).*?(?=Adopted this directive|Adopted this regulation)"))

services_elx <- services_elx %>%
  mutate(services_elx = str_extract(services_elx, "(?is).*?(?=Adopted this directive|Adopted this regulation)")) %>% 
  # Experiment with different text manipulations in order to get same results as Hix Hoyland
  mutate(services_elx = str_replace_all(services_elx, "\n", " ")) %>% # replace "\n" with " "
  mutate(services_elx = str_replace_all(services_elx, "\\s{2,}", " ")) %>% # remove double and triple whitespaces
  mutate(services_elx = tolower(services_elx)) %>%
  # add a whitespace after a comma if the comma is followed by a non-whitespace character
  mutate(services_elx = str_replace_all(services_elx, ",(?=[^\\s])", ", ")) %>%
  # remove all numbers
  mutate(services_elx = str_remove_all(services_elx, "\\d+")) %>%
  # remove all brackets ( )
  # mutate(services_elx = str_remove_all(services_elx, "\\(")) %>%
  # mutate(services_elx = str_remove_all(services_elx, "\\)")) %>%
  mutate(services_elx = str_remove_all(services_elx, "\\(.*?\\)")) %>%
  # remove all double slashes //
  # mutate(services_elx = str_remove_all(services_elx, "//"))
  mutate(services_elx = str_remove_all(services_elx, "//.*?//"))
  
  
# remove stopwords: doesnt make results better
# install.packages("stopwords")
# library("stopwords")
# stopwords_en <- stopwords::stopwords("english")
# # Function to remove stopwords from a string
# remove_stopwords <- function(text, stopwords) {
#   words <- unlist(str_split(text, "\\s+"))  # Split the text into words
#   filtered_words <- words[!tolower(words) %in% stopwords]  # Remove stopwords
#   cleaned_text <- paste(filtered_words, collapse = " ")  # Rejoin the words into a string
#   return(cleaned_text)
# }
# # Apply the function using dplyr
# services_elx <- services_elx %>%
#   mutate(services_elx = sapply(services_elx, remove_stopwords, stopwords = stopwords_en))


# split string into segments of 100 words
split_into_segments <- function(text, segment_size = 100) {
  words <- unlist(str_split(text, "\\s+"))
  segments <- split(words, ceiling(seq_along(words) / segment_size))
  sapply(segments, paste, collapse = " ")
}

# perform split of preamble segments
services_elx <- services_elx %>%
  mutate(preamble_segment = map(services_elx, split_into_segments)) %>%
  unnest_longer(preamble_segment) %>% 
  select(-services_elx)

# classify
services_elx <- services_elx %>%
  # mutate(ManiBERT_label = map_chr(preamble_segment, ~ ManiBERT_classifier(.x)[[1]]$label))
  mutate(RoBERT_label = map_chr(preamble_segment, ~ RoBERT_classifier(.x)[[1]]$label))

table(services_elx$RoBERT_label)
# log(right + 0.5) - log(left + 0.5)
round(log(0 + 0.5) - log(4 + 0.5), 2) # 32003L0088 -2.71 | -2.56 | -1.95
round(log(4 + 0.5) - log(25 + 0.5), 2) # 32006L0123 -0.71 | -1.1 | -1.73
round(log(3 + 0.5) - log(1 + 0.5), 2) # 32011L0095               |  1.1







ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))




