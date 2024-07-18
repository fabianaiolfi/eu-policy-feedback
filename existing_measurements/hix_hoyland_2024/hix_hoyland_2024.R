
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
df <- ceps_eurlex_dir_reg_sample %>%
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

temp_df <- ceps_eurlex_dir_reg_sample %>% 
  # select celex column and all columns starting with preamble_segment
  select(CELEX, starts_with("preamble_segment")) %>% 
  # convert to long format
  pivot_longer(cols = starts_with("preamble_segment"), names_to = "segment", values_to = "text") %>% 
  drop_na(text) %>% 
  mutate(ManiBERT_label = map_chr(text, ~ ManiBERT_classifier(.x)[[1]]$label))

# "We then use the adjusted categorization of CMP codes provided by Bakker and Hobolt (2013) to identify economic and social left-right sentences, and classify each EU legislation on these two scales separately."

# Table 2.4. Bakker-Hobolt’s modified CMP measures (p. 38)
bakker_hobolt_right_emphases <- c("free enterprise", "economic incentives", "anti-protectionism", "social services limitation", "education limitation", "productivity: positive", "economic orthodoxy: positive", "labour groups: negative")

bakker_hobolt_left_emphases <- c("regulate capitalism", "economic planning", "pro-protectionism", "social services expansion", "education expansion", "nationalization", "controlled economy", "labour groups: positive", "corporatism: positive", "keynesian demand management: positive", "marxist analysis: positive", "social justice")

temp_df <- temp_df %>%
  mutate(ManiBERT_label = tolower(ManiBERT_label)) %>% 
  mutate(bakker_hobolt_label = case_when(ManiBERT_label %in% bakker_hobolt_right_emphases ~ "right",
                                   ManiBERT_label %in% bakker_hobolt_left_emphases ~ "left",
                                   T ~ NA))


# 2. Calculate logit-scaled left-right position -------------------------------------------
# For each piece of legislation, we calculate the logit-scaled left-right position, as proposed by Lowe et al. (2011)

# Lowe et al (2011)
# P. 127: We will denote the number of sentences in a manifesto assigned to the “left” and “right” categories constituting a policy issue as L and R,
# P. 127:  The output any scaling procedure is an estimate of the position which we will refer to as θ [theta]

# A Scaling Method Based on Log Odds-Ratios
# P. 131: θ = log(R + .5) - log(L + .5)
# E.g., `log(13 + .5) - log(7 + .5)`

# Count occurence of each label
# Define function
count_labels <- function(RoBERT_rile_labels, label) {
  str_count(RoBERT_rile_labels, label)
}

# Add new columns for neutral, left, and right counts
df <- df %>%
  mutate(
    neutral = count_labels(RoBERT_rile_labels, "Neutral"),
    left = count_labels(RoBERT_rile_labels, "Left"),
    right = count_labels(RoBERT_rile_labels, "Right"),
    scale = log(right + 0.5) - log(left + 0.5)
  )

# Output
df %>% select(CELEX, scale)
# CELEX       scale
# <chr>       <dbl>
# 1 32011L0095  1.10 
# 2 32006L0123 -0.715
# 3 32003L0088 -2.40 
