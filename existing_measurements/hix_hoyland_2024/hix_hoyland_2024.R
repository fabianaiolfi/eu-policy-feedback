
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
classify_segments <- function(segments) {
  segments <- segments[!is.na(segments)] # Remove NA segments
  RoBERT_rile_labels <- map(segments, ~ RoBERT_classifier(.x)[[1]]$label) # Classify each segment and extract the label
  paste(RoBERT_rile_labels, collapse = ", ") # Combine labels into a single string
}

# Apply the function to each row and create a new column 'labels'
df <- ceps_eurlex_dir_reg_sample %>%
  rowwise() %>%
  mutate(RoBERT_rile_labels = classify_segments(c_across(starts_with("preamble_segment")))) %>%
  ungroup() %>%
  select(CELEX, RoBERT_rile_labels) # Select only the required columns


## ManiBERT: Classifier fine-tuned to identify the CMP policy-issue codes

# Define the huggingface pipeline
ManiBERT_classifier <- hf_load_pipeline(
  task = "text-classification",
  model = "niksmer/ManiBERT")

ManiBERT_classifier("the creation of a Common European Asylum System has now been achieved. The European Council of 4 November 2004 adopted the Hague Programme, which sets the objectives to be implemented in the area of freedom, security and justice in the period 2005-2010. In this respect, the Hague Programme invited the European Commission to conclude the evaluation of the first-phase legal instruments and to submit the second-phase instruments and measures to the European Parliament and the Council, with a view to their adoption before the end of 2010. (8) In the European Pact on Immigration and Asylum, adopted on 15 and")


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
