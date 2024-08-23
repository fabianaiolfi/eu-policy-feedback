
# Seed Words: Wordfish Approach -----------------------

# Import CEPS data -----------------------

# all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg_sample.rds")) # 100 docs
all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))
all_dir_reg <- all_dir_reg %>% slice_sample(n = 200)

procedural_stop_words <- scan(here("lss", "procedural_stop_words.txt"), character(), quote = "")

all_dir_reg <- all_dir_reg %>%
  distinct(CELEX, .keep_all = T) %>% 
  drop_na(CELEX)

# Convert to corpus object
all_dir_reg_corpus <- corpus(all_dir_reg,
                      docid_field = "CELEX",
                      text_field = "act_raw_text",
                      meta = "test_id")

toks_all_dir_reg <- all_dir_reg_corpus %>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE, 
         remove_numbers = TRUE,
         remove_url = TRUE) %>% 
  tokens_remove(quanteda::stopwords("en", source = "marimo")) %>% 
  tokens_remove(procedural_stop_words) %>%  # Remove corpus specific irrelevant words
  tokens_remove(min_nchar = 3) # Remove tokens that are shorter than 3 characters

# Create document-feature matrix
dfmat_all_dir_reg <- dfm(toks_all_dir_reg)

# Limit the vocabulary to tokens with a minimum count of 50 occurrences
dfmat_all_dir_reg <- dfm_trim(dfmat_all_dir_reg, min_termfreq = 50)

## Convert trimmed matrix back to object with tokens (used later for subsampling) -----

# Get the features (words) and their counts
features <- featnames(dfmat_all_dir_reg)
counts <- as.matrix(dfmat_all_dir_reg)

# Reconstruct the documents
doc_texts <- apply(counts, 1, function(row) {
  paste(rep(features, row), collapse = " ")
})

# Now tokenize the reconstructed documents
tokens_object <- tokens(doc_texts)


## Subsampling --------------
word_frequencies <- colSums(dfmat_all_dir_reg)
total_words <- sum(word_frequencies)

# Set the threshold
t <- 1e-5
word_probs <- 1 - sqrt(t / (word_frequencies / total_words))
word_probs[word_probs < 0] <- 0  # Ensure that the probability is not negative

# Subsample the tokens
subsampled_tokens <- tokens_remove(tokens_object, pattern = names(word_probs)[sapply(names(word_probs), function(word) {
  runif(1) < word_probs[word]
})])

# Reconstruct the documents after subsampling
subsampled_corpus <- sapply(subsampled_tokens, paste, collapse = " ")



# Run Wordfish model -------

tmod_wf <- textmodel_wordfish(dfmat_all_dir_reg)

# Extract tokens, beta and psi values from Wordfish model
tokens <- tmod_wf$features
beta <- tmod_wf$beta
psi <- tmod_wf$psi

# Combine extraced data into a single dataframe
full_feature_scores_df <- data.frame(
  feature = tokens,
  beta = beta,
  psi = psi)
