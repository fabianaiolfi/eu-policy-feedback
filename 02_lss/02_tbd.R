
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
dict <- dictionary(file = here("data", "02_lss", "l_r_dict.yml"))
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


