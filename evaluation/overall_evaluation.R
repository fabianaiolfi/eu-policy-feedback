
# Overall Evaluation -----------------------------------

# Comparing different automated methods with expert scores


## Load data -----------------------

nanou_2017_lrscale3 <- readRDS(here("existing_measurements", "nanou_2017", "nanou_2017_lrscale3.rds")) # Averaged expert measurements from extract_expert_measurements.R
all_dir_reg <- readRDS(here("data", "data_collection", "all_dir_reg.rds"))
all_dir_reg <- all_dir_reg %>% slice_sample(n = 50)

# source(here("evaluation", "policy_area_subj_matter.R")) # Run script
policy_area_subj_matter <- readRDS(here("data", "evaluation", "policy_area_subj_matter.rds")) # Load data

glove_polarity_scores_all_dir_reg_econ <- readRDS(here("data", "lss", "glove_polarity_scores_all_dir_reg_econ.rds"))

# Add Subject Matter to all_dir_reg
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
ceps_eurlex <- ceps_eurlex %>% select(CELEX, Subject_matter)
all_dir_reg <- all_dir_reg %>% left_join(ceps_eurlex, by = "CELEX")


## Connect a Law's Subject Matter with the Broad Policy Area from Nanou 2017 -----------------------

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

all_dir_reg$broad_policy_area <- sapply(all_dir_reg$Subject_matter, match_policy_area, lookup_df = policy_area_subj_matter)


## Calculate Averages per Time Period and Broad Policy Area ---------------------------------

# Create a dataframe that allows us to calculate the average score per time period and broad policy area

# Preprocess data and add calculated scores
broad_policy_avg_df <- all_dir_reg %>% 
  select(CELEX, Date_document, broad_policy_area) %>% 
  mutate(year = as.numeric(format(Date_document, "%Y"))) %>% 
  select(-Date_document) %>% 
  drop_na(broad_policy_area) %>% 
  separate_rows(broad_policy_area, sep = "; ") %>% # Place each Broad Policy Area on its own row
  # Add calculated scores
  left_join(glove_polarity_scores_all_dir_reg_econ, by = "CELEX") %>% 
  rename(lss_econ = avg_glove_polarity_scores)# %>% 
  ## Add other scores here later ##

# Calcualate averages based on time periods
broad_policy_avg_df <- broad_policy_avg_df %>%
  mutate(period = case_when(
    year %in% 1989:1990 ~ "1989-1990",
    year %in% 1991:1995 ~ "1991-1995",
    year %in% 1996:2000 ~ "1996-2000",
    year %in% 2001:2005 ~ "2001-2005",
    year %in% 2006:2010 ~ "2006-2010",
    year %in% 2011:2014 ~ "2011-2014",
    year %in% 2014:2024 ~ "2014-2024",
    TRUE ~ NA_character_)) %>% 
  drop_na(period) %>%
  group_by(broad_policy_area, period) %>%
  summarise(avg_lss_econ = mean(lss_econ, na.rm = T), .groups = "drop")


## CONTINUE HERE ##
# - normalise different scores
# - add all calculated scores (both LSS, Hix Hoyland, etc)
# - compare with Nanou 2017 (ie expert survey)

temp_df <- broad_policy_avg_df %>% 
  left_join(nanou_2017_lrscale3, by = c("broad_policy_area", "period"))
