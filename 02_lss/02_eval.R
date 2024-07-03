
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


# Evaluation 1: Three groups --------------------
# Create 3 broad groups (left, center, right) and examine top subject matters in each group

evaluation <- evaluation %>%
  mutate(polarity_score_group_cut = cut(avg_glove_polarity_scores, breaks = 3, labels = F)) %>% # Bins of equal width, unequal number of observations
  mutate(polarity_score_group_cut = case_when(polarity_score_group_cut == 1 ~ "right",
                                              polarity_score_group_cut == 2 ~ "centre",
                                              polarity_score_group_cut == 3 ~ "left")) %>% 
  mutate(polarity_score_group_ntile = ntile(avg_glove_polarity_scores, n = 3)) %>% # Equal number of observations, unequal width
  mutate(polarity_score_group_ntile = case_when(polarity_score_group_ntile == 1 ~ "right",
                                                polarity_score_group_ntile == 2 ~ "centre",
                                                polarity_score_group_ntile == 3 ~ "left"))
  
top_tags <- evaluation %>% 
  dplyr::filter(polarity_score_group_cut == "right") %>% # "right" "centre"
  select(Subject_matter) %>% 
  separate_rows(Subject_matter, sep = ";") %>% 
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  dplyr::filter(Subject_matter != "") %>% # Remove empty rows
  count(Subject_matter) %>% 
  arrange(-n)

head(top_tags, n = 5)

# "left"
# Subject_matter                      n
# <chr>                           <int>
# 1 European Union law                 29
# 2 employment                         29
# 3 rights and freedoms                24
# 4 health                             23
# 5 labour law and labour relations    23

# "right"
# Subject_matter                           n
# <chr>                                <int>
# 1 technology and technical regulations   280
# 2 organisation of transport              234
# 3 European Union law                     174
# 4 marketing                              138
# 5 transport policy                       130

