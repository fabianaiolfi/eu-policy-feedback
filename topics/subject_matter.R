
# Examine "Subject_matter" column in CEPS data


# Import CEPS data -----------------------

ceps_eurlex <- readRDS(here("data", "ceps_eurlex.rds"))

# Create subset of directives and regulations
ceps_eurlex_dir_reg <- ceps_eurlex %>% 
  mutate(Date_publication = as.Date(Date_publication, format = "%Y-%m-%d")) %>%
  dplyr::filter(Date_publication >= "1989-01-01") %>%
  dplyr::filter(str_detect(Act_type, "Directive|Regulation")) %>% 
  select(CELEX, Subject_matter)


# Count all available tags ----------------------------

tags <- ceps_eurlex_dir_reg %>% 
  select(Subject_matter) %>% 
  separate_rows(Subject_matter, sep = ";") %>% 
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  dplyr::filter(Subject_matter != "") # Remove empty rows

# Count tags
count_tags <- tags %>%
  count(Subject_matter) %>% 
  arrange(-n)

head(count_tags)
# Subject_matter                           n
# <chr>                                <int>
# 1 marketing                              985
# 2 health                                 806
# 3 technology and technical regulations   719
# 4 European Union law                     700
# 5 deterioration of the environment       542
# 6 means of agricultural production       452


# Count only first tag -----------------------------------

tags <- ceps_eurlex_dir_reg %>% 
  select(Subject_matter) %>% 
  mutate(Subject_matter = gsub(";.*", "", Subject_matter)) %>% # Remove all characters after the ";"
  mutate(Subject_matter = trimws(Subject_matter)) %>% 
  dplyr::filter(Subject_matter != "") # Remove empty rows

# Count tags
count_tags <- tags %>%
  count(Subject_matter) %>% 
  arrange(-n)

head(count_tags)
# Subject_matter   n
# 1                            marketing 218
# 2 technology and technical regulations 204
# 3                               health 201
# 4                   European Union law 127
# 5     deterioration of the environment 118
# 6            organisation of transport 116


# Cluster tags using embeddings ---------------------------------------------

# Download and load the GloVe embeddings
glove <- read.table(here("02_lss", "glove.6B", "glove.6B.300d.txt"), header = FALSE, quote = "", comment.char = "")
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
write.csv(embeddings_df, here("topics", "subject_matter_embedding_clusters.csv"), row.names = F)



# Elbow plot --------------------------------

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

