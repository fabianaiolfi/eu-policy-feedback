
# LSS Evaluation --------------------------

# Is there a correlation between ideology and subject matter?


# Load data --------------------------

# Output of 01_run_lss.R
glove_polarity_scores <- readRDS(here("02_lss", "glove_polarity_scores.rds"))

# Subject matter (in original CEPS dataset)
ceps_eurlex_dir_reg_subject_matter <- readRDS(here("data", "ceps_eurlex_dir_reg_subject_matter.rds"))

# Clustered tags: Clustered subject matters based on embeddings (topics/subject_matter.R)
ceps_eurlex_cluster_names <- readRDS(here("topics", "ceps_eurlex_cluster_names.rds"))


# Prepare data -------------------
ceps_eurlex_cluster_names <- ceps_eurlex_cluster_names %>% 
  group_by(CELEX) %>%
  summarize(cluster_name = str_c(cluster_name, collapse = "; "))

evaluation <- glove_polarity_scores %>% 
  left_join(ceps_eurlex_dir_reg_subject_matter, by = "CELEX") %>% 
  left_join(ceps_eurlex_cluster_names, by = "CELEX")

# hist(test_df$avg_glove_polarity_scores)
# head(test_df)
# test_df %>% select(-CELEX) %>% head()


# Evaluation 1: Three groups --------------------
# Create 3 broad groups (left, center, right) and examine top subject matters in each group

# test_df <- test_df %>% mutate(new_bin = cut(avg_glove_polarity_scores, breaks=3, labels = F))
evaluation <- evaluation %>% mutate(new_bin = ntile(avg_glove_polarity_scores, n=3))

evaluation <- evaluation %>% 
  dplyr::filter(new_bin == 1) %>% 
  select(cluster_name) %>% 
  separate_rows(cluster_name, sep = ";") %>% 
  mutate(cluster_name = trimws(cluster_name)) %>% 
  dplyr::filter(cluster_name != "") # Remove empty rows

# Count tags
count_tags <- evaluation %>%
  count(cluster_name) %>% 
  arrange(-n)

head(count_tags)

