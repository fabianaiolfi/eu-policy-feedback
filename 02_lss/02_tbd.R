
# Based on Example 1: generic sentiment (https://koheiw.github.io/LSX/articles/pkgdown/basic.html#example-1-generic-sentiment)

# Example 1

# Estimate the polarity of words
# Taking the DFM and the seed words as the only inputs, textmodel_lss() computes the polarity scores of all the words in the corpus based on their semantic similarity to the seed words. You usually do not need to change the value of k (300 by default).
seed <- as.seedwords(data_dictionary_sentiment)
lss <- textmodel_lss(dfmt_example,
                     seeds = seed,
                     k = 2,
                     cache = F,
                     include_data = T,
                     group_data = T
                     )

# Predict the polarity of documents
dat <- docvars(lss$data)
dat$lss <- predict(lss)


# Example 2

# Estimate the polarity of words
dict <- dictionary(file = here("data", "02_lss", "dictionary.yml"))
print(dict$hostility)

seed2 <- as.seedwords(dict$hostility)

term <- tokens_remove(toks, dict$country, padding = TRUE) %>% 
  char_context(pattern = "nato", p = 0.01)

lss2 <- textmodel_lss(dfmt, seeds = seed2, terms = term, cache = F, 
                      include_data = TRUE, group_data = T)

# Predict the polarity of documents
dat2 <- docvars(lss2$data)
quantile(ntoken(lss2$data))
dat2$lss <- predict(lss2, min_n = 10)
print(nrow(dat2))



#####################

# Using custom dictionary
dict <- dictionary(file = here::here("data", "02_lss", "l_r_dict.yml"))
seed <- as.seedwords(dict$ideology, concatenator = " ")
lss <- textmodel_lss(dfmt,
                     seeds = seed,
                     k = 300,
                     cache = F,
                     include_data = T,
                     group_data = T)

# Predict the polarity of documents
# TO DO: Check if correct documents are being merged with the ID
dat <- docvars(lss$data)
dat$lss <- predict(lss)

# Look at policies
# sample_ceps_eurlex$act_raw_text[37]
sample_ceps_eurlex$CELEX[886]

#####################
# Clean corpus
# https://tutorials.quanteda.io/machine-learning/lss/

# tokenize text corpus and remove various features
corp_sent <- corpus_reshape(sample_ceps_eurlex_corpus, to = "sentences") # to = "paragraphs"
toks_sent <- corp_sent %>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE, 
         remove_numbers = TRUE,
         remove_url = TRUE) %>% 
  tokens_remove(stopwords("en", source = "marimo")) %>% 
  # remove tokens that are shorter than 3 characters
  tokens_remove(min_nchar = 3) %>%
  tokens_remove(c("article", "shall", "annex", "commission", "decision", "member", "european", "state*", "measure*", "regard", "directive"))

# Get sentence length and with it sentence weight in its own document
# Extract the tokens and their document names
tokens_list <- as.list(toks_sent)
doc_names <- docnames(toks_sent)

# Create a data frame
df_tokens <- data.frame(
  sent_id = rep(doc_names, lengths(tokens_list)),
  token = unlist(tokens_list)
)

df_tokens_sent_len <- df_tokens %>% 
  count(sent_id, name = "sent_len") %>% 
  mutate(doc_id = gsub("\\..*", "", sent_id)) %>% 
  group_by(doc_id) %>% 
  mutate(doc_len = sum(sent_len)) %>% 
  mutate(sent_weight = sent_len / doc_len) %>% 
  ungroup() %>% 
  select(sent_id, sent_weight)
  

# Create bigrams
# toks_sent_bigrams <- toks_sent %>% tokens_ngrams(n = 2, concatenator = " ")

# create a document feature matrix from the tokens object
dfmat_sent <- toks_sent %>%
  dfm() %>% 
  dfm_remove(pattern = "") %>% 
  dfm_trim(min_termfreq = 5)



# Save dfmat_sent to file
# save(dfmat_sent, ascii = F, file = here("data", "02_lss", "dfmat_sent"))
# rm(dfmat_sent)
load(here("data", "02_lss", "dfmat_sent"))

# dfmat_sent_bigrams <- toks_sent_bigrams %>%
#   dfm() %>% 
#   dfm_remove(pattern = "") %>% 
#   dfm_trim(min_termfreq = 5)

topfeatures(dfmat_sent, 20)

# identify context words 
context_words <- char_context(toks_sent, pattern = "authority", p = 0.05)
context_words

# Create LSS Model
tmod_lss <- textmodel_lss(dfmat_sent,
                          seeds = seed,
                          k = 300,
                          # simil_method = "ejaccard",
                          # engine = c("RSpectra", "irlba", "rsvd", "rsparse"),
                          engine = "rsparse",
                          include_data = T,
                          group_data = T,
                          cache = F
                          )

head(coef(tmod_lss), 20) # ideologically left words
tail(coef(tmod_lss), 20) # ideologically right words



#####################
# Selection of seed words
# https://koheiw.github.io/LSX/articles/pkgdown/seedwords.html

# print(lss)
print(tmod_lss$seeds)
print(tmod_lss$seeds_weighted)

bs_term <- bootstrap_lss(tmod_lss, mode = "terms")
# knitr::kable(head(bs_term, 10))
head(bs_term, 10)

bs_coef <- bootstrap_lss(tmod_lss, mode = "coef")
#knitr::kable(head(bs_coef, 10), digits = 3)
head(bs_coef, 10)

# filter by row name
bs_coef[rownames(bs_coef) %in% c("migrant"),]


# predict polarity
dat <- docvars(tmod_lss$data)
dat$lss <- predict(tmod_lss)

# Look at policies
# sample_ceps_eurlex$act_raw_text[37]
sample_ceps_eurlex$CELEX[837]



############### Using GloVe #########

# Instructions: https://blog.koheiw.net/?p=2031

# Import GloVe Data
# Source: https://nlp.stanford.edu/projects/glove/

mt <- read.table(here("02_lss", "glove.6B", "glove.6B.200d.txt"), quote = "", sep = " ", fill = FALSE,
                 comment.char = "", row.names = 1, fileEncoding = "UTF-8")

colnames(mt) <- NULL
mt <- mt[stringi::stri_detect_regex(rownames(mt), "[a-zA-Z]"),] # exclude numbers and punctuations
mt <- t(mt) # transpose

# seed <- as.seedwords(data_dictionary_sentiment)
lss <- as.textmodel_lss(mt, seed) # create LSS object

# check polarity of words using coef()
head(coef(lss), 20)
tail(coef(lss), 20)

# This is a bit pointless here
# bs_term <- bootstrap_lss(lss, mode = "terms")
# head(bs_term, 10)

# bs_coef <- bootstrap_lss(lss, mode = "coef")
# head(bs_coef, 10)

glove_polarity_scores <- predict(lss, newdata = dfmat_sent)
df <- as.data.frame(glove_polarity_scores)
# convert row names to column
df$CELEX <- rownames(df)

# add sentence weight
df <- df %>% left_join(df_tokens_sent_len, by = c("CELEX" = "sent_id"))

# merge sentences back to documents
# in the CELEX column, remove all characters after the .
df$CELEX <- gsub("\\..*", "", df$CELEX)
# length(unique(df$CELEX)) # number of documents

# calculate average polarity for each document
# use sentence length as weight (shorter sentences should have less weight)
## CONTINUE HERE ##

df <- df %>%
  group_by(CELEX) %>%
  summarise(avg_glove_polarity_scores = weighted.mean(glove_polarity_scores, sent_weight, na.rm = TRUE))


