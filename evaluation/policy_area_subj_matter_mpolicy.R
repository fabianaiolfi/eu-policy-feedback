
## Load Data -----------------------

ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))
moodley <- read.csv(here("data", "data_collection", "eu_regulations_metadata_1971_2022.csv"), stringsAsFactors = F)


## Extract EuroVoc -----------------------

# unique_terms_ceps_eurlex <- ceps_eurlex %>%
#   pull(EUROVOC) %>% # Pulls the Subject_matter column as a character vector
#   str_split(";") %>% # Splits the string by semicolon
#   unlist() %>% # Unlists all terms into a single vector
#   str_trim() %>% # Trims leading and trailing whitespace from each term
#   unique() # Extracts unique terms

# The 4982 EuroVoc keywords are too detailed to be useful.


## Extract Subject Matter -----------------------

# CEPS Eurlex
unique_terms_ceps_eurlex <- ceps_eurlex %>%
  pull(Subject_matter) %>% # Pulls the Subject_matter column as a character vector
  str_split(";") %>% # Splits the string by semicolon
  unlist() %>% # Unlists all terms into a single vector
  str_trim() %>% # Trims leading and trailing whitespace from each term
  unique() %>% # Extracts unique terms
  tolower() # Lowercase

unique_terms_ceps_eurlex <- as.data.frame(unique_terms_ceps_eurlex)
unique_terms_ceps_eurlex <- unique_terms_ceps_eurlex %>% 
  dplyr::filter(unique_terms_ceps_eurlex != "") %>% 
  dplyr::filter(unique_terms_ceps_eurlex != "NA") %>% 
  dplyr::filter(unique_terms_ceps_eurlex != "character(0)")

# Moodley
unique_terms_moodley <- moodley %>%
  pull(subject_matters) %>% # Pulls the Subject_matter column as a character vector
  str_split("[|,]") %>% # Splits the string
  unlist() %>% # Unlists all terms into a single vector
  str_trim() %>% # Trims leading and trailing whitespace from each term
  unique() %>% # Extracts unique terms
  tolower() # Lowercase

unique_terms_moodley <- as.data.frame(unique_terms_moodley)
unique_terms_moodley <- unique_terms_moodley %>% 
  dplyr::filter(unique_terms_moodley != "") %>% 
  dplyr::filter(unique_terms_moodley != "NA") %>% 
  dplyr::filter(unique_terms_moodley != "character(0)")


## Assign subject matter to broad policy area in Nanou 2017 (via ChatGPT) -----------------

# Broad Policy Areas (EU_Competencies_Index_codebook_v1.pdf, p. 4)
# Economic and Financial Affairs
# Competitiveness
# Employment, Social Policy, Health and Consumer Affairs
# Environment
# Agriculture and Fisheries
# Transport, Telecommunications, Energy
# Education, Youth and Culture
# Justice and Home Affairs
# Foreign and Security policy

policy_area_subj_matter <- data.frame() # Set up empty dataframe

# Economic and Financial Affairs
subject_matter <- c("budget",
                    "EU finance",
                    "economic policy",
                    "economic conditions",
                    "economic structure",
                    "public finance and budget policy",
                    "financial institutions and credit",
                    "financing and investment",
                    "free movement of capital",
                    "prices",
                    "monetary economics",
                    "monetary relations",
                    "national accounts",
                    "taxation",
                    "trade policy",
                    "trade"
                    # "economic analysis",
                    # "consumption",
                    # "competition",
                    # "accounting",
                    # "production",
                    # "insurance",
                    # "business classification",
                    # "international trade",
                    # "tariff policy"
                    )

df <- data.frame(
  mpolicy = "Economic and Financial Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Competitiveness
subject_matter <- c("leather and textile industries",
                    "mechanical engineering",
                    "business organisation",
                    "business classification",
                    "electronics and electrical engineering",
                    "industrial structures and policy",
                    "technology and technical regulations",
                    "research and intellectual property",
                    "distributive trades",
                    "competition"
                    # "construction and town planning",
                    # "management",
                    # "iron, steel and other metal industries",
                    # "miscellaneous industries",
                    # "building and public works",
                    # "marketing",
                    # "wood industry",
                    # "agri-foodstuffs",
                    # "foodstuff",
                    # "food technology",
                    # "processed agricultural produce",
                    # "plant product",
                    # "animal product",
                    # "agricultural structures and production",
                    # "prices"
                    )

df <- data.frame(
  mpolicy = "Competitiveness",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

### Employment, Social Policy, Health and Consumer Affairs
subject_matter <- c("employment",
                    "labour market",
                    "labour law and labour relations",
                    "organisation of work and working conditions",
                    "social protection",
                    "social affairs",
                    "personnel management and staff remuneration",
                    "demography and population",
                    "rights and freedoms",
                    "consumption",
                    "marketing",
                    "health",
                    "social framework"
                    # "family",
                    # "beverages and sugar"
                    )

df <- data.frame(
  mpolicy = "Employment, Social Policy, Health and Consumer Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Environment
subject_matter <- c("deterioration of the environment",
                    "natural environment",
                    "environmental policy",
                    "soft energy"
                    #"chemistry",
                    #"coal and mining industries"
                    )

df <- data.frame(
  mpolicy = "Environment",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Agriculture and Fisheries
subject_matter <- c("agri-foodstuffs",
                    "means of agricultural production",
                    "processed agricultural produce",
                    "plant product",
                    "animal product",
                    "agricultural policy",
                    "cultivation of agricultural land",
                    "fisheries",
                    "farming systems",
                    "agricultural activity",
                    "agricultural structures and production",
                    "forestry"
                    )

df <- data.frame(
  mpolicy = "Agriculture and Fisheries",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Transport, Telecommunications, Energy
subject_matter <- c("air and space transport",
                    "land transport",
                    "maritime and inland waterway transport",
                    "organisation of transport",
                    "transport policy",
                    "energy policy",
                    "oil industry",
                    "electrical and nuclear industries"
                    #"information technology and data processing",
                    #"information and information processing",
                    #"communications",
                    #"technology and technical regulations"
                    )

df <- data.frame(
  mpolicy = "Transport, Telecommunications, Energy",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Education, Youth and Culture
subject_matter <- c("education",
                    "organisation of teaching",
                    "teaching",
                    "culture and religion",
                    "humanities"
                    #"research and intellectual property",
                    #"natural and applied sciences"
                    )

df <- data.frame(
  mpolicy = "Education, Youth and Culture",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

### Justice and Home Affairs
subject_matter <- c("justice",
                    "migration",
                    "civil law",
                    "criminal law",
                    "organisation of the legal system",
                    "rights and freedoms",
                    "electoral procedure and voting",
                    "defence",
                    "family"
                    #"cooperation policy",
                    #"legal form of organisations",
                    #"parliamentary proceedings",
                    #"sources and branches of the law",
                    #"politics and public safety"
                    )

df <- data.frame(
  mpolicy = "Justice and Home Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Foreign and Security Policy
subject_matter <- c(
                    "international security",
                    "United Nations",
                    "international law",
                    "international affairs",
                    "overseas countries and territories",
                    "extra-European organisations",
                    "Africa",
                    "Asia and Oceania",
                    "America",
                    "political geography",
                    "political framework"
                    # "European construction",
                    # "European organisations",
                    # "EU institutions and European civil service",
                    # "regions of EU Member States",
                    # "regions and regional policy",
                    # "world organisations",
                    # "non-governmental organisations",
                    # "political party",
                    # "European Union law",
                    # "parliament",
                    # "executive power and public service",
                    # "cooperation policy"
                    )

df <- data.frame(
  mpolicy = "Foreign and Security Policy",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% 
  rbind(df) %>% # Add to dataframe
  distinct(subject_matter, .keep_all = T) # Clean up duplicates

# Save to file
saveRDS(policy_area_subj_matter, file = here("data", "evaluation", "policy_area_subj_matter_mpolicy.rds"))
