
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

# Manifesto IDs and their RILE score
MPDataset_MPDS2024a_subset <- MPDataset_MPDS2024a %>% 
  dplyr::filter(date > 198900) %>% 
  mutate(manifesto_id = paste0(party, "_", date)) %>% 
  select(manifesto_id, rile)


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
  
  # Set ngram length
  toks_manifesto <- tokens_ngrams(toks_manifesto, n = i)
  
  # create a document-feature matrix
  dfmat_manifesto <- dfm(toks_manifesto)
  
  # Limit the vocabulary to tokens with a minimum count of n occurrences
  dfmat_manifesto <- dfm_trim(dfmat_manifesto, min_termfreq = 50)
  
  # apply Wordscores algorithm to document-feature matrix
  tmod_ws <- textmodel_wordscores(dfmat_manifesto, y = subset_manifesto_corpus$rile , smooth = 1)
  
  # Extract Wordscores
  wordscores_manifesto <- tmod_ws$wordscores
  wordscores_manifesto <- as.data.frame(wordscores_manifesto)
  wordscores_manifesto <- wordscores_manifesto %>% rownames_to_column(var = "token")
  
  filename <- paste0("wordscores_manifesto_ngram_", i, ".rds")
  
  # Save to file
  saveRDS(wordscores_manifesto, file = here("lss", filename))
  
  message("Completed ", i, " of 4")
  
  }

# Load all ngram sizes
wordscores_manifesto_ngram_1 <- readRDS(file = here("lss", "wordscores_manifesto_ngram_1.rds"))
wordscores_manifesto_ngram_2 <- readRDS(file = here("lss", "wordscores_manifesto_ngram_2.rds"))
wordscores_manifesto_ngram_3 <- readRDS(file = here("lss", "wordscores_manifesto_ngram_3.rds"))
wordscores_manifesto_ngram_4 <- readRDS(file = here("lss", "wordscores_manifesto_ngram_4.rds"))
