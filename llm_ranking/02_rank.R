
# Create dummy data to test ranking algorithm ---------------------------------------------------------------

# dummy_data <- ceps_eurlex_dir_reg_summaries %>% select(CELEX) # Only select CELEX
# dummy_data <- bind_rows(replicate(3, dummy_data, simplify = F)) # Repeat same row 3 times
# dummy_data <- dummy_data %>% 
#   rename(doc1 = CELEX) %>%
#   mutate(doc2 = sample(doc1)) %>% # Shuffle rows
#   # Randomly pick a value from doc1 or doc2 and save it in new column
#   mutate(more_left = ifelse(runif(nrow(.)) > 0.5, doc1, doc2)) %>% 
#   arrange(doc1)


# Naive Ranking: Counting Occurences ---------------------------------------------------------------

# Count the number of times each document is identified as "more left"
ranked_df <- dummy_data %>%
  group_by(more_left) %>%
  summarize(count = n()) %>%
  arrange(desc(count))

# Rename the columns for clarity
colnames(ranked_df) <- c("document", "count")


# Elo Ranking ---------------------------------------------------------------

# Elo update function
update_elo <- function(winner, loser, ratings, K = 32) {
  expected_winner <- 1 / (1 + 10^((ratings[loser] - ratings[winner]) / 400))
  expected_loser <- 1 / (1 + 10^((ratings[winner] - ratings[loser]) / 400))
  
  ratings[winner] <- ratings[winner] + K * (1 - expected_winner)
  ratings[loser] <- ratings[loser] + K * (0 - expected_loser)
  
  return(ratings)
}


## Economically left-leaning -------------------------

# Initialize ratings
initial_rating <- 1000
documents <- unique(c(ranking_df_left$CELEX_1, ranking_df_left$CELEX_2))
ratings <- setNames(rep(initial_rating, length(documents)), documents)

# Iterate over comparisons and update ratings
for (i in 1:nrow(ranking_df_left)) {
  winner <- ranking_df_left$more_left[i]
  loser <- ifelse(ranking_df_left$CELEX_1[i] == winner, ranking_df_left$CELEX_2[i], ranking_df_left$CELEX_1[i])
  ratings <- update_elo(winner, loser, ratings)
}

# Convert ratings to a dataframe for easier viewing
ratings_df_left <- data.frame(document = names(ratings), rating = unname(ratings))
ratings_df_left <- ratings_df_left %>% arrange(desc(rating))

# Save to file
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("llama_ratings_df_left_", formatted_timestamp, ".rds")
saveRDS(ratings_df_left, file = here("data", "llm_ranking", file_name))


## Economically right-leaning -------------------------

# Initialize ratings
initial_rating <- 1000
documents <- unique(c(ranking_df_right$CELEX_1, ranking_df_right$CELEX_2))
ratings <- setNames(rep(initial_rating, length(documents)), documents)

# Iterate over comparisons and update ratings
for (i in 1:nrow(ranking_df_right)) {
  winner <- ranking_df_right$more_right[i]
  loser <- ifelse(ranking_df_right$CELEX_1[i] == winner, ranking_df_right$CELEX_2[i], ranking_df_right$CELEX_1[i])
  ratings <- update_elo(winner, loser, ratings)
}

# Convert ratings to a dataframe for easier viewing
ratings_df_right <- data.frame(document = names(ratings), rating = unname(ratings))
ratings_df_right <- ratings_df_right %>% arrange(desc(rating))

# Save to file
timestamp <- Sys.time()
formatted_timestamp <- format(timestamp, "%Y%m%d_%H%M%S")
file_name <- paste0("llama_ratings_df_right_", formatted_timestamp, ".rds")
saveRDS(ratings_df_right, file = here("data", "llm_ranking", file_name))
