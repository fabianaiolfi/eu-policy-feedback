
# Import custom dictionary for seed words -----------------------

dict <- dictionary(file = here("data", "lss", "l_r_dict.yml"))
seed <- as.seedwords(dict$ideology, concatenator = " ")


# Import CEPS data -----------------------

ceps_eurlex_dir_reg <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg.rds"))


# Clean corpus --------------------------
# https://tutorials.quanteda.io/machine-learning/lss/

# Convert to corpus object
ceps_eurlex_dir_reg <- corpus(ceps_eurlex_dir_reg,
                              docid_field = "CELEX",
                              text_field = "act_raw_text",
                              meta = "test_id")

# Tokenize text corpus and remove various features
corp_sent <- corpus_reshape(ceps_eurlex_dir_reg, to = "sentences") # to = "paragraphs"

toks_sent <- corp_sent %>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE, 
         remove_numbers = TRUE,
         remove_url = TRUE)# %>% 
  # tokens_remove(quanteda::stopwords("en", source = "marimo")) %>% 
  # tokens_remove(min_nchar = 3) %>% # Remove tokens that are shorter than 3 characters
  # tokens_remove(c("article", "shall", "annex", "commission", "decision", "member", "european", "state*", "measure*", "regard", "directive")) # Remove corpus specific irrelevant words


# Set up document feature matrix --------------------------

# Create a DFM from the tokens object
dfmat_sent <- toks_sent %>%
  dfm() %>% 
  dfm_remove(pattern = "") %>% 
  dfm_trim(min_termfreq = 5)


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


# LSS with GloVe ----------------------------------
# Instructions: https://blog.koheiw.net/?p=2031

# Import GloVe embeddings
# Source: https://nlp.stanford.edu/projects/glove/

mt <- read.table(here("data", "glove.6B", "glove.6B.300d.txt"),
                 quote = "",
                 sep = " ",
                 fill = F,
                 comment.char = "",
                 row.names = 1,
                 fileEncoding = "UTF-8")

colnames(mt) <- NULL
mt <- mt[stringi::stri_detect_regex(rownames(mt), "[a-zA-Z]"),] # Exclude numbers and punctuations
mt <- t(mt) # Transpose

# Create LSS object
lss <- as.textmodel_lss(mt, seed)

# Predict document polarity
# glove_polarity_scores <- predict(lss, newdata = dfmat_sent)
glove_polarity_scores <- predict(lss, newdata = dfmat_sent, type = "embedding")

# Calculate average document polarity based on sentence weight
glove_polarity_scores <- as.data.frame(glove_polarity_scores)
glove_polarity_scores$CELEX <- rownames(glove_polarity_scores) # Convert row names to column
glove_polarity_scores <- glove_polarity_scores %>% left_join(toks_sent_df, by = c("CELEX" = "sent_id")) # Add sentence weight
glove_polarity_scores$CELEX <- gsub("\\..*", "", glove_polarity_scores$CELEX) # Remove all characters after the "."

glove_polarity_scores <- glove_polarity_scores %>%
  group_by(CELEX) %>%
  summarise(avg_glove_polarity_scores = weighted.mean(glove_polarity_scores, sent_weight, na.rm = T))

# saveRDS(glove_polarity_scores, file = here("data", "lss", "glove_polarity_scores.rds"))


# Selection and evaluation of seed words ---------------
# https://koheiw.github.io/LSX/articles/pkgdown/seedwords.html

# Evaluation with synonyms
# bs_term <- bootstrap_lss(lss, mode = "terms")
# saveRDS(bs_term, file = here("data", "lss", "bs_term.rds"))
bs_term <- readRDS(here("data", "lss", "bs_term.rds"))
head(bs_term, 5)

# Evaluation with words with known polarity
bs_coef <- bootstrap_lss(lss, mode = "coef")
saveRDS(bs_coef, file = here("data", "lss", "bs_coef.rds"))

dat_seed <- data.frame(seed = lss$seeds, diff = bs_coef["solidarity",] - bs_coef["migration",])
print(dat_seed)






