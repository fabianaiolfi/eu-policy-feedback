
# Overall Evaluation -----------------------------------
# Comparing different automated methods with expert scores


## Load data -----------------------

nanou_2017 <- read_dta(here("existing_measurements", "nanou_2017", "EUcompetencies_expertlevel.dta")) # https://www.eucompetencies.com/data/
ceps_eurlex <- readRDS(here("data", "data_collection", "ceps_eurlex.rds"))


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

# Assign subject matter to broad policy area in Nanou 2017 (via ChatGPT)

broad_policy_area <- "Economic and Financial Affairs"
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
                    "insurance")

# Create the dataframe
df <- data.frame(
  broad_policy_area = rep(broad_policy_area, length(subject_matter)),
  subject_matter = subject_matter,
  stringsAsFactors = FALSE)


  ### Economic and Financial Affairs
- budget
- EU finance
- financial institutions and credit
- economic policy
- economic conditions
- economic structure
- public finance and budget policy
- economic analysis
- financing and investment
- free movement of capital
- prices
- consumption
- trade policy
- trade
- monetary economics
- monetary relations
- national accounts
- taxation
- competition
- accounting
- production
- insurance

### Competitiveness
- leather and textile industries
- mechanical engineering
- distributive trades
- business organisation
- industrial structures and policy
- construction and town planning
- electronics and electrical engineering
- management
- soft energy
- iron, steel and other metal industries
- miscellaneous industries
- building and public works
- wood industry
- agri-foodstuffs
- foodstuff
- marketing
- food technology
- beverages and sugar
- processed agricultural produce
- plant product
- animal product
- agricultural structures and production

### Employment, Social Policy, Health and Consumer Affairs
- employment
- labour market
- social protection
- social affairs
- health
- rights and freedoms
- demography and population
- organisation of work and working conditions
- personnel management and staff remuneration
- family
- social framework

### Environment
- deterioration of the environment
- natural environment
- environmental policy
- soft energy

### Agriculture and Fisheries
- agricultural policy
- agricultural activity
- cultivation of agricultural land
- farming systems
- forestry
- fisheries
- means of agricultural production

### Transport, Telecommunications, Energy
- air and space transport
- land transport
- oil industry
- organisation of transport
- energy policy
- transport policy
- maritime and inland waterway transport
- electrical and nuclear industries
- information technology and data processing
- information and information processing
- communications
- technology and technical regulations

### Education, Youth and Culture
- education
- teaching
- organisation of teaching
- culture and religion
- humanities

### Justice and Home Affairs
- cooperation policy
- international security
- migration
- justice
- defence
- criminal law
- civil law
- organisation of the legal system
- legal form of organisations
- electoral procedure and voting
- parliamentary proceedings
- rights and freedoms
- sources and branches of the law

### Foreign and Security Policy
- international affairs
- United Nations
- European construction
- European organisations
- EU institutions and European civil service
- regions of EU Member States
- regions and regional policy
- political framework
- world organisations
- extra-European organisations
- non-governmental organisations
- political geography
- political party
- international law
- Asia and Oceania
- Africa
- America
- overseas countries and territories
- European Union law
- parliament
- executive power and public service
- cooperation policy
