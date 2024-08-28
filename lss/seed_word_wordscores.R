
# Seed Words: Wordscores Approach -----------------------


## Load Data -----------------------

# Manifesto Data (https://manifesto-project.wzb.eu/datasets)
parties_MPDataset <- read.csv(file = here("lss", "parties_MPDataset_MPDS2024a.csv")) # Dataset
MPDataset_MPDS2024a <- read.csv(file = here("data", "lss", "MPDataset_MPDS2024a.csv")) # Parties

manifesto_stop_words <- scan(here("lss", "manifesto_stop_words.txt"), character(), quote = "")

# Documentation:
# https://manifesto-project.wzb.eu/information/documents/translation
# https://manifesto-project.wzb.eu/down/tutorials/firststepsmanifestoR.html#downloading-documents-from-the-manifesto-corpus

# Set API key
mp_setapikey("manifesto_apikey.txt")

english_translation <- mp_availability(TRUE) %>% 
  dplyr::filter(translation_en == TRUE | language == "english")

english_translation_manifesto_corpus <- mp_corpus_df(english_translation, translation = "en")

# Save / load dataset
saveRDS(english_translation_manifesto_corpus, file = here("lss", "english_translation_manifesto_corpus.rds"))
english_translation_manifesto_corpus <- readRDS(file = here("lss", "english_translation_manifesto_corpus.rds"))


## Create Manifesto Data Subset --------------------
# Only include manifestos from Western Europe between 1989 and 2024

# Add country to each row
english_translation_manifesto_corpus <- english_translation_manifesto_corpus %>% 
  left_join(select(parties_MPDataset, party, countryname), by = "party")

w_europe <- c("Sweden", "Norway", "Denmark", "Finland", "Belgium", "Netherlands",
               "Luxembourg", "France", "Italy", "Spain", "Greece", "Portugal",
               "Germany", "Austria", "Switzerland", "United Kingdom", "Ireland", "Cyprus")

# English manifesto texts
subset_manifesto_corpus <- english_translation_manifesto_corpus %>% 
  dplyr::filter(date > 198900) %>% 
  dplyr::filter(countryname %in% w_europe)

# Manifesto IDs and their scores
MPDataset_MPDS2024a_subset <- MPDataset_MPDS2024a %>% 
  dplyr::filter(date > 198900) %>% 
  mutate(manifesto_id = paste0(party, "_", date)) %>% 
  select(manifesto_id, rile, planeco, markeco, welfare)


## Create Corpus --------------------

# Concatenate texts
subset_manifesto_corpus <- subset_manifesto_corpus %>% 
  group_by(manifesto_id) %>% 
  summarise(text = str_c(text, collapse = " "))

subset_manifesto_corpus <- subset_manifesto_corpus %>% 
  left_join(MPDataset_MPDS2024a_subset, by = "manifesto_id")

# Convert to corpus object
subset_manifesto_corpus_obj <- corpus(subset_manifesto_corpus,
                                      docid_field = "manifesto_id",
                                      text_field = "text")


## Train Wordscores model -----------------------------
# Wordscores Guide/Documentation: https://tutorials.quanteda.io/machine-learning/wordscores/

# Use for-loop to create different ngram sizes (1 to 4)

# List of variables to process
variables <- c("rile", "planeco", "markeco", "welfare")

# Outer loop over variables
for (variable in variables) {
  
  # Inner loop over n-gram lengths
  for (i in 1:4) {
    
    # Clean and tokenize texts
    toks_manifesto <- subset_manifesto_corpus_obj %>% 
      tokens(remove_punct = TRUE,
             remove_symbols = TRUE, 
             remove_numbers = TRUE,
             remove_url = TRUE) %>% 
      tokens_remove(quanteda::stopwords("en", source = "marimo")) %>% 
      tokens_remove(manifesto_stop_words) %>%  # Remove corpus specific irrelevant words
      tokens_remove("\\b(?=\\w*[A-Za-z])(?=\\w*\\d)\\w+\\b", valuetype = "regex") %>% # Remove mixed letter-number tokens
      tokens_remove("\\b(?=.*\\d)(?=.*[[:punct:]])\\S+\\b", valuetype = "regex") %>% # Remove mixed letter-punctuation tokens
      tokens_remove(min_nchar = 3) # Remove tokens that are shorter than 3 characters
    
    # Set n-gram length
    toks_manifesto <- tokens_ngrams(toks_manifesto, n = i)
    
    # Create a document-feature matrix
    dfmat_manifesto <- dfm(toks_manifesto)
    
    # Limit the vocabulary to tokens with a minimum count of n occurrences
    dfmat_manifesto <- dfm_trim(dfmat_manifesto, min_termfreq = 50)
    
    # Apply Wordscores algorithm to document-feature matrix
    tmod_ws <- textmodel_wordscores(dfmat_manifesto, y = subset_manifesto_corpus[[variable]], smooth = 1)
    
    # Extract Wordscores
    wordscores_manifesto <- tmod_ws$wordscores
    wordscores_manifesto <- as.data.frame(wordscores_manifesto)
    wordscores_manifesto <- wordscores_manifesto %>% rownames_to_column(var = "token")
    
    # Create filename using both variable and n-gram length
    filename <- paste0("wordscores_manifesto_", variable, "_ngram_", i, ".rds")
    
    # Save to file
    saveRDS(wordscores_manifesto, file = here("lss", "wordscores_manifesto_datasets", filename))
    
    message("Completed ", variable, " with n-gram length ", i, " of 4")
  }
}


## Export head() and tail() of dataframes for report ----------------------

# Load all .rds files from wordscores_manifesto_datasets
rds_dir <- here("lss", "wordscores_manifesto_datasets")  # Specify the directory containing the .rds files
rds_files <- list.files(path = rds_dir, pattern = "\\.rds$", full.names = TRUE) # List all .rds files in the directory
all_wordscores_manifesto_datasets <- lapply(rds_files, readRDS) # Load all .rds files into a list

names(all_wordscores_manifesto_datasets) <- gsub("\\.rds$", "", basename(rds_files))

all_wordscores_manifesto_datasets <- lapply(all_wordscores_manifesto_datasets, function(df) {
  df %>%
    arrange(wordscores_manifesto)# Replace 'token' with the column name you want to sort by
})

# Define number of rows
nr_of_rows <- 20

# Loop over each dataframe in the list
for (name in names(all_wordscores_manifesto_datasets)) {
  
  # Extract the dataframe
  df <- all_wordscores_manifesto_datasets[[name]]
  
  # Get the head and tail of the dataframe
  df_head <- head(df, nr_of_rows)
  df_tail <- tail(df, nr_of_rows)
  
  # Define filenames for head and tail
  head_filename <- paste0(name, "_head.csv")
  tail_filename <- paste0(name, "_tail.csv")
  
  # Save head and tail as separate CSV files
  write.csv(df_head, file = here("lss", "wordscores_manifesto_seed_words", head_filename), row.names = FALSE)
  write.csv(df_tail, file = here("lss", "wordscores_manifesto_seed_words", tail_filename), row.names = FALSE)
  
  message("Saved head and tail for ", name)
}
