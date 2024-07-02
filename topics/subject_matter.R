
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


# Cluster tags ---------------------------------------------

#  term-document matrix based on the bag-of-words model

# Load necessary libraries
# install.packages(c("text2vec", "tm", "dplyr", "cluster"))
library(text2vec)
library(tm)
library(dplyr)
library(cluster)

# Example list of terms
# terms <- c("employment", "labor market", "job security", "social protection", "healthcare", "retirement", "education", "vocational training", "public safety", "financial stability")
terms <- count_tags$Subject_matter

# Preprocess the terms
# terms_clean <- tolower(terms)
# terms_clean <- removePunctuation(terms_clean)
# terms_clean <- removeNumbers(terms_clean)
# terms_clean <- stripWhitespace(terms_clean)

# Create term-document matrix
tokens <- word_tokenizer(terms)
it <- itoken(tokens, progressbar = FALSE)
vocab <- create_vocabulary(it)
vectorizer <- vocab_vectorizer(vocab)
dtm <- create_dtm(it, vectorizer)

# Normalize the term-document matrix
dtm_normalized <- apply(as.matrix(dtm), 1, function(row) row / sqrt(sum(row^2)))

# Convert back to matrix form
dtm_normalized <- t(dtm_normalized)

# Compute term similarities with normalized matrix
similarity_matrix <- sim2(dtm_normalized, method = "cosine", norm = "none")

# Cluster the terms
# set.seed(123)
k <- 20 # Number of clusters
clusters <- kmeans(similarity_matrix,
                    iter.max = 1000,
                    centers = k,
                    nstart = 25)

# Assign terms to clusters
terms_clusters <- data.frame(term = terms, cluster = clusters$cluster)
View(terms_clusters)



# using embeddings

# Load necessary libraries
# install.packages(c("text2vec", "dplyr"))
library(text2vec)
library(dplyr)

# Download and load the GloVe embeddings
glove <- read.table(here("02_lss", "glove.6B", "glove.6B.200d.txt"), header = FALSE, quote = "", comment.char = "")
colnames(glove) <- c("word", paste0("dim", 1:200))
glove <- as.data.frame(glove)
# glove$word <- as.character(glove$word)

# Example list of terms
# terms <- c("employment", "labor market", "job security", "social protection", "healthcare", "retirement", "education", "vocational training", "public safety", "financial stability")

# Function to get embedding for a term
get_embedding <- function(term) {
  embedding <- glove %>% dplyr::filter(word == term) %>% select(-word)
  if (nrow(embedding) == 0) return(rep(NA, 50))
  return(as.numeric(embedding))
}

# Obtain embeddings for terms
embeddings <- sapply(terms, get_embedding)
embeddings <- t(embeddings)
embeddings <- as.data.frame(embeddings)
test <- t(embeddings)
test <- as.data.frame(test)
test$word <- rownames(test)
rownames(test) <- NULL
test <- test %>% select(word, V1)

test <- test %>%
  unnest_wider(V1, names_sep = "_") %>% 
  drop_na()

head(test)


# Select the embedding columns (V1_1 to V1_200)
embedding_columns <- test %>%
  select(starts_with("V1_"))

# Convert the selected columns to a matrix for clustering
embedding_matrix <- as.matrix(embedding_columns)

# Perform k-means clustering
# set.seed(123) # For reproducibility
k <- 15 # Number of clusters, adjust as needed
clusters <- kmeans(embedding_matrix, centers = k, nstart = 25)

# Add cluster information to the dataframe
test$cluster <- clusters$cluster

test_output <- test %>% select(word, cluster)

