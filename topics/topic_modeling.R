
# Example script
# https://tutorials.quanteda.io/machine-learning/topicmodel/

require(quanteda)
require(quanteda.corpora)
require(seededlda)
require(lubridate)

corp_news <- download("data_corpus_guardian")

corp_news_2016 <- corpus_subset(corp_news, year(date) == 2016)
ndoc(corp_news_2016)

toks_news <- tokens(corp_news_2016, remove_punct = TRUE, remove_numbers = TRUE, remove_symbol = TRUE)
toks_news <- tokens_remove(toks_news, pattern = c(stopwords("en"), "*-time", "updated-*", "gmt", "bst"))
dfmat_news <- dfm(toks_news) %>% 
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

tmod_lda <- textmodel_lda(dfmat_news, k = 10)

terms(tmod_lda, 10) # You can extract the most important terms for each topic from the model using terms().
head(topics(tmod_lda), 20)


# own application

# ceps_eurlex_dir_reg

toks_ceps <- tokens(ceps_eurlex_dir_reg, remove_punct = TRUE, remove_numbers = TRUE, remove_symbol = TRUE)

toks_ceps <- toks_ceps %>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE, 
         remove_numbers = TRUE,
         remove_url = TRUE) %>% 
  tokens_remove(stopwords("en", source = "marimo")) %>% 
  tokens_remove(min_nchar = 4) %>% # Remove tokens that are shorter than 3 characters
  tokens_remove(c("article", "shall", "annex", "commission", "decision", "member", "european", "state*", "measur*", "regard", "directive", "appendix", "therefor", "notify*")) %>%  # Remove corpus specific irrelevant words
  # Remove tokens that contain non-letters
  tokens_remove(pattern = "[^a-z]") # maybe add + again

dfmat_ceps <- dfm(toks_ceps) %>% 
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

tmod_lda <- textmodel_lda(dfmat_ceps,
                          max_iter = 200, # 2000: ca. 20min; 100. ca 1.5min
                          k = 30,
                          verbose = T)

terms(tmod_lda, 10)
head(topics(tmod_lda), 20)



