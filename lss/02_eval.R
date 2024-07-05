
# LSS Evaluation --------------------------

# Is there a correlation between ideology and subject matter?


# Load data --------------------------

# Output of 01_run_lss.R
glove_polarity_scores <- readRDS(here("data", "lss", "glove_polarity_scores_240705.rds"))

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
  # in EUROVOC and Subject_matter cols, replace empty strings and "character(0)" with NA
  mutate(EUROVOC = ifelse(EUROVOC == "" | EUROVOC == "character(0)", NA, EUROVOC),
         Subject_matter = ifelse(Subject_matter == "" | Subject_matter == "character(0)", NA, Subject_matter))


# Evaluation 1: Three groups --------------------
# Create 3 broad groups (left, center, right) and examine top *EUROVOC* keywords in each group

top_keywords <- evaluation %>% 
  dplyr::filter(polarity_score_group_cut == "centre") %>% # "right" "centre"
  select(EUROVOC) %>% 
  separate_rows(EUROVOC, sep = ";") %>% 
  mutate(EUROVOC = trimws(EUROVOC)) %>% 
  dplyr::filter(EUROVOC != "") %>% # Remove empty rows
  count(EUROVOC) %>% 
  arrange(-n)

head(top_keywords, n = 10)

# "left" (using sentences)
# EUROVOC                   n
# <chr>                 <int>
# 1 approximation of laws    18
# 2 equal opportunity        14
# 3 alien                    12
# 4 employment law           10
# 5 worker information       10

# "centre" (using sentences)
# EUROVOC                   n
# <chr>                 <int>
# 1 approximation of laws   370
# 2 grading                 313
# 3 marketing               246
# 4 plant health product    213
# 5 labelling               197

# "right" (using sentences)
# EUROVOC                              n
# <chr>                            <int>
# 1 motor vehicle                      140
# 2 approximation of laws              129
# 3 technical standard                  96
# 4 adaptation to technical progress    81
# 5 grading                             68

# Create 3 broad groups (left, center, right) and examine top *Subject_matter* keywords in each group

top_keywords <- evaluation %>% 
  dplyr::filter(polarity_score_group_cut == "centre") %>% # "right" "centre"
  select(Subject_matter) %>% 
  separate_rows(Subject_matter, sep = ";") %>% 
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  dplyr::filter(Subject_matter != "") %>% # Remove empty rows
  count(Subject_matter) %>% 
  arrange(-n)

head(top_keywords, n = 10)

# "left" (using sentences)
# Subject_matter                      n
# <chr>                           <int>
# 1 European Union law                 29
# 2 employment                         29
# 3 rights and freedoms                24
# 4 health                             23
# 5 labour law and labour relations    23

# "left" (using paragraphs)
# Subject_matter                      n
# <chr>                           <int>
# 1 employment                         29
# 2 European Union law                 28
# 3 health                             25
# 4 rights and freedoms                24
# 5 labour law and labour relations    23

# "right" (using sentences)
# Subject_matter                           n
# <chr>                                <int>
# 1 technology and technical regulations   280
# 2 organisation of transport              234
# 3 European Union law                     174
# 4 marketing                              138
# 5 transport policy                       130

# "right" (using paragraphs)
# Subject_matter                           n
# <chr>                                <int>
# 1 technology and technical regulations   279
# 2 organisation of transport              235
# 3 European Union law                     170
# 4 marketing                              132
# 5 transport policy                       130


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

head(correlation_with_scores, 10)
# Using sentences
# correlation_with_scores              EUROVOC
# 1               0.2196984 plant health product
# 2               0.1798582    equal opportunity
# 3               0.1520850         disinfectant
# 4               0.1297387       employment law
# 5               0.1279970                  GII


tail(correlation_with_scores, 10)
# Using sentences
# correlation_with_scores                 EUROVOC
# 1789              -0.1811606                     COC
# 1790              -0.1855913 Community certification
# 1791              -0.2419075      commercial vehicle
# 1792              -0.2463396      technical standard
# 1793              -0.3617184           motor vehicle


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
# Using sentences
# correlation_with_scores                     Subject_matter
# 1               0.2194048                           health
# 2               0.1862763              rights and freedoms
# 3               0.1760807 means of agricultural production
# 4               0.1659472  labour law and labour relations
# 5               0.1354413                       employment

# Using paragraphs
# correlation_with_scores                   Subject_matter
# 1               0.2221000                           health
# 2               0.1863899              rights and freedoms
# 3               0.1768236 means of agricultural production
# 4               0.1643161  labour law and labour relations
# 5               0.1368674                       employment

tail(correlation_with_scores, 10)
# Using sentences
# correlation_with_scores                           Subject_matter
# 119              -0.1481816               mechanical engineering
# 120              -0.2557085                     transport policy
# 121              -0.2708997                       land transport
# 122              -0.3085961 technology and technical regulations
# 123              -0.3866056            organisation of transport

# Using paragraphs
# correlation_with_scores                       Subject_matter
# 119              -0.1490653               mechanical engineering
# 120              -0.2576249                     transport policy
# 121              -0.2751934                       land transport
# 122              -0.3119345 technology and technical regulations
# 123              -0.3918363            organisation of transport
