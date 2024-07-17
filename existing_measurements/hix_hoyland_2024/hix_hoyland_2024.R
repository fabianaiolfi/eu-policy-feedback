
# Recreate Hix Hoyland (2024)


# 1. Classification -------------------------------------------
# For each piece of legislation, we classified each sentence in the preamble, until the phrase “Adopted this directive/regulation”, using a RoBERT-classifier trained on the corpus of party manifestos
# We split the preambles into segments of 100 words, and classify each segment as left, neutral, or right

# Load data
ceps_eurlex_dir_reg_sample <- readRDS(file = here("data", "data_collection", "ceps_eurlex_dir_reg_sample.rds"))
set.seed(project_seed)
ceps_eurlex_dir_reg_sample <- ceps_eurlex_dir_reg_sample %>% slice_sample(n = 100, replace = F)

# Get preamble string until “Adopted this directive/regulation”
ceps_eurlex_dir_reg_sample <- ceps_eurlex_dir_reg_sample %>% 
  mutate(preamble = str_extract(act_raw_text, "(?i).*?(?=Adopted this directive|Adopted this regulation)"))

# Split preamble into segments of 100 words
# Define function
split_into_segments <- function(text, segment_size = 100) {
  words <- unlist(str_split(text, "\\s+"))
  segments <- split(words, ceiling(seq_along(words) / segment_size))
  sapply(segments, paste, collapse = " ")
}

# Perform split of preamble segments
ceps_eurlex_dir_reg_sample <- ceps_eurlex_dir_reg_sample %>%
  mutate(preamble_segment = map(preamble, split_into_segments)) %>%
  unnest_wider(preamble_segment, names_sep = "_")

# Classify each segment as left, neutral, or right

# Define the huggingface pipeline
classifier <- hf_load_pipeline(
  task = "text-classification",
  model = "niksmer/RoBERTa-RILE")

# Function to classify text segments and return labels
classify_segments <- function(segments) {
  segments <- segments[!is.na(segments)] # Remove NA segments
  labels <- map(segments, ~ classifier(.x)[[1]]$label) # Classify each segment and extract the label
  paste(labels, collapse = ", ") # Combine labels into a single string
}

# Apply the function to each row and create a new column 'labels'
df <- ceps_eurlex_dir_reg_sample %>%
  rowwise() %>%
  mutate(labels = classify_segments(c_across(starts_with("preamble_segment")))) %>%
  ungroup() %>%
  select(CELEX, labels) # Select only the required columns


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
count_labels <- function(labels, label) {
  str_count(labels, label)
}

# Add new columns for neutral, left, and right counts
df <- df %>%
  mutate(
    neutral = count_labels(labels, "Neutral"),
    left = count_labels(labels, "Left"),
    right = count_labels(labels, "Right")
  )

# Calculate left-right position
df$scale <- log(df$right + .5) - log(df$left + .5)
