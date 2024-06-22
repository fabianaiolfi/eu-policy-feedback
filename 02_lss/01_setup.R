
# Libraries --------------------------------

library(LSX)
library(quanteda)
library(ggplot2)


# Data Import --------------------------------

## Example Data -----------------------------

# https://koheiw.github.io/LSX/articles/pkgdown/basic.html#preperation
corp <- readRDS(here("data", "02_lss", "data_corpus_sputnik2022.rds")) %>% 
  corpus_reshape(to = "sentences")

toks <- tokens(corp, remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = TRUE, remove_url = TRUE)

dfmt <- dfm(toks) %>% 
  dfm_remove(stopwords("en"))


## CEPS EurLex --------------------------

# Create sample 
sample_ceps_eurlex <- ceps_eurlex %>% 
  mutate(Date_publication = as.Date(Date_publication, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_publication >= "1989-01-01") %>%
  # dplyr::filter(Act_type %in% c("Directive", "Directive_IMPL", "Directive_DEL", "Regulation", "Implementing Regulation", "Delegated Regulation", "Regulation_FINANC"))# %>% # Only regulations and directives
  dplyr::filter(str_detect(Act_type, "Directive|Regulation")) %>% 
  select(CELEX, act_raw_text) %>%
  # sample_n(10000) %>% 
  # Remove rows where act_raw_text is the string "nan"
  dplyr::filter(act_raw_text != "nan") %>%
  # sample_n(10) %>%
  mutate(test_id = row_number())

# Convert to corpus
sample_ceps_eurlex_corpus <- corpus(sample_ceps_eurlex,
                                    docid_field = "CELEX",
                                    text_field = "act_raw_text",
                                    meta = "test_id")

toks <- tokens(sample_ceps_eurlex_corpus,
               remove_punct = TRUE,
               remove_symbols = TRUE,
               remove_numbers = TRUE,
               remove_url = TRUE)

dfmt <- dfm(toks) %>% 
  dfm_remove(stopwords("en"))
