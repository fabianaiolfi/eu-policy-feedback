
# Libraries ----------------

library(LSX)
library(quanteda)
library(ggplot2)


# Data Import ----------------

corp <- readRDS(here("data", "data_corpus_sputnik2022.rds")) %>% 
  corpus_reshape(to = "sentences")

toks <- tokens(corp, remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = TRUE, remove_url = TRUE)

dfmt <- dfm(toks) %>% 
  dfm_remove(stopwords("en"))
