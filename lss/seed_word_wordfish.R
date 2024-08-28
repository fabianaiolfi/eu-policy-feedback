
# Seed Words: Wordfish Approach -----------------------

project_seed <- 999
set.seed(project_seed)

## Import data -----------------------

# all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg_sample.rds")) # 100 docs
all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))
all_dir_reg <- all_dir_reg %>% slice_sample(n = 1000)

procedural_stop_words <- scan(here("lss", "procedural_stop_words.txt"), character(), quote = "")


## Preprocess data -----------------------

# Remove duplicates and missing CELEX IDs
all_dir_reg <- all_dir_reg %>%
  distinct(CELEX, .keep_all = T) %>% 
  drop_na(CELEX)

# Convert to corpus object
all_dir_reg_corpus <- corpus(all_dir_reg,
                             docid_field = "CELEX",
                             text_field = "act_raw_text",
                             meta = "test_id")

# Clean text
toks_all_dir_reg <- all_dir_reg_corpus %>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE, 
         remove_numbers = TRUE,
         remove_url = TRUE) %>% 
  tokens_remove(quanteda::stopwords("en", source = "marimo")) %>% 
  tokens_remove(procedural_stop_words) %>%  # Remove corpus specific irrelevant words
  tokens_remove("\\b(?=\\w*[A-Za-z])(?=\\w*\\d)\\w+\\b", valuetype = "regex") %>% # Remove mixed letter-number tokens
  tokens_remove("\\b(?=.*\\d)(?=.*[[:punct:]])\\S+\\b", valuetype = "regex") %>% # Remove mixed letter-punctuation tokens
  tokens_remove(min_nchar = 3) # Remove tokens that are shorter than 3 characters

# Create bigrams
toks_all_dir_reg <- tokens_ngrams(toks_all_dir_reg, n = 2)

# Create document-feature matrix
dfmat_all_dir_reg <- dfm(toks_all_dir_reg)

# Limit the vocabulary to tokens with a minimum count of 50 occurrences
dfmat_all_dir_reg <- dfm_trim(dfmat_all_dir_reg, min_termfreq = 50)


## Convert trimmed matrix back to token object -----------------
# This is used later for subsampling

# Get the features (words) and their counts
features <- featnames(dfmat_all_dir_reg)
counts <- as.matrix(dfmat_all_dir_reg)

# Reconstruct the documents
doc_texts <- apply(counts, 1, function(row) {
  paste(rep(features, row), collapse = " ")
})

# Now tokenize the reconstructed documents
toks_all_dir_reg <- tokens(doc_texts)


## Perform Subsampling ---------------------

word_frequencies <- colSums(dfmat_all_dir_reg)
total_words <- sum(word_frequencies)

# Set the threshold
t <- 1e-5

word_probs <- 1 - sqrt(t / (word_frequencies / total_words))
word_probs[word_probs < 0] <- 0  # Ensure that the probability is not negative

# Subsample the tokens
subsampled_tokens <- tokens_remove(toks_all_dir_reg,
                                   pattern = names(word_probs)[sapply(names(word_probs),
                                                                      function(word) {
                                                                        runif(1) < word_probs[word]
                                                                        })])

# Reconstruct the documents after subsampling
subsampled_corpus <- sapply(subsampled_tokens, paste, collapse = " ")

# Create document-feature matrix
subsampled_dfmat <- dfm(tokens(subsampled_corpus))


# Run Wordfish model -----------------------------------

tmod_wf <- textmodel_wordfish(subsampled_dfmat)

# Extract tokens, beta and psi values from Wordfish model
tokens <- tmod_wf$features
beta <- tmod_wf$beta
psi <- tmod_wf$psi

# Combine extraced data into a single dataframe
full_feature_scores_df <- data.frame(
  feature = tokens,
  beta = beta,
  psi = psi)

# saveRDS(full_feature_scores_df, file = here("lss", "wordfish_output", "full_feature_scores_df_5k_unigrams.rds"))
