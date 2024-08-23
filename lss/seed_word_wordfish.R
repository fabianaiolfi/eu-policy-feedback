
# Seed Words: Wordfish Approach -----------------------

# Import CEPS data -----------------------

# all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg_sample.rds")) # 100 docs
all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))

all_dir_reg_1000 <- all_dir_reg %>% slice_sample(n = 1000)

all_dir_reg_1000 <- all_dir_reg_1000 %>%
  distinct(CELEX, .keep_all = T) %>% 
  drop_na(CELEX)

# Convert to corpus object
all_dir_reg_corpus <- corpus(all_dir_reg_1000,
                      docid_field = "CELEX",
                      text_field = "act_raw_text",
                      meta = "test_id")

toks_all_dir_reg <- all_dir_reg_corpus %>% 
  tokens(remove_punct = TRUE,
         remove_symbols = TRUE, 
         remove_numbers = TRUE,
         remove_url = TRUE) %>% 
  tokens_remove(quanteda::stopwords("en", source = "marimo")) %>% 
  tokens_remove(min_nchar = 3) %>% # Remove tokens that are shorter than 3 characters
  tokens_remove(c("article", "shall", "annex", "commission", "decision", "member", "european", "state*", "measure*", "regard", "directive")) # Remove corpus specific irrelevant words

dfmat_all_dir_reg <- dfm(toks_all_dir_reg)
tmod_wf <- textmodel_wordfish(dfmat_all_dir_reg)

# Assuming your model is stored in the variable `tmod_wf`
tokens <- tmod_wf$features  # Extract the tokens (words)
beta <- tmod_wf$beta        # Extract the beta values
psi <- tmod_wf$psi          # Extract the psi values

# Combine into a dataframe
full_feature_scores_df <- data.frame(
  Feature = tokens,  # Add tokens as the first column
  Beta = beta,       # Add beta values as the second column
  Psi = psi          # Add psi values as the third column
)

