
# Seed Words: Wordscores Approach -----------------------

## Get Manifesto Data -----------------------

parties_MPDataset <- read.csv(file = here("lss", "parties_MPDataset_MPDS2024a.csv"))
MPDataset_MPDS2024a <- read.csv(file = here("data", "lss", "MPDataset_MPDS2024a.csv"))

# Documentation:
# https://manifesto-project.wzb.eu/information/documents/translation
# https://manifesto-project.wzb.eu/down/tutorials/firststepsmanifestoR.html#downloading-documents-from-the-manifesto-corpus

# Set API key
mp_setapikey("manifesto_apikey.txt")

english_translation <- mp_availability(TRUE) %>% 
  dplyr::filter(translation_en == TRUE | language == "english")

english_translation_manifesto_corpus <- mp_corpus_df(english_translation, translation = "en")

saveRDS(english_translation_manifesto_corpus, file = here("lss", "english_translation_manifesto_corpus.rds"))
english_translation_manifesto_corpus <- readRDS(file = here("lss", "english_translation_manifesto_corpus.rds"))


## Create Manifesto Data Subset --------------------
# Only include manifestos from Western Europe between 1989 and 2024

# Add country to each row
english_translation_manifesto_corpus <- english_translation_manifesto_corpus %>% 
  left_join(select(parties_MPDataset, party, countryname), by = "party")

w_europe <- c("Sweden", "Norway", "Denmark", "Finland", "Belgium", "Netherlands",
               "Luxembourg", "France", "Italy", "Spain", "Greece", "Portugal",
               "Germany", "Austria", "Switzerland", "United Kingdom", "Ireland", "Cyprus")

subset_manifesto_corpus <- english_translation_manifesto_corpus %>% 
  dplyr::filter(date > 198900) %>% 
  dplyr::filter(countryname %in% w_europe)

MPDataset_MPDS2024a_subset <- MPDataset_MPDS2024a %>% 
  dplyr::filter(date > 198900) %>% 
  mutate(manifesto_id = paste0(party, "_", date)) %>% 
  select(manifesto_id, rile)


## Create Corpus --------------------

# Concatenate texts
subset_manifesto_corpus <- subset_manifesto_corpus %>% 
  group_by(manifesto_id) %>% 
  summarise(text = str_c(text, collapse = " "))

subset_manifesto_corpus <- subset_manifesto_corpus %>% 
  left_join(MPDataset_MPDS2024a_subset, by = "manifesto_id")

# Convert to corpus object ######## CONTINUE HERE ##############
test_df <- corpus(subset_manifesto_corpus,
                  docid_field = "manifesto_id",
                  text = "text")
                  # rile = "rile")
                  # meta = "test_id")
# head(test_df)
# subset_manifesto_corpus$text[1]

# tokenize texts
toks_ger <- tokens(test_df, remove_punct = TRUE)

# create a document-feature matrix
dfmat_ger <- dfm(toks_ger) %>% 
  dfm_remove(pattern = stopwords("de"))

# apply Wordscores algorithm to document-feature matrix
tmod_ws <- textmodel_wordscores(dfmat_ger, y = corp_ger$ref_score, smooth = 1)
summary(tmod_ws)


#####



# corpus <- mp_corpus_df(date == 202103, translation = "en")

doclist <- mp_metadata(TRUE) %>% dplyr::filter(translation_en == TRUE | language == "english")

# w_europe <- c("swedish", "norwegian", "danish", "finnish", "french", "dutch", "german", "italian",
#               "spanish", "greek", "portuguese", "english")

w_europe <- doclist %>% 
  dplyr::filter(date > 198900) %>% 
  dplyr::filter(language %in% w_europe)
  

#test_df <- my_doclist %>% slice_sample(n = 10)

#corpus_test <- mp_corpus_df(ids = (manifesto_id == "160956_201905"))

# english_annotated <- mp_availability(TRUE) %>% dplyr::filter(annotations == TRUE & language == "english")
english_translation <- mp_availability(TRUE) %>% dplyr::filter(translation_en == TRUE | language == "english")

corpus_test <- mp_corpus(english_translation)
saveRDS(corpus_test, file = here("lss", "corpus_test.rds"))

corpus_test_df <- mp_corpus_df(english_translation)
saveRDS(corpus_test_df, file = here("lss", "corpus_test_df.rds"))

corpus_test_df_3 <- mp_corpus_df(english_translation, translation = "en")
saveRDS(corpus_test_df_3, file = here("lss", "corpus_test_df_3.rds"))

max(corpus_test_df_3$date)

###################

my_doclist$party
my_doclist$date

corpus_test_df_2 <- mp_corpus_df(party == 11220 & date == 200609,
                                 translation = "en")


corpus_test_df_2 <- mp_corpus_df(party == my_doclist$party & date == my_doclist$date,
                                 translation = "en")






