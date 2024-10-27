
# Read the data from the text file
lines <- readLines(here("evaluation", "assignments.txt"))

# Initialize empty vectors to store terms and topics
spolicy <- c()
subject_matter <- c()

# Variables to hold the current term
current_term <- ""

# Loop through each line in the file
for (line in lines) {
  # Remove leading and trailing whitespace
  line <- str_trim(line)
  
  # Check if the line contains a term (bold and numbered)
  if (str_detect(line, "^\\d+\\. \\*\\*.*\\*\\*$")) {
    # Extract the term between the bold asterisks
    current_term <- str_extract(line, "\\*\\*(.*?)\\*\\*")
    current_term <- str_replace_all(current_term, "\\*\\*", "") # Remove the asterisks
  } else if (str_detect(line, "^-")) {
    # Extract the topic after the dash
    topic <- str_replace(line, "^-\\s*", "")
    # Append the term and topic to the vectors
    spolicy <- c(spolicy, topic)
    subject_matter <- c(subject_matter, current_term)
  }
}

# Create a dataframe from the vectors
policy_area_subj_matter <- data.frame(spolicy, subject_matter, stringsAsFactors = F)

# Remove "No suitable topic assigned"
policy_area_subj_matter <- policy_area_subj_matter %>% dplyr::filter(spolicy != "*(No suitable topic assigned)*")

# Save to file
saveRDS(policy_area_subj_matter, file = here("data", "evaluation", "policy_area_subj_matter_spolicy.rds"))
