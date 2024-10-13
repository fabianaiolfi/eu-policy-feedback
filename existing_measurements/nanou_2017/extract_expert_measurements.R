

# Reformatting Nanou 2017 -----------------------

# Aim: Extract expert survey measurements from dataset in order to evaluate our computed measurements


## Load data -----------------------

nanou_2017 <- read_dta(here("existing_measurements", "nanou_2017", "EUcompetencies_expertlevel.dta")) # https://www.eucompetencies.com/data/


## Reformat data -----------------------

# Calculate expert average for each time period and broad policy area

nanou_2017_lrscale3 <- nanou_2017 %>% 
  select(
    mpolicy,
    lrscale3_1986_90,
    lrscale3_1991_95,
    lrscale3_1996_2000,
    lrscale3_2001_05,
    lrscale3_2006_10,
    lrscale3_2011_14
  )

nanou_2017_lrscale3 <- nanou_2017_lrscale3 %>%
  group_by(mpolicy) %>%
  summarise(across(lrscale3_1986_90:lrscale3_2011_14, 
                   ~ mean(.x, na.rm = T), # Calculate mean for each column
                   .names = "{.col}_avg")) %>% # Add "_avg" string to each summarised column
  mutate(broad_policy_area = case_when(mpolicy == 1 ~ "Economic and Financial Affairs",
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

nanou_2017_lrscale3 <- nanou_2017_lrscale3 %>% 
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

saveRDS(nanou_2017_lrscale3, file = here("existing_measurements", "nanou_2017", "nanou_2017_lrscale3.rds"))
