
## Load Data -----------------------

ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))


## Extract EuroVoc -----------------------

# unique_terms <- ceps_eurlex %>%
#   pull(EUROVOC) %>% # Pulls the Subject_matter column as a character vector
#   str_split(";") %>% # Splits the string by semicolon
#   unlist() %>% # Unlists all terms into a single vector
#   str_trim() %>% # Trims leading and trailing whitespace from each term
#   unique() # Extracts unique terms

# The 4982 EuroVoc keywords are too detailed to be useful.


## Extract Subject Matter -----------------------

unique_terms <- ceps_eurlex %>%
  pull(Subject_matter) %>% # Pulls the Subject_matter column as a character vector
  str_split(";") %>% # Splits the string by semicolon
  unlist() %>% # Unlists all terms into a single vector
  str_trim() %>% # Trims leading and trailing whitespace from each term
  unique() # Extracts unique terms

unique_terms <- as.data.frame(unique_terms)
unique_terms <- unique_terms %>% 
  dplyr::filter(unique_terms != "") %>% 
  dplyr::filter(unique_terms != "NA") %>% 
  dplyr::filter(unique_terms != "character(0)")


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
                    "financial institutions and credit",
                    "economic policy",
                    "economic conditions",
                    "economic structure",
                    "public finance and budget policy",
                    "economic analysis",
                    "financing and investment",
                    "free movement of capital",
                    "prices",
                    "consumption",
                    "trade policy",
                    "trade",
                    "monetary economics",
                    "monetary relations",
                    "national accounts",
                    "taxation",
                    "competition",
                    "accounting",
                    "production",
                    "insurance",
                    "business classification",
                    "international trade",
                    "tariff policy")

df <- data.frame(
  broad_policy_area = "Economic and Financial Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Competitiveness
subject_matter <- c("leather and textile industries",
                    "mechanical engineering",
                    "distributive trades",
                    "business organisation",
                    "industrial structures and policy",
                    "construction and town planning",
                    "electronics and electrical engineering",
                    "management",
                    "iron, steel and other metal industries",
                    "miscellaneous industries",
                    "building and public works",
                    "marketing",
                    "wood industry",
                    "agri-foodstuffs",
                    "foodstuff",
                    "food technology",
                    "processed agricultural produce",
                    "plant product",
                    "animal product",
                    "agricultural structures and production")

df <- data.frame(
  broad_policy_area = "Competitiveness",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

### Employment, Social Policy, Health and Consumer Affairs
subject_matter <- c("employment",
                    "labour market",
                    "social protection",
                    "social affairs",
                    "health",
                    "rights and freedoms",
                    "demography and population",
                    "organisation of work and working conditions",
                    "personnel management and staff remuneration",
                    "family",
                    "social framework",
                    "labour law and labour relations",
                    "beverages and sugar")

df <- data.frame(
  broad_policy_area = "Employment, Social Policy, Health and Consumer Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Environment
subject_matter <- c("deterioration of the environment",
                    "natural environment",
                    "environmental policy",
                    "soft energy",
                    "chemistry",
                    "coal and mining industries")

df <- data.frame(
  broad_policy_area = "Environment",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Agriculture and Fisheries
subject_matter <- c("agricultural policy",
                    "agricultural activity",
                    "cultivation of agricultural land",
                    "farming systems",
                    "forestry",
                    "fisheries",
                    "means of agricultural production")

df <- data.frame(
  broad_policy_area = "Agriculture and Fisheries",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Transport, Telecommunications, Energy
subject_matter <- c("air and space transport",
                    "land transport",
                    "oil industry",
                    "organisation of transport",
                    "energy policy",
                    "transport policy",
                    "maritime and inland waterway transport",
                    "electrical and nuclear industries",
                    "information technology and data processing",
                    "information and information processing",
                    "communications",
                    "technology and technical regulations")

df <- data.frame(
  broad_policy_area = "Transport, Telecommunications, Energy",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Education, Youth and Culture
subject_matter <- c("education",
                    "teaching",
                    "organisation of teaching",
                    "culture and religion",
                    "humanities",
                    "research and intellectual property",
                    "natural and applied sciences")

df <- data.frame(
  broad_policy_area = "Education, Youth and Culture",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

### Justice and Home Affairs
subject_matter <- c("cooperation policy",
                    "international security",
                    "migration",
                    "justice",
                    "defence",
                    "criminal law",
                    "civil law",
                    "organisation of the legal system",
                    "legal form of organisations",
                    "electoral procedure and voting",
                    "parliamentary proceedings",
                    "rights and freedoms",
                    "sources and branches of the law",
                    "politics and public safety")

df <- data.frame(
  broad_policy_area = "Justice and Home Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Foreign and Security Policy
subject_matter <- c("international affairs",
                    "United Nations",
                    "European construction",
                    "European organisations",
                    "EU institutions and European civil service",
                    "regions of EU Member States",
                    "regions and regional policy",
                    "political framework",
                    "world organisations",
                    "extra-European organisations",
                    "non-governmental organisations",
                    "political geography",
                    "political party",
                    "international law",
                    "Asia and Oceania",
                    "Africa",
                    "America",
                    "overseas countries and territories",
                    "European Union law",
                    "parliament",
                    "executive power and public service",
                    "cooperation policy"
)

df <- data.frame(
  broad_policy_area = "Foreign and Security Policy",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% 
  rbind(df) %>% # Add to dataframe
  distinct(subject_matter, .keep_all = T) # Clean up duplicates

# Save to file
saveRDS(policy_area_subj_matter, file = here("data", "evaluation", "policy_area_subj_matter.rds"))
