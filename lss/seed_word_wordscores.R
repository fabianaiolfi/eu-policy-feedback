
# Seed Words: Wordscores Approach -----------------------

## Get Manifesto Data -----------------

mp_setapikey("manifesto_apikey.txt")

corpus <- mp_corpus_df(date == 202103, translation = "en")


doclist <- mp_metadata(TRUE) %>% dplyr::filter(translation_en == TRUE | language == "english")

w_europe <- c("swedish", "norwegian", "danish", "finnish", "french", "dutch", "german", "italian",
              "spanish", "greek", "portuguese", "english")

my_doclist <- doclist %>% 
  dplyr::filter(date > 198900) %>% 
  dplyr::filter(language %in% w_europe)
  

test_df <- my_doclist %>% slice_sample(n = 10)

#corpus_test <- mp_corpus_df(ids = (manifesto_id == "160956_201905"))

english_annotated <- mp_availability(TRUE) %>% dplyr::filter(annotations == TRUE & language == "english")
english_translation <- mp_availability(TRUE) %>% dplyr::filter(translation_en == TRUE | language == "english")

corpus_test <- mp_corpus(english_translation)
saveRDS(corpus_test, file = here("lss", "corpus_test.rds"))

corpus_test_df <- mp_corpus_df(english_translation)
saveRDS(corpus_test_df, file = here("lss", "corpus_test_df.rds"))

corpus_test_df_3 <- mp_corpus_df(english_translation, translation = "en")
saveRDS(corpus_test_df_3, file = here("lss", "corpus_test_df_3.rds"))

###################

my_doclist$party
my_doclist$date

corpus_test_df_2 <- mp_corpus_df(party == 11220 & date == 200609,
                                 translation = "en")


corpus_test_df_2 <- mp_corpus_df(party == my_doclist$party & date == my_doclist$date,
                                 translation = "en")






