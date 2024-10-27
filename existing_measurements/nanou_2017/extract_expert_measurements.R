

# Reformatting Nanou 2017 -----------------------

# Aim: Extract expert survey measurements from dataset in order to evaluate our computed measurements


## Load data -----------------------

nanou_2017 <- read_dta(here("existing_measurements", "nanou_2017", "EUcompetencies_expertlevel.dta")) # https://www.eucompetencies.com/data/


## Reformat data (mpolicy) -----------------------

# Calculate expert average for each time period and broad policy area

nanou_2017_mpolicy_lrscale3 <- nanou_2017 %>% 
  select(
    mpolicy,
    lrscale3_1986_90,
    lrscale3_1991_95,
    lrscale3_1996_2000,
    lrscale3_2001_05,
    lrscale3_2006_10,
    lrscale3_2011_14
  )

nanou_2017_mpolicy_lrscale3 <- nanou_2017_mpolicy_lrscale3 %>%
  group_by(mpolicy) %>%
  summarise(across(lrscale3_1986_90:lrscale3_2011_14, 
                   ~ mean(.x, na.rm = T), # Calculate mean for each column
                   .names = "{.col}_avg")) %>% # Add "_avg" string to each summarised column
  mutate(broad_policy_area = case_when(
    mpolicy == 1 ~ "Economic and Financial Affairs",
    mpolicy == 2 ~ "Competitiveness",
    mpolicy == 3 ~ "Employment, Social Policy, Health and Consumer Affairs",
    mpolicy == 5 ~ "Environment",
    mpolicy == 6 ~ "Agriculture and Fisheries",
    mpolicy == 7 ~ "Transport, Telecommunications, Energy",
    mpolicy == 8 ~ "Education, Youth and Culture",
    mpolicy == 9 ~ "Justice and Home Affairs",
    mpolicy == 10 ~ "Foreign and Security policy"
    ))

# Convert from wide to long

nanou_2017_mpolicy_lrscale3 <- nanou_2017_mpolicy_lrscale3 %>% 
  select(-mpolicy) %>% 
  pivot_longer(!broad_policy_area, names_to = "period", values_to = "lrscale3_avg") %>% 
  mutate(period = case_when(
    period == "lrscale3_1986_90_avg" ~ "1986-1990",
    period == "lrscale3_1991_95_avg" ~ "1991-1995",
    period == "lrscale3_1996_2000_avg" ~ "1996-2000",
    period == "lrscale3_2001_05_avg" ~ "2001-2005",
    period == "lrscale3_2006_10_avg" ~ "2006-2010",
    period == "lrscale3_2011_14_avg" ~ "2011-2014",
    TRUE ~ NA_character_))


## Save to file ----------------

saveRDS(nanou_2017_lrscale3, file = here("existing_measurements", "nanou_2017", "nanou_2017_mpolicy_lrscale3.rds"))


## Reformat data (spolicy) -----------------------

# Calculate expert average for each time period and broad policy area

nanou_2017_spolicy_lrscale3 <- nanou_2017 %>% 
  select(
    spolicy,
    lrscale3_1986_90,
    lrscale3_1991_95,
    lrscale3_1996_2000,
    lrscale3_2001_05,
    lrscale3_2006_10,
    lrscale3_2011_14
  )

nanou_2017_spolicy_lrscale3 <- nanou_2017_spolicy_lrscale3 %>%
  group_by(spolicy) %>%
  summarise(across(lrscale3_1986_90:lrscale3_2011_14, 
                   ~ mean(.x, na.rm = T), # Calculate mean for each column
                   .names = "{.col}_avg")) %>% # Add "_avg" string to each summarised column
  mutate(broad_policy_area = case_when(
    spolicy == 100 ~ "Economic and Financial Affairs (general)",
    spolicy == 101 ~ "Monetary Policy",
    spolicy == 102 ~ "Macroeconomic Policy",
    spolicy == 103 ~ "Taxation",
    spolicy == 200 ~ "Competitiveness (general)",
    spolicy == 201 ~ "Competition",
    spolicy == 202 ~ "Industry",
    spolicy == 203 ~ "Internal Market: Goods and Services",
    spolicy == 204 ~ "Internal Market: Capital Flows",
    spolicy == 205 ~ "Internal Market: Persons/workers",
    spolicy == 206 ~ "Regional Policy",
    spolicy == 300 ~ "Employment and Social Policy",
    spolicy == 304 ~ "Health and Consumer Protection",
    spolicy == 301 ~ "Work Conditions",
    spolicy == 302 ~ "Labour-Management Relations",
    spolicy == 303 ~ "Social Welfare",
    spolicy == 305 ~ "Public Health",
    spolicy == 306 ~ "Food Safety",
    spolicy == 500 ~ "Environment (general)",
    spolicy == 501 ~ "Climate Change",
    spolicy == 502 ~ "Nature and Biodiversity",
    spolicy == 600 ~ "Agriculture and Fisheries (general)",
    spolicy == 601 ~ "Agriculture",
    spolicy == 602 ~ "Maritime Affairs and Fisheries",
    spolicy == 700 ~ "Transport, Telecommunications, and Energy (general)",
    spolicy == 701 ~ "Transport",
    spolicy == 702 ~ "Telecommunications",
    spolicy == 703 ~ "Energy",
    spolicy == 800 ~ "Education, Youth and Culture (general)",
    spolicy == 801 ~ "Education and Research",
    spolicy == 802 ~ "Cultural Policy",
    spolicy == 900 ~ "Justice and Home Affairs (general)",
    spolicy == 901 ~ "Justice and Property Rights",
    spolicy == 902 ~ "Citizenship and Immigration",
    spolicy == 903 ~ "Police and Public Order",
    spolicy == 1000 ~ "Foreign and Security Policy (general)",
    spolicy == 1001 ~ "Defense and Military Affairs",
    spolicy == 1002 ~ "Diplomacy",
    spolicy == 1003 ~ "External Trade",
    spolicy == 1004 ~ "Humanitarian Aid and Civil Protection",
    spolicy == 1005 ~ "Development Aid"
    ))

# Convert from wide to long

nanou_2017_spolicy_lrscale3 <- nanou_2017_spolicy_lrscale3 %>% 
  select(-spolicy) %>% 
  pivot_longer(!broad_policy_area, names_to = "period", values_to = "lrscale3_avg") %>% 
  mutate(period = case_when(
    period == "lrscale3_1986_90_avg" ~ "1986-1990",
    period == "lrscale3_1991_95_avg" ~ "1991-1995",
    period == "lrscale3_1996_2000_avg" ~ "1996-2000",
    period == "lrscale3_2001_05_avg" ~ "2001-2005",
    period == "lrscale3_2006_10_avg" ~ "2006-2010",
    period == "lrscale3_2011_14_avg" ~ "2011-2014",
    TRUE ~ NA_character_))


## Save to file ----------------

saveRDS(nanou_2017_spolicy_lrscale3, file = here("existing_measurements", "nanou_2017", "nanou_2017_spolicy_lrscale3.rds"))
