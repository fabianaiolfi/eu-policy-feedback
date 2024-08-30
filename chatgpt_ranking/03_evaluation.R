
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

plot_df_left <- ratings_df_left %>% 
  select(document) %>% 
  rename(left = document) %>% 
  # provide each row with an id
  mutate(id_left = row_number())

plot_df_right <- ratings_df_right_flipped %>% 
  select(document) %>% 
  rename(right = document) %>% 
  # provide each row with an id
  mutate(id_right = row_number())

df <- plot_df_left %>% 
  left_join(plot_df_right, by = c("left" = "right")) %>% 
  mutate(position_change = abs(id_left - id_right))

# Prepare data frame for plotting
plot_df <- data.frame(
  id = rep(1:nrow(df), each = 1),
  value = c(df$id_left, df$id_right),
  side = rep(c("left", "right"), each = nrow(df)),
  label = rep(df$left, each = 1), # Include labels for better understanding
  position_change = rep(df$position_change, each = 1)
)

# Plot
ggplot(plot_df, aes(x = side, y = value, group = id)) +
  geom_line(aes(color = position_change), linewidth = 1) +
  geom_point(aes(color = position_change)) +
  scale_color_gradient(low = "cornsilk", high = "firebrick1") + # https://sape.inf.usi.ch/quick-reference/ggplot2/colour
  geom_text(data = subset(plot_df, side == "left"), aes(label = label), nudge_x = -0.1, nudge_y = 0, size = 3, hjust = 1) +
  geom_text(data = subset(plot_df, side == "right"), aes(label = label), nudge_x = 0.1, nudge_y = 0, size = 3, hjust = 0) +
  scale_y_reverse(breaks = seq(min(plot_df$value), max(plot_df$value))) +
  theme_minimal() +
  theme(axis.text.x = element_text(hjust = 0.5)) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(legend.position = "none") +
  labs(title = "Order Difference Most Left and Most Right Ranking",
       subtitle = "Most Right Ranking Flipped",
       x = "",
       y = "Position")
