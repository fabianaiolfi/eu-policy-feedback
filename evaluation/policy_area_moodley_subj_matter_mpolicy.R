
## Load Data -----------------------

moodley <- read.csv(here("data", "data_collection", "eu_regulations_metadata_1971_2022.csv"), stringsAsFactors = F)


## Extract Subject Matter -----------------------

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


## Assign subject matter to broad policy area in Nanou 2017 (via ChatGPT o1 (241229)) -----------------

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
subject_matter <- c("own resources",
                    "financial provisions",
                    "provisions governing the institutions",
                    "financial provisions ecsc",
                    "levies and loans",
                    "loans contracted by the ecsc",
                    "budget",
                    "economic policy",
                    "conjunctural policy",
                    "balance of payments",
                    "free movement of capital",
                    "investments",
                    "economic and monetary union",
                    "monetary measures in the field of agriculture",
                    "european investment bank (eib)",
                    "capital of the ecb",
                    "european central bank (ecb)",
                    "euro",
                    "minimum reserves",
                    "monetary income",
                    "monetary policy instruments",
                    "monetary policy and operations",
                    "means of payment and currency matters",
                    "capital requirements",
                    "financial accounts",
                    "ecb institutional provisions",
                    "banking supervision",
                    "financial market stability",
                    "foreign reserves",
                    "coin issuance",
                    "monetary financing prohibition",
                    "supervisory fees",
                    "supervisory powers and tasks",
                    "microprudential tasks",
                    "organisational principles",
                    "financial institutions and markets statistics",
                    "payment and settlement systems",
                    "auditing",
                    "accounting and reporting",
                    "financial assistance",
                    "target2-securities (t2s)"
                    )

df <- data.frame(
  mpolicy = "Economic and Financial Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Competitiveness
subject_matter <- c("competition",
                    "agreements",
                    "decisions and concerted practices",
                    "agreements and concentrations",
                    "dominant position",
                    "state aids",
                    "internal market - principles",
                    "approximation of laws",
                    "harmonisation of laws",
                    "technical barriers",
                    "free movement of goods",
                    "freedom to provide services",
                    "freedom of establishment",
                    "public procurement in the european union",
                    "public procurement",
                    "small and medium-sized enterprises",
                    "industry",
                    "industrial policy",
                    "lifting and mechanical handling appliances",
                    "motor vehicles",
                    "construction products",
                    "machinery",
                    "cableways",
                    "personal protective equipment",
                    "gas appliances",
                    "pressure vessels",
                    "electrical and radio equipment",
                    "marine equipment",
                    "tourism",
                    "research and technological development",
                    "scientific and technical information and documentation",
                    "technology",
                    "intellectual property",
                    "concentrations between undertakings",
                    "block exemption regulations",
                    "temporary framework",
                    "compatibility rules",
                    "administrative cooperation",
                    "trade statistics",
                    "procurement"
                    )

df <- data.frame(
  mpolicy = "Competitiveness",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

### Employment, Social Policy, Health and Consumer Affairs
subject_matter <- c("european social fund (esf)",
                    "social provisions",
                    "social security for migrant workers",
                    "staff regulations and employment conditions - ec",
                    "public health",
                    "health and safety",
                    "consumer protection",
                    "safety at work and elsewhere",
                    "anti-discrimination",
                    "eur foundation improvement of living and working conditions",
                    "vocational training and youth",
                    "employment",
                    "medical devices",
                    "animal disease control",
                    "zoonosis control",
                    "veterinary legislation",
                    "veterinary checks",
                    "feed – products and hygiene",
                    "food – hygiene",
                    "food – ingredients",
                    "food – other",
                    "food – general",
                    "official controls",
                    "social policy",
                    "safety at work and elsewhere",
                    "eur foundation improvement of living and working conditions"
                    )

df <- data.frame(
  mpolicy = "Employment, Social Policy, Health and Consumer Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Environment
subject_matter <- c("environment",
                    "forestry",
                    "pollution",
                    "waste",
                    "plant health",
                    "plant health legislation",
                    "conservation of marine biological resources"
                    )

df <- data.frame(
  mpolicy = "Environment",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Agriculture and Fisheries
subject_matter <- c("pigmeat",
                    "european agricultural guidance and guarantee fund (eaggf)",
                    "seeds and seedlings",
                    "cereals",
                    "sugar",
                    "milk products",
                    "agriculture and fisheries",
                    "oils and fats",
                    "agricultural structures",
                    "fisheries policy",
                    "wine",
                    "tobacco",
                    "flax and hemp",
                    "fruit and vegetables",
                    "beef and veal",
                    "rice",
                    "silkworms",
                    "hops",
                    "dry fodder",
                    "potatoes",
                    "peas and field beans",
                    "eggs and poultry",
                    "sheepmeat and goatmeat",
                    "processed fruit and vegetables",
                    "monetary measures in the field of agriculture",
                    "common organisation of agricultural markets",
                    "fisheries and aquaculture",
                    "feed – products and hygiene",
                    "veterinary legislation",
                    "veterinary checks",
                    "animal feedingstuffs",
                    "animal disease control",
                    "zoonosis control",
                    "plant health",
                    "plant health legislation",
                    "plant reproductive material",
                    "cotton",
                    "cocoa",
                    "bananas",
                    "agricultural structural funds",
                    "conservation of marine biological resources",
                    "plant varieties",
                    "rabbit meat and farmed game meat"
                    )

df <- data.frame(
  mpolicy = "Agriculture and Fisheries",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Transport, Telecommunications, Energy
subject_matter <- c("transport",
                    "telecommunications",
                    "energy",
                    "nuclear common market",
                    "fuels",
                    "trans-european networks",
                    "energy efficiency",
                    "rail transport",
                    "gas appliances"
                    )

df <- data.frame(
  mpolicy = "Transport, Telecommunications, Energy",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Education, Youth and Culture
subject_matter <- c("education",
                    "vocational training and youth",
                    "culture",
                    "copyright and related rights"
                    )

df <- data.frame(
  mpolicy = "Education, Youth and Culture",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

### Justice and Home Affairs
subject_matter <- c("justice and home affairs",
                    "asylum policy",
                    "immigration and asylum policy",
                    "border checks",
                    "area of freedom, security and justice",
                    "judicial cooperation in civil matters",
                    "judicial cooperation in criminal matters",
                    "police cooperation",
                    "data protection",
                    "human rights",
                    "fundamental rights",
                    "protection of the euro"
                    )

df <- data.frame(
  mpolicy = "Justice and Home Affairs",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% rbind(df) # Add to dataframe

# Foreign and Security Policy
subject_matter <- c("foreign and security policy",
                    "external relations",
                    "development cooperation",
                    "food aid",
                    "commercial policy",
                    "protective measures",
                    "customs union",
                    "harmonisation of customs law: community transit",
                    "customs duties: national tariff quotas",
                    "customs duties: authorisation to defer application of cct",
                    "customs duties: community tariff quotas",
                    "customs duties: speed-up decisions",
                    "common customs tariff",
                    "cct: derogations",
                    "cct: franchise",
                    "association agreement",
                    "preferential systems",
                    "quotas - third countries",
                    "dumping",
                    "general agreement on tariffs and trade (gatt)",
                    "overseas countries and territories",
                    "efta (european free trade association)",
                    "european free trade association (efta)",
                    "harmonisation of customs law: origin of goods",
                    "harmonisation of customs law: warehouses",
                    "harmonisation of customs law: inward processing",
                    "harmonisation of customs law: value for customs purposes",
                    "harmonisation of customs law: customs territory",
                    "free zones",
                    "external action by the union",
                    "international agreements",
                    "world trade organization",
                    "trade defence instruments",
                    "african caribbean and pacific states (acp)",
                    "associated african states and madagascar",
                    "banana trade",
                    "humanitarian aid",
                    "foreign reserves",
                    "financial and technical cooperation with third countries",
                    "integration of the german democratic republic (gdr)",
                    "non-trade agreement",
                    "accession",
                    "accession to agreement",
                    "regulation on bilateral safeguards"
                    )

df <- data.frame(
  mpolicy = "Foreign and Security Policy",
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)

policy_area_subj_matter <- policy_area_subj_matter %>% 
  rbind(df) %>% # Add to dataframe
  distinct(subject_matter, .keep_all = T) # Clean up duplicates

# Save to file
saveRDS(policy_area_subj_matter, file = here("data", "evaluation", "policy_area_moodley_subj_matter_mpolicy.rds"))
