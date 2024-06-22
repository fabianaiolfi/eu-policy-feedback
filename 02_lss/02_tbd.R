
# Based on Example 1: generic sentiment (https://koheiw.github.io/LSX/articles/pkgdown/basic.html#example-1-generic-sentiment)

# Example 1

# Estimate the polarity of words
# Taking the DFM and the seed words as the only inputs, textmodel_lss() computes the polarity scores of all the words in the corpus based on their semantic similarity to the seed words. You usually do not need to change the value of k (300 by default).
seed <- as.seedwords(data_dictionary_sentiment)
lss <- textmodel_lss(dfmt,
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
seed <- as.seedwords(dict$ideology)
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
corp_sent <- corpus_reshape(sample_ceps_eurlex_corpus, to =  "sentences")
toks_sent <- corp_sent %>% 
  tokens(remove_punct = TRUE, remove_symbols = TRUE, 
         remove_numbers = TRUE, remove_url = TRUE) %>% 
  tokens_remove(stopwords("en", source = "marimo")) %>% 
  # remove tokens that are shorter than 3 characters
  tokens_remove(min_nchar = 3) %>%
  tokens_remove(c("article", "shall", "annex", "commission", "decision", "member", "european", "state*", "measure*", "regard", "directive"))

# create a document feature matrix from the tokens object
dfmat_sent <- toks_sent %>% 
  dfm() %>% 
  dfm_remove(pattern = "") %>% 
  dfm_trim(min_termfreq = 5)

topfeatures(dfmat_sent, 20)

# identify context words 
context_words <- char_context(toks_sent, pattern = "authority", p = 0.05)
context_words

# Create LSS Model
tmod_lss <- textmodel_lss(dfmat_sent,
                          seeds = seed,
                          k = 300,
                          simil_method = "ejaccard",
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
bs_coef[rownames(bs_coef) %in% c("solidarity"),]






