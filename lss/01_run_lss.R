
# Import custom dictionary for seed words -----------------------

# dict <- dictionary(file = here("lss", "seed_words_econ_manual.yml"))
dict <- dictionary(file = here("lss", "seed_words_social_manual.yml"))
seed <- as.seedwords(dict$ideology, concatenator = " ")


# Import data -----------------------

all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))

# Clean corpus --------------------------
# https://tutorials.quanteda.io/machine-learning/lss/

all_dir_reg <- all_dir_reg %>% distinct(CELEX, .keep_all = T)

# Create subset
# all_dir_reg <- all_dir_reg %>% head(n = 10000)

# Convert to corpus object
all_dir_reg <- corpus(all_dir_reg,
                      docid_field = "CELEX",
                      text_field = "act_raw_text",
                      meta = "test_id")

# Tokenize text corpus and remove various features
corp_sent <- corpus_reshape(all_dir_reg, to = "sentences") # to = "paragraphs"

toks_sent <- corp_sent %>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE, 
         remove_numbers = TRUE,
         remove_url = TRUE) %>% 
  tokens_remove(quanteda::stopwords("en", source = "marimo")) %>%
  tokens_remove(min_nchar = 3) # Remove tokens that are shorter than 3 characters
  # tokens_remove(c("article", "shall", "annex", "commission", "decision", "member", "european", "state*", "measure*", "regard", "directive")) # Remove corpus specific irrelevant words


# Set up document feature matrix --------------------------

# Create a DFM from the tokens object
dfmat_sent <- toks_sent %>%
  dfm() %>% 
  dfm_remove(pattern = "") %>% 
  dfm_trim(min_termfreq = 50#,
           # min_docfreq = 0.15,
           # max_docfreq = 0.85,
           # docfreq_type = "prop"
           )


# Calculate sentence weight ----------------------------------
# We need sentence length in order to calculate the weight of each sentence.
# We assume that longer sentences contain more information. Thus they should receive a larger weight when averaging polarity of an entire document.

# Extract the tokens and their document names
tokens_list <- as.list(toks_sent)
doc_names <- docnames(toks_sent)

# Convert toks_sent to a data frame
toks_sent_df <- data.frame(
  sent_id = rep(doc_names, lengths(tokens_list)),
  token = unlist(tokens_list))

# Calculate sentence weight relative to its length in its document
toks_sent_df <- toks_sent_df %>% 
  count(sent_id, name = "sent_len") %>% # Calculate number of tokens per sentence
  mutate(doc_id = gsub("\\..*", "", sent_id)) %>% # Get document ID based on sentence ID
  group_by(doc_id) %>% 
  mutate(doc_len = sum(sent_len)) %>% 
  mutate(sent_weight = sent_len / doc_len) %>% 
  ungroup() %>% 
  select(sent_id, sent_weight)


# Save and load objects ----------------------------------
# Used when applying large datasets

# saveRDS(corp_sent, file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/corp_sent.rds")
# saveRDS(toks_sent, file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/toks_sent.rds")
# saveRDS(dfmat_sent, file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/dfmat_sent.rds")
# saveRDS(tokens_list, file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/tokens_list.rds")
# saveRDS(toks_sent_df, file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/toks_sent_df.rds")

corp_sent <- readRDS(file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/corp_sent.rds")
toks_sent <- readRDS(file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/toks_sent.rds")
dfmat_sent <- readRDS(file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/dfmat_sent.rds")
tokens_list <- readRDS(file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/tokens_list.rds")
toks_sent_df <- readRDS(file = "/Volumes/iPhone_Backup_2/eu-policy-feedback-data/toks_sent_df.rds")


# LSS with GloVe ----------------------------------
# Instructions: https://blog.koheiw.net/?p=2031

# Import GloVe embeddings
# Source: https://nlp.stanford.edu/projects/glove/

mt <- read.table(here("data", "glove.6B", "glove.6B.50d.txt"),
                 quote = "",
                 sep = " ",
                 fill = F,
                 comment.char = "",
                 row.names = 1,
                 fileEncoding = "UTF-8")

colnames(mt) <- NULL
mt <- mt[stringi::stri_detect_regex(rownames(mt), "[a-zA-Z]"),] # Exclude numbers and punctuations


# Calculate embeddings for multi-word seed words ----------------

# Function to calculate the embedding of a multi-word term
calculate_embedding <- function(term, embedding_matrix) {
  # Split the term into individual words
  words <- unlist(strsplit(term, " "))
  
  # Check if all words exist in the embedding matrix
  missing_words <- words[!words %in% rownames(embedding_matrix)]
  if (length(missing_words) > 0) {
    stop(paste("The following words are missing in the embedding matrix:", paste(missing_words, collapse = ", ")))
  }
  
  # Extract embeddings for each word
  word_embeddings <- embedding_matrix[words, ]
  
  # Calculate the average embedding for the multi-word term
  term_embedding <- colMeans(word_embeddings)
  
  return(term_embedding)
}

# Function to add multiple multi-word term embeddings to the matrix
add_multi_word_embeddings <- function(multi_word_terms, embedding_matrix) {
  for (term in multi_word_terms) {
    # Calculate the embedding for each multi-word term
    multi_word_embedding <- calculate_embedding(term, embedding_matrix)
    
    # Add the multi-word term embedding to the existing matrix
    embedding_matrix <- rbind(embedding_matrix, multi_word_embedding)
    rownames(embedding_matrix)[nrow(embedding_matrix)] <- term
  }
  
  return(embedding_matrix)
}

multi_word_terms <- names(seed) # Convert named num list to normal character list
multi_word_terms <- multi_word_terms[sapply(multi_word_terms, function(x) length(unlist(strsplit(x, " "))) > 1)] # remove single word terms from list
mt <- add_multi_word_embeddings(multi_word_terms, mt)

mt <- t(mt) # Transpose

# Create LSS object
lss <- as.textmodel_lss(mt, seed)

# Predict document polarity
glove_polarity_scores <- predict(lss, newdata = dfmat_sent)

# Calculate average document polarity based on sentence weight
glove_polarity_scores <- data.frame(
  CELEX = names(glove_polarity_scores), # flattened_scores
  glove_polarity_scores = as.numeric(glove_polarity_scores)) # flattened_scores
glove_polarity_scores <- glove_polarity_scores %>% left_join(toks_sent_df, by = c("CELEX" = "sent_id")) # Add sentence weight
glove_polarity_scores$CELEX <- gsub("\\..*", "", glove_polarity_scores$CELEX) # Remove all characters after the "."

glove_polarity_scores <- glove_polarity_scores %>%
  group_by(CELEX) %>%
  summarise(avg_glove_polarity_scores = weighted.mean(glove_polarity_scores, sent_weight, na.rm = T))

saveRDS(glove_polarity_scores, file = here("data", "lss", "glove_polarity_scores_all_dir_reg_social.rds"))


# Selection and evaluation of seed words ---------------
# https://koheiw.github.io/LSX/articles/pkgdown/seedwords.html

# Evaluation with synonyms
bs_term <- bootstrap_lss(lss, mode = "terms")
saveRDS(bs_term, file = here("data", "lss", "bs_term_v3.rds"))
# bs_term <- readRDS(here("data", "lss", "bs_term_vx.rds"))
head(bs_term, 10)

# Evaluation with words with known polarity
# bs_coef <- bootstrap_lss(lss, mode = "coef")
# saveRDS(bs_coef, file = here("data", "lss", "bs_coef.rds"))
bs_coef <- readRDS(here("data", "lss", "bs_coef.rds"))
dat_seed <- data.frame(seed = lss$seeds, diff = bs_coef["equal",] - bs_coef["individual",])
print(dat_seed)
