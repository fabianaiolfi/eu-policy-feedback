
# LSS Evaluation --------------------------

# Is there a correlation between ideology and subject matter?


# Load data --------------------------

# Output of 01_run_lss.R
# glove_polarity_scores <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_econ.rds"))
glove_polarity_scores <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_social.rds"))

# CEPS with keywords
ceps_eurlex_dir_reg_keywords <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg_keywords.rds"))

# Clustered keywords: Clustered subject matters based on embeddings (topics/subject_matter.R)
ceps_eurlex_Subject_matter_cluster_names <- readRDS(here("data", "topics", "ceps_eurlex_Subject_matter_cluster_names.rds"))


# Prepare data -------------------

ceps_eurlex_Subject_matter_cluster_names <- ceps_eurlex_Subject_matter_cluster_names %>% 
  group_by(CELEX) %>%
  summarize(subject_matter_cluster_name = str_c(subject_matter_cluster_name, collapse = "; "))

evaluation <- glove_polarity_scores %>% 
  left_join(ceps_eurlex_dir_reg_keywords, by = "CELEX") %>% 
  left_join(ceps_eurlex_Subject_matter_cluster_names, by = "CELEX")

evaluation <- evaluation %>%
  mutate(polarity_score_group_cut = cut(avg_glove_polarity_scores, breaks = 3, labels = F)) %>% # Bins of equal width, unequal number of observations
  mutate(polarity_score_group_cut = case_when(polarity_score_group_cut == 1 ~ "right",
                                              polarity_score_group_cut == 2 ~ "centre",
                                              polarity_score_group_cut == 3 ~ "left")) %>% 
  mutate(polarity_score_group_ntile = ntile(avg_glove_polarity_scores, n = 3)) %>% # Equal number of observations, unequal width
  mutate(polarity_score_group_ntile = case_when(polarity_score_group_ntile == 1 ~ "right",
                                                polarity_score_group_ntile == 2 ~ "centre",
                                                polarity_score_group_ntile == 3 ~ "left"))

# Clean up missing values: Currently around 23% of EUROVOC/Subject_matter are NAs
evaluation <- evaluation %>% 
  # In EUROVOC and Subject_matter cols, replace empty strings and "character(0)" with NA
  mutate(EUROVOC = ifelse(EUROVOC == "" | EUROVOC == "character(0)", NA, EUROVOC),
         Subject_matter = ifelse(Subject_matter == "" | Subject_matter == "character(0)", NA, Subject_matter))

# Evaluation 1: Three groups --------------------
# Create 3 broad groups (left, center, right) and examine top *EUROVOC* keywords in each group

table(evaluation$polarity_score_group_cut)

top_keywords <- evaluation %>% 
  dplyr::filter(polarity_score_group_cut == "right") %>% # "right" "centre"
  select(EUROVOC) %>% 
  separate_rows(EUROVOC, sep = ";") %>% 
  mutate(EUROVOC = trimws(EUROVOC)) %>% 
  dplyr::filter(EUROVOC != "") %>% # Remove empty rows
  count(EUROVOC) %>% 
  arrange(-n) %>% 
  rename(EUROVOC_Keyword = EUROVOC) %>% 
  rename(Occurences = n)

print(top_keywords, n = 5)


# Create 3 broad groups (left, center, right) and examine top *Subject_matter* keywords in each group

top_keywords <- evaluation %>% 
  dplyr::filter(polarity_score_group_cut == "right") %>% # "right" "centre"
  select(Subject_matter) %>% 
  separate_rows(Subject_matter, sep = ";") %>% 
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  dplyr::filter(Subject_matter != "") %>% # Remove empty rows
  count(Subject_matter) %>% 
  arrange(-n) %>% 
  rename(Subject_matter_Keyword = Subject_matter) %>% 
  rename(Occurences = n)

print(top_keywords, n = 5)


# Evaluation 2: Correlation --------------------
# Transform categorical keywords into a numerical representation that can be used for correlation analysis
# Create a binary matrix where each column represents a unique keyword

# Keyword: EUROVOC --------------------

keywords_separated <- evaluation %>%
  select(CELEX, EUROVOC) %>% 
  dplyr::filter(EUROVOC != "") %>% # Remove empty rows
  separate_rows(EUROVOC, sep = ";") %>%
  mutate(EUROVOC = trimws(EUROVOC)) %>% 
  distinct(CELEX, EUROVOC) # Remove duplicate row that was causing an error in pivot_wider below

# Create a binary matrix where each column represents a unique keyword
keywords_binary <- keywords_separated %>%
  mutate(presence = 1) %>% 
  pivot_wider(names_from = EUROVOC, values_from = presence, values_fill = list(presence = 0)) %>% 
  left_join(select(evaluation, CELEX, avg_glove_polarity_scores), by = "CELEX")

# Prepare correlation data
correlation_data <- keywords_binary %>% select(-CELEX)

# Calculate the correlation matrix
correlation_matrix <- cor(correlation_data, use = "pairwise.complete.obs")

# Extract the correlations with 'avg_glove_polarity_scores'
# How much do the keywords correlate with the avg_glove_polarity_score?
correlation_with_scores <- correlation_matrix["avg_glove_polarity_scores", ]
correlation_with_scores <- as.data.frame(correlation_with_scores)
correlation_with_scores$EUROVOC <- rownames(correlation_with_scores)
rownames(correlation_with_scores) <- NULL
correlation_with_scores <- correlation_with_scores %>% 
  dplyr::filter(correlation_with_scores != 1) %>% 
  arrange(-correlation_with_scores)

head(correlation_with_scores, 5)
tail(correlation_with_scores, 5)


# Keyword: Subject_matter --------------------

keywords_separated <- evaluation %>%
  select(CELEX, Subject_matter) %>% 
  dplyr::filter(Subject_matter != "") %>% # Remove empty rows
  separate_rows(Subject_matter, sep = ";") %>%
  mutate(Subject_matter = trimws(Subject_matter))

# Create a binary matrix where each column represents a unique keyword
keywords_binary <- keywords_separated %>%
  mutate(presence = 1) %>%
  pivot_wider(names_from = Subject_matter, values_from = presence, values_fill = list(presence = 0)) %>% 
  left_join(select(evaluation, CELEX, avg_glove_polarity_scores), by = "CELEX")

# Prepare correlation data
correlation_data <- keywords_binary %>% select(-CELEX)

# Calculate the correlation matrix
correlation_matrix <- cor(correlation_data, use = "pairwise.complete.obs")

# Extract the correlations with 'avg_glove_polarity_scores'
# How much do the keywords correlate with the avg_glove_polarity_score?
correlation_with_scores <- correlation_matrix["avg_glove_polarity_scores", ]
correlation_with_scores <- as.data.frame(correlation_with_scores)
correlation_with_scores$Subject_matter <- rownames(correlation_with_scores)
rownames(correlation_with_scores) <- NULL
correlation_with_scores <- correlation_with_scores %>% 
  dplyr::filter(correlation_with_scores != 1) %>% 
  arrange(-correlation_with_scores)

head(correlation_with_scores, 10)
tail(correlation_with_scores, 10)
