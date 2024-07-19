
# Recreate Hix Hoyland (2024) ------------------------------------

# Load data
ceps_eurlex_dir_reg_sample <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_sample.rds"))
set.seed(project_seed)
ceps_eurlex_dir_reg_sample <- ceps_eurlex_dir_reg_sample %>% slice_sample(n = 100, replace = F)

# Load examples from paper (Table 1, p. 13)
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
examples_paper <- c("32003L0088", "32006L0123", "32011L0095")
ceps_eurlex_dir_reg_sample <- ceps_eurlex %>% dplyr::filter(CELEX %in% examples_paper)

# Preprocessing: "For each piece of legislation, we classified each sentence in the preamble, until the phrase “Adopted this directive/regulation”, using a RoBERT-classifier trained on the corpus of party manifestos"

# Get preamble string until “Adopted this directive/regulation”
ceps_eurlex_dir_reg_sample <- ceps_eurlex_dir_reg_sample %>% 
  mutate(preamble = str_extract(act_raw_text, "(?i).*?(?=Adopted this directive|Adopted this regulation)"))

# "We split the preambles into segments of 100 words…"

# Define split function
split_into_segments <- function(text, segment_size = 100) {
  words <- unlist(str_split(text, "\\s+"))
  segments <- split(words, ceiling(seq_along(words) / segment_size))
  sapply(segments, paste, collapse = " ")
}

# Perform split of preamble segments
ceps_eurlex_dir_reg_sample <- ceps_eurlex_dir_reg_sample %>%
  mutate(preamble_segment = map(preamble, split_into_segments)) %>%
  unnest_wider(preamble_segment, names_sep = "_")


# 1. Classification -------------------------------------------

## RoBERT-classifier trained on the corpus of party manifestos -----------------------

# "We […] classify each segment as left, neutral, or right"

# Define the huggingface pipeline
RoBERT_classifier <- hf_load_pipeline(
  task = "text-classification",
  model = "niksmer/RoBERTa-RILE")

# Function to classify text segments and return labels
RoBERT_classify_segments <- function(segments) {
  segments <- segments[!is.na(segments)] # Remove NA segments
  RoBERT_rile_labels <- map(segments, ~ RoBERT_classifier(.x)[[1]]$label) # Classify each segment and extract the label
  paste(RoBERT_rile_labels, collapse = ", ") # Combine labels into a single string
}

# Apply the function to each row and create a new column 'labels'
RoBERT_df <- ceps_eurlex_dir_reg_sample %>%
  rowwise() %>%
  mutate(RoBERT_rile_labels = RoBERT_classify_segments(c_across(starts_with("preamble_segment")))) %>%
  ungroup() %>%
  select(CELEX, RoBERT_rile_labels) # Select only the required columns


## ManiBERT: Classifier fine-tuned to identify the CMP policy-issue codes

# Define the huggingface pipeline
ManiBERT_classifier <- hf_load_pipeline(
  task = "text-classification",
  model = "niksmer/ManiBERT")

# ManiBERT_classifier(ceps_eurlex_dir_reg_sample$preamble_segment_50[2])[[1]]$label

ManiBERT_df <- ceps_eurlex_dir_reg_sample %>% 
  # Select celex column and all columns starting with preamble_segment
  select(CELEX, starts_with("preamble_segment")) %>% 
  # Convert to long format
  pivot_longer(cols = starts_with("preamble_segment"), names_to = "segment", values_to = "text") %>% 
  drop_na(text) %>% 
  mutate(ManiBERT_label = map_chr(text, ~ ManiBERT_classifier(.x)[[1]]$label))

# "We then use the adjusted categorization of CMP codes provided by Bakker and Hobolt (2013) to identify economic and social left-right sentences, and classify each EU legislation on these two scales separately."

# Table 2.2. CMP left-right dimension (p. 33)
cmp_right <- c("pro-military", "freedom, human rights", "constitutionalism", "effective authority", "free enterprise", "economic incentives", "anti-protectionism", "economic orthodoxy", "social services limitation", "national way of life", "traditional morality", "law and order", "social harmony")

cmp_left <- c("decolonization", "anti-military", "peace", "internationalism", "democracy", "regulate capitalism", "economic planning", "pro-protectionism", "controlled economy", "nationalization", "social services expansion", "education expansion", "pro-labour")

# Table 2.4. Bakker-Hobolt’s modified CMP measures (p. 38)
bakker_hobolt_econ_right <- c("free enterprise", "economic incentives", "anti-protectionism", "social services limitation", "education limitation", "productivity: positive", "economic orthodoxy: positive", "labour groups: negative")

bakker_hobolt_econ_left <- c("regulate capitalism", "economic planning", "pro-protectionism", "social services expansion", "education expansion", "nationalization", "controlled economy", "labour groups: positive", "corporatism: positive", "keynesian demand management: positive", "marxist analysis: positive", "social justice")

bakker_hobolt_authoritarian <- c("political authority", "national way of life: positive", "traditional morality: positive", "law and order", "multiculturalism: negative", "social harmony")

bakker_hobolt_libertarian <- c("environmental protection", "national way of life: negative", "traditional morality: negative", "culture", "multiculturalism: positive", "anti-growth", "underprivileged minority groups", "non-economic demographic groups: positive", "freedom-human rights", "democracy")

# Convert ManiBERT_label to CMP and Bakker Hobolt label
ManiBERT_df <- ManiBERT_df %>%
  mutate(ManiBERT_label = tolower(ManiBERT_label)) %>% 
  mutate(cmp_label = case_when(ManiBERT_label %in% cmp_right ~ "right",
                               ManiBERT_label %in% cmp_left ~ "left",
                               T ~ NA)) %>% 
  mutate(bakker_hobolt_econ_label = case_when(ManiBERT_label %in% bakker_hobolt_econ_right ~ "right",
                                              ManiBERT_label %in% bakker_hobolt_econ_left ~ "left",
                                              T ~ NA)) %>% 
  mutate(bakker_hobolt_galtan_label = case_when(ManiBERT_label %in% bakker_hobolt_authoritarian ~ "right",
                                                ManiBERT_label %in% bakker_hobolt_libertarian ~ "left",
                                                T ~ NA))

# Bakker Hobolt Economic Scale
bakker_hobolt_econ <- ManiBERT_df %>% 
  select(CELEX, bakker_hobolt_econ_label) %>% 
  # Count label in each group
  group_by(CELEX) %>% 
  count(bakker_hobolt_econ_label) %>% 
  drop_na(bakker_hobolt_econ_label) %>% 
  # Convert to long format with label as columns
  pivot_wider(names_from = bakker_hobolt_econ_label, values_from = n, values_fill = 0) %>% 
  # Explicitly add "right" column
  mutate(right = 0)

# Bakker Hobolt Social Scale
bakker_hobolt_social <- ManiBERT_df %>% 
  select(CELEX, bakker_hobolt_galtan_label) %>% 
  # Count label in each group
  group_by(CELEX) %>% 
  count(bakker_hobolt_galtan_label) %>% 
  # drop_na(bakker_hobolt_galtan_label) %>% 
  # Convert to long format with label as columns
  pivot_wider(names_from = bakker_hobolt_galtan_label, values_from = n, values_fill = 0)# %>% 
  # Explicitly add "right" column
  # mutate(right = 0)

# CMP Scale
cmp <- ManiBERT_df %>% 
  select(CELEX, cmp_label) %>% 
  # Count label in each group
  group_by(CELEX) %>% 
  count(cmp_label) %>% 
  drop_na(cmp_label) %>%
  # Convert to long format with label as columns
  pivot_wider(names_from = cmp_label, values_from = n, values_fill = 0) %>% 
  # Explicitly add "right" column
  mutate(right = 0)


# 2. Calculate logit-scaled left-right position -------------------------------------------
# For each piece of legislation, we calculate the logit-scaled left-right position, as proposed by Lowe et al. (2011)

# Lowe et al (2011)
# P. 127: We will denote the number of sentences in a manifesto assigned to the “left” and “right” categories constituting a policy issue as L and R,
# P. 127:  The output any scaling procedure is an estimate of the position which we will refer to as θ [theta]

# A Scaling Method Based on Log Odds-Ratios
# P. 131: θ = log(R + .5) - log(L + .5)


## RoBERT -------------------------

# Count occurence of each label
# Define function
count_labels <- function(RoBERT_rile_labels, label) {
  str_count(RoBERT_rile_labels, label)
}

# Add new columns for neutral, left, and right counts
RoBERT_df <- RoBERT_df %>%
  mutate(
    neutral = count_labels(RoBERT_rile_labels, "Neutral"),
    left = count_labels(RoBERT_rile_labels, "Left"),
    right = count_labels(RoBERT_rile_labels, "Right"),
    left_right = log(right + 0.5) - log(left + 0.5)
  )

## ManiBERT -------------------------

# Economic Scale
bakker_hobolt_econ <- bakker_hobolt_econ %>% mutate(economic = log(right + 0.5) - log(left + 0.5))

# Social Scale
bakker_hobolt_social <- bakker_hobolt_social %>% mutate(social = log(right + 0.5) - log(left + 0.5))


# Evaluation -------------------------

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


