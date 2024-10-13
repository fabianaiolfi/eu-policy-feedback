

# Reformatting Nanou 2017 -----------------------

# Aim: Extract expert survey measurements from dataset in order to evaluate our computed measurements


## Load data -----------------------

nanou_2017 <- read_dta(here("existing_measurements", "nanou_2017", "EUcompetencies_expertlevel.dta")) # https://www.eucompetencies.com/data/


## Reformat data -----------------------

# Calculate expert average for each time period and broad policy area

nanou_2017_rf <- nanou_2017 %>% 
  select(
    mpolicy,
    lrscale3_1986_90,
    lrscale3_1991_95,
    lrscale3_1996_2000,
    lrscale3_2001_05,
    lrscale3_2006_10,
    lrscale3_2011_14
  )

nanou_2017_rf <- nanou_2017_rf %>%
  group_by(mpolicy) %>%
  summarise(across(lrscale3_1986_90:lrscale3_2011_14, 
                   ~ mean(.x, na.rm = T), # Calculate mean for each column
                   .names = "{.col}_avg")) %>% # Add "_avg" string to each summarised column
  mutate(mpolicy_name = case_when(mpolicy == 1 ~ "Economic and Financial Affairs",
                                  mpolicy == 2 ~ "Competitiveness",
                                  mpolicy == 3 ~ "Employment, Social Policy, Health and Consumer Affairs",
                                  mpolicy == 5 ~ "Environment",
                                  mpolicy == 6 ~ "Agriculture and Fisheries",
                                  mpolicy == 7 ~ "Transport, Telecommunications, Energy",
                                  mpolicy == 8 ~ "Education, Youth and Culture",
                                  mpolicy == 9 ~ "Justice and Home Affairs",
                                  mpolicy == 10 ~ "Foreign and Security policy"
                                  ))

# Save to file
saveRDS(nanou_2017_rf, file = here("existing_measurements", "nanou_2017", "nanou_2017_rf.rds"))
