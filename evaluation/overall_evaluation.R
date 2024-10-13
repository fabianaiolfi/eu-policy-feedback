
# Overall Evaluation -----------------------------------
# Comparing different automated methods with expert scores


## Load data -----------------------

nanou_2017_rf <- readRDS(here("existing_measurements", "nanou_2017", "nanou_2017_rf.rds")) # Averaged expert measurements from extract_expert_measurements.R
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
ceps_eurlex <- ceps_eurlex %>% slice_sample(n = 50)


## Merge Subject Matter and Broad Policy Area from Nanou 2017 -----------------------

# source(here("evaluation", "policy_area_subj_matter.R")) # Run script
policy_area_subj_matter <- readRDS(here("data", "evaluation", "policy_area_subj_matter.rds")) # Load data


## Assign a Policy Area to each Legislation -----------------------
# Based on Subject Matter

# Function to match subject matter terms to broad policy areas, accounting for match frequency
match_policy_area <- function(subject_matter, lookup_df) {
  # Initialize a named vector to store the count of matches per broad policy area
  match_count <- setNames(rep(0, length(unique(lookup_df$broad_policy_area))), 
                          unique(lookup_df$broad_policy_area))
  
  # Loop through each subject matter term in the lookup table
  for (i in seq_along(lookup_df$subject_matter)) {
    if (grepl(lookup_df$subject_matter[i], subject_matter, ignore.case = TRUE)) {
      # Increment the count for the corresponding broad policy area
      match_count[lookup_df$broad_policy_area[i]] <- match_count[lookup_df$broad_policy_area[i]] + 1
    }
  }
  
  # Filter out broad policy areas with no matches
  matched_areas <- match_count[match_count > 0]
  
  # Sort the matched areas by the number of matches in descending order
  matched_areas <- sort(matched_areas, decreasing = TRUE)
  
  # Return the matched broad policy areas in order of frequency
  if (length(matched_areas) == 0) {
    return(NA)  # Return NA if no match is found
  } else {
    return(paste(names(matched_areas), collapse = "; "))
  }
}

ceps_eurlex$broad_policy_area <- sapply(ceps_eurlex$Subject_matter, match_policy_area, lookup_df = policy_area_subj_matter)

ceps_eurlex$broad_policy_area[22]
ceps_eurlex$Subject_matter[22]

#####

temp_df <- ceps_eurlex %>% 
  select(CELEX, Subject_matter)

head(temp_df)

temp_df <- policy_area_subj_matter %>% slice_sample(n=5)
