
# Examine keywords (EUROVOC, Subject_matter) columns in CEPS data


# Import CEPS data -----------------------

# CEPS with keywords
ceps_eurlex_dir_reg_keywords <- readRDS(here("data", "data_collection", "ceps_eurlex_dir_reg_keywords.rds"))


# Count Keyword: EUROVOC -------------------------

EUROVOC <- ceps_eurlex_dir_reg_keywords %>% 
  select(EUROVOC) %>% 
  separate_rows(EUROVOC, sep = ";") %>% 
  mutate(EUROVOC = trimws(EUROVOC)) %>% 
  dplyr::filter(EUROVOC != "") # Remove empty rows

# Count tags
count_EUROVOC <- EUROVOC %>%
  count(EUROVOC) %>% 
  arrange(-n)

head(count_EUROVOC)
# EUROVOC                   n
# 1 approximation of laws   517
# 2 grading                 389
# 3 marketing               269
# 4 phytosanitary control   238
# 5 ban on sales            227
# 6 plant health product    222

# Count only first tag -----------------------------------

EUROVOC <- ceps_eurlex_dir_reg_keywords %>% 
  select(EUROVOC) %>% 
  mutate(EUROVOC = gsub(";.*", "", EUROVOC)) %>% # Remove all characters after the ";"
  mutate(EUROVOC = trimws(EUROVOC)) %>% 
  dplyr::filter(EUROVOC != "") # Remove empty rows

# Count tags
count_EUROVOC <- EUROVOC %>%
  count(EUROVOC) %>% 
  arrange(-n)

head(count_EUROVOC)
# EUROVOC                      n
# 1     approximation of laws 89
# 2                 marketing 60
# 3                   grading 52
# 4              ban on sales 36
# 5             motor vehicle 36
# 6 phytosanitary legislation 35


# Count Keyword: Subject_matter -------------------------

Subject_matter <- ceps_eurlex_dir_reg_keywords %>% 
  select(Subject_matter) %>% 
  separate_rows(Subject_matter, sep = ";") %>% 
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  dplyr::filter(Subject_matter != "") # Remove empty rows

# Count tags
count_Subject_matter <- Subject_matter %>%
  count(Subject_matter) %>% 
  arrange(-n)

head(count_Subject_matter)
# Subject_matter                           n
# <chr>                                <int>
# 1 marketing                              985
# 2 health                                 806
# 3 technology and technical regulations   719
# 4 European Union law                     700
# 5 deterioration of the environment       542
# 6 means of agricultural                  452


# Count only first tag -----------------------------------

Subject_matter <- ceps_eurlex_dir_reg_keywords %>% 
  select(Subject_matter) %>% 
  mutate(Subject_matter = gsub(";.*", "", Subject_matter)) %>% # Remove all characters after the ";"
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  dplyr::filter(Subject_matter != "") # Remove empty rows

# Count tags
count_Subject_matter <- Subject_matter %>%
  count(Subject_matter) %>% 
  arrange(-n)

head(count_Subject_matter)
# Subject_matter                           n
# 1                            marketing 218
# 2 technology and technical regulations 204
# 3                               health 201
# 4                   European Union law 127
# 5     deterioration of the environment 118
# 6            organisation of transport 116



# Cluster keywords using embeddings ---------------------------------------------

# Download and load the GloVe embeddings
glove <- read.table(here("data", "glove.6B", "glove.6B.300d.txt"), header = FALSE, quote = "", comment.char = "")
colnames(glove) <- c("word", paste0("dim", 1:300))
glove <- as.data.frame(glove)

# Function to get embedding for a term
get_embedding <- function(term) {
  embedding <- glove %>% dplyr::filter(word == term) %>% select(-word)
  if (nrow(embedding) == 0) return(rep(NA, 300))
  return(as.numeric(embedding))
}

# Function to get embedding for multi-word term
get_embedding_for_term <- function(term) {
  words <- strsplit(term, " ")[[1]]
  word_embeddings <- lapply(words, get_embedding)
  valid_embeddings <- word_embeddings[!sapply(word_embeddings, is.null)]
  if (length(valid_embeddings) == 0) return(NULL)
  average_embedding <- colMeans(do.call(rbind, valid_embeddings))
  return(average_embedding)
}

# Cluster EUROVOC ---------------------------------------------

# Get CEPS Eurlex terms and clean them in order to get their embeddings
terms <- count_EUROVOC$EUROVOC
terms <- terms[!terms %in% c("NA")]
terms <- tolower(terms)
terms <- gsub("[[:punct:]]", " ", terms) # Replace punctuation with space
terms <- gsub("  ", " ", terms) # Replace double white space with single white space

# Calculate embeddings for terms
term_embeddings <- lapply(terms, get_embedding_for_term)

# Convert the list of embeddings into a data frame
valid_embeddings <- !sapply(term_embeddings, is.null)
embeddings_matrix <- do.call(rbind, term_embeddings[valid_embeddings])
terms_valid <- terms[valid_embeddings]
embeddings_df <- as.data.frame(embeddings_matrix)
colnames(embeddings_df) <- paste0("dim", 1:ncol(embeddings_df))
embeddings_df <- cbind(term = terms_valid, embeddings_df)

# Select the embedding columns
embedding_columns <- embeddings_df %>%
  select(starts_with("dim"))

# Convert the selected columns to a matrix for clustering
embedding_matrix <- as.matrix(embedding_columns)

# Remove rows that contain NAs
# Get row numbers that contain NAs
na_rows <- apply(embedding_matrix, 1, function(x) any(is.na(x)))
na_rows <- as.data.frame(na_rows)
na_rows$index <- 1:nrow(na_rows)
na_rows <- na_rows %>% 
  dplyr::filter(na_rows == TRUE) %>% 
  select(index)
na_rows <- na_rows$index

# Remove terms from list at index in na_rows
terms_valid <- terms[-na_rows]

# Remove terms from dataframe at index in na_rows
embeddings_df <- embeddings_df[-na_rows,]

# Perform k-means clustering
clusters <- kmeans(na.omit(embedding_matrix),
                   centers = 10, # Number of clusters
                   nstart = 150,
                   iter.max = 150
                   )

# Add cluster information to the dataframe
embeddings_df$cluster <- clusters$cluster
embeddings_df <- embeddings_df %>%
  select(term, cluster) %>% 
  arrange(cluster)

# Save the embeddings and clusters to name clusters
# write.csv(embeddings_df, here("topics", "EUROVOC_embedding_clusters.csv"), row.names = F) # NOT RUN!


# Cluster Subject_matter ---------------------------------------------

# Get CEPS Eurlex terms and clean them in order to get their embeddings
terms <- count_tags$Subject_matter
terms <- terms[!terms %in% c("NA")]
terms <- tolower(terms)
terms <- gsub("[[:punct:]]", " ", terms) # Replace punctuation with space
terms <- gsub("  ", " ", terms) # Replace double white space with single white space

# Calculate embeddings for terms
term_embeddings <- lapply(terms, get_embedding_for_term)

# Convert the list of embeddings into a data frame
valid_embeddings <- !sapply(term_embeddings, is.null)
embeddings_matrix <- do.call(rbind, term_embeddings[valid_embeddings])
terms_valid <- terms[valid_embeddings]
embeddings_df <- as.data.frame(embeddings_matrix)
colnames(embeddings_df) <- paste0("dim", 1:ncol(embeddings_df))
embeddings_df <- cbind(term = terms_valid, embeddings_df)

# Select the embedding columns
embedding_columns <- embeddings_df %>%
  select(starts_with("dim"))

# Convert the selected columns to a matrix for clustering
embedding_matrix <- as.matrix(embedding_columns)

# Perform k-means clustering
clusters <- kmeans(embedding_matrix,
                   centers = 40, # Number of clusters
                   nstart = 150,
                   iter.max = 150)

# Add cluster information to the dataframe
embeddings_df$cluster <- clusters$cluster
embeddings_df <- embeddings_df %>%
  select(term, cluster) %>% 
  arrange(cluster)

# Save the embeddings and clusters to name clusters
# write.csv(embeddings_df, here("topics", "subject_matter_embedding_clusters.csv"), row.names = F)


# Cluster Naming --------------------------------

# Load CSV
embeddings_df <- read.csv(here("data", "topics", "subject_matter_embedding_clusters.csv"))

# ChatGPT prompt: I've attached a CSV containing terms that have been clustered. Can you please name each cluster based on the terms in a cluster?
embeddings_df <- embeddings_df %>% 
  mutate(subject_matter_cluster_name = case_when(cluster == 1 ~ "Agricultural Production",
                                                cluster == 2 ~ "Humanities",
                                                cluster == 3 ~ "International Relations",
                                                cluster == 4 ~ "Policy and Regulation",
                                                cluster == 5 ~ "Natural Resource Industries",
                                                cluster == 6 ~ "Consumption",
                                                cluster == 7 ~ "Competition",
                                                cluster == 8 ~ "Employment and Labour",
                                                cluster == 9 ~ "Communications",
                                                cluster == 10 ~ "Justice",
                                                cluster == 11 ~ "Heavy Industries",
                                                cluster == 12 ~ "Economic Studies",
                                                cluster == 13 ~ "Transport and Logistics",
                                                cluster == 14 ~ "Agriculture and Food Technology",
                                                cluster == 15 ~ "Family and Society",
                                                cluster == 16 ~ "Health and Insurance",
                                                cluster == 17 ~ "Legislative Bodies",
                                                cluster == 18 ~ "Budget and Finance",
                                                cluster == 19 ~ "Africa",
                                                cluster == 20 ~ "Accounting",
                                                cluster == 21 ~ "Trade",
                                                cluster == 22 ~ "Engineering",
                                                cluster == 23 ~ "Technology and Standards",
                                                cluster == 24 ~ "Retail and Distribution",
                                                cluster == 25 ~ "Education",
                                                cluster == 26 ~ "Law",
                                                cluster == 27 ~ "Business and European Organisations",
                                                cluster == 28 ~ "Taxation",
                                                cluster == 29 ~ "Chemistry",
                                                cluster == 30 ~ "Social and Political Affairs",
                                                cluster == 31 ~ "Pricing",
                                                cluster == 32 ~ "European Union Affairs",
                                                cluster == 33 ~ "Defence",
                                                cluster == 34 ~ "Migration",
                                                cluster == 35 ~ "Monetary Economics",
                                                cluster == 36 ~ "Sciences and Environment",
                                                cluster == 37 ~ "Marketing and Management",
                                                cluster == 38 ~ "Production",
                                                cluster == 39 ~ "Foodstuff",
                                                cluster == 40 ~ "Information Technology"))

# Add cluster name to CEPS Eurlex documents
ceps_eurlex_Subject_matter_cluster_names <- ceps_eurlex_dir_reg_keywords %>% 
  separate_rows(Subject_matter, sep = ";") %>%
  mutate(Subject_matter = gsub("NA; ", "", Subject_matter)) %>% 
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  mutate(Subject_matter = tolower(Subject_matter)) %>% 
  mutate(Subject_matter = gsub("[[:punct:]]", " ", Subject_matter)) %>% # Replace punctuation with space
  mutate(Subject_matter = gsub("  ", " ", Subject_matter)) %>% # Replace double white space with single white space
  dplyr::filter(!str_detect(Subject_matter, "NA")) %>% # Remove NA rows
  left_join(embeddings_df, by = c("Subject_matter" = "term")) %>% 
  group_by(CELEX) %>% 
  distinct(cluster, .keep_all = T) %>% 
  select(CELEX, subject_matter_cluster_name) %>% 
  drop_na()

# Save to file for use in other scripts
saveRDS(ceps_eurlex_Subject_matter_cluster_names, file = here("data", "topics", "ceps_eurlex_Subject_matter_cluster_names.rds"))


# K-means clustering elbow plot --------------------------------

# Define the range of cluster counts to evaluate
# max_k <- 50
# wss <- numeric(max_k)
# 
# # Compute WSS for each k
# for (k in 1:max_k) {
#   kmeans_result <- kmeans(embedding_matrix, centers = k, nstart = 25)
#   wss[k] <- kmeans_result$tot.withinss
# }
# 
# # Create a data frame for plotting
# elbow_data <- data.frame(
#   k = 1:max_k,
#   wss = wss
# )
# 
# # Plot the elbow plot
# ggplot(elbow_data, aes(x = k, y = wss)) +
#   geom_line() +
#   geom_point() +
#   scale_x_continuous(breaks = 1:max_k) +
#   labs(title = "Elbow Method for Determining Optimal Number of Clusters",
#        x = "Number of Clusters (k)",
#        y = "Total Within-Cluster Sum of Squares (WSS)") +
#   theme_minimal()
