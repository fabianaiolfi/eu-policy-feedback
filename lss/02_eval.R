
# LSS Evaluation --------------------------

# Is there a correlation between ideology and subject matter?


# Load data --------------------------

# Output of 01_run_lss.R
glove_polarity_scores <- readRDS(here("data", "lss", "glove_polarity_scores.rds"))

# Subject matter (in original CEPS dataset)
ceps_eurlex_dir_reg_subject_matter <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg_subject_matter.rds"))

# Clustered tags: Clustered subject matters based on embeddings (topics/subject_matter.R)
ceps_eurlex_cluster_names <- readRDS(here("data", "topics", "ceps_eurlex_cluster_names.rds"))


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


# Evaluation 2: Correlation --------------------
# Transform categorical tags into a numerical representation that can be used for correlation analysis
# Create a binary matrix where each column represents a unique tag

tags_separated <- evaluation %>%
  select(CELEX, Subject_matter) %>% 
  dplyr::filter(Subject_matter != "") %>% # Remove empty rows
  separate_rows(Subject_matter, sep = ";") %>%
  mutate(Subject_matter = trimws(Subject_matter))

# Create a binary matrix where each column represents a unique tag
tags_binary <- tags_separated %>%
  mutate(presence = 1) %>%
  pivot_wider(names_from = Subject_matter, values_from = presence, values_fill = list(presence = 0)) %>% 
  left_join(select(evaluation, CELEX, avg_glove_polarity_scores), by = "CELEX")

# Prepare correlation data
correlation_data <- tags_binary %>% select(-CELEX)

# Calculate the correlation matrix
correlation_matrix <- cor(correlation_data, use = "pairwise.complete.obs")

# Extract the correlations with 'avg_glove_polarity_scores'
correlation_with_scores <- correlation_matrix["avg_glove_polarity_scores", ]
correlation_with_scores <- as.data.frame(correlation_with_scores)
correlation_with_scores$Subject_matter <- rownames(correlation_with_scores)
rownames(correlation_with_scores) <- NULL
correlation_with_scores <- correlation_with_scores %>% 
  dplyr::filter(correlation_with_scores != 1) %>% 
  arrange(-correlation_with_scores)

head(correlation_with_scores, 5)
# correlation_with_scores                     Subject_matter
# 1               0.2194048                           health
# 2               0.1862763              rights and freedoms
# 3               0.1760807 means of agricultural production
# 4               0.1659472  labour law and labour relations
# 5               0.1354413                       employment

tail(correlation_with_scores, 5)
# correlation_with_scores                           Subject_matter
# 119              -0.1481816               mechanical engineering
# 120              -0.2557085                     transport policy
# 121              -0.2708997                       land transport
# 122              -0.3085961 technology and technical regulations
# 123              -0.3866056            organisation of transport
