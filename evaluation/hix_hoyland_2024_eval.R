
## Comparison with Hix Hoyland 2024 ----------------------------

# Load CELEX from ranking/03_evaluation.R
ratings_df_left <- readRDS(file = here("data", "ranking", "ratings_df_more_left_20240712_144220.rds"))
ceps_eurlex_dir_reg_sample <- ceps_eurlex %>% dplyr::filter(CELEX %in% ratings_df_left$document)

# Consolidate own results
own_results <- RoBERT_df %>% 
  select(CELEX, left_right) %>% 
  left_join(select(bakker_hobolt_econ, CELEX, economic), by = "CELEX") %>% 
  left_join(select(bakker_hobolt_social, CELEX, social), by = "CELEX")

# Reconstruct Table 1 from Hix Hoyland (2024, p. 13)
hix_hoyland_table_1 <- data.frame(
  CELEX = c("32003L0088", "32006L0123", "32011L0095"),
  left_right_hh = c(-2.10, -1.60, 1.42),
  economic_hh = c(-2.10, -2.98, -0.37),
  social_hh = c(1.56, -1.66, -1.94)
)

left_right_results <- own_results %>%
  select(CELEX, left_right) %>% 
  left_join(select(hix_hoyland_table_1, CELEX, left_right_hh), by = "CELEX") %>% 
  mutate(diff = left_right_hh - left_right)

econ_results <- own_results %>%
  select(CELEX, economic) %>% 
  left_join(select(hix_hoyland_table_1, CELEX, economic_hh), by = "CELEX") %>% 
  mutate(diff = economic_hh - economic)

social_results <- own_results %>%
  select(CELEX, social) %>% 
  left_join(select(hix_hoyland_table_1, CELEX, social_hh), by = "CELEX") %>% 
  mutate(diff = social_hh - social)


## Comparison with ranking ------------------------------

ranking_RoBERT_df <- RoBERT_df %>% 
  select(CELEX, left_right) %>% 
  arrange(left_right)

ranking_bakker_hobolt_econ <- bakker_hobolt_econ %>% 
  select(CELEX, economic) %>% 
  arrange(economic)

ranking_elo <- readRDS(file = here("data", "ranking", "ratings_df_more_left_20240712_144220.rds"))

# Visualise difference between both lists

plot_df_left <- ranking_bakker_hobolt_econ %>% 
  ungroup() %>% 
  select(CELEX) %>% 
  rename(left = CELEX) %>% 
  # provide each row with an id
  mutate(id_left = row_number())

plot_df_right <- ranking_elo %>% 
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
