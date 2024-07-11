
# Naive Ranking: Counting Occurences ---------------------------------------------------------------

# Count the number of times each document is identified as "more left"
ranked_df <- dummy_data %>%
  group_by(more_left) %>%
  summarize(count = n()) %>%
  arrange(desc(count))

# Rename the columns for clarity
colnames(ranked_df) <- c("document", "count")


# Elo Ranking: Counting Occurences ---------------------------------------------------------------

