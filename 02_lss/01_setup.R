
## Pre-processing CEPS EurLex Data --------------------------

ceps_eurlex_dir_reg <- ceps_eurlex %>% 
  mutate(Date_publication = as.Date(Date_publication, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_publication >= "1989-01-01") %>%
  dplyr::filter(str_detect(Act_type, "Directive|Regulation")) %>% 
  select(CELEX, act_raw_text) %>%
  # Remove rows where act_raw_text is the string "nan"
  dplyr::filter(act_raw_text != "nan")

# Convert to corpus object
ceps_eurlex_dir_reg <- corpus(ceps_eurlex_dir_reg,
                              docid_field = "CELEX",
                              text_field = "act_raw_text",
                              meta = "test_id")
