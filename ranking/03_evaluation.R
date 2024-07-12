
# Load ranked dataframes ---------------------------------------------------------------

ratings_df_left <- readRDS(file = here("data", "ranking", "ratings_df_more_left_20240712_144220.rds"))
ratings_df_right <- readRDS(file = here("data", "ranking", "ratings_df_more_right_20240712_144521.rds"))


# Compare both lists ---------------------------------------------------------------

# Assumption: The least right policies are also the most left ones
ratings_df_right_flipped <- ratings_df_right %>% arrange(rating)

# Create the dataframe
df <- ratings_df_left %>% 
  select(document) %>% 
  rename(left = document)
df$right <- ratings_df_right_flipped$document

# Function to calculate the difference metric
calculate_difference <- function(list1, list2) {
  n <- length(list1)
  total_difference <- 0
  
  for (i in 1:n) {
    element <- list1[i]
    position_in_list2 <- match(element, list2)
    total_difference <- total_difference + abs(i - position_in_list2)
  }
  
  return(total_difference)
}

# Calculate the difference between the two lists
difference <- calculate_difference(df$left, df$right)


# Visualise difference between both lists ---------------------------------------------------------------



