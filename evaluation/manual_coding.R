
# Manual Coding of Directives/Regulations


# Load data ----------------------

all_data <- readRDS(here("data", "data_collection", "all_data.rds"))
manual_coding <- read_sheet("https://docs.google.com/spreadsheets/d/1DUyJZvo6g-JR3wc8KB_isnWYb_ni92TNK4deeHOm1eU/edit?gid=0#gid=0")


# Create sample ----------------------

manual_sample <- c("31990R0153",
                   "31995R2420",
                   "31990R1216",
                   "32010R0679",
                   "31993R2920",
                   "31991R3235")

all_data_sample <- all_data %>%
  dplyr::filter(CELEX %in% manual_sample) %>% 
  select(-date, -act_string, -act_type, -act_summary, -eurlex_policy_area, -nanou_broad_policy_area, -contains("summary"))

#1 31990R0153: https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:31990R0153&qid=1737798685022
#2 31995R2420: https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:31995R2420&qid=1737798712353
#3 31990R1216: https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:31990R1216&qid=1737798733154
#4 32010R0679: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32010R0679&qid=1737798754141
#5 31993R2920: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A31993R2920&qid=1737798768560
#6 31991R3235: https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:31991R3235&qid=1737798783823


# Import and clean manual codings ----------------------
# From Google Sheets (https://docs.google.com/spreadsheets/d/1DUyJZvo6g-JR3wc8KB_isnWYb_ni92TNK4deeHOm1eU/edit?usp=sharing)

manual_coding <- manual_coding %>% dplyr::select(-...1, -...3, -(19:26))
manual_coding_fa <- manual_coding %>% dplyr::select(...2, 2:6) %>% row_to_names(row_number = 1) %>% dplyr::mutate(Coder = "FA")
manual_coding_af <- manual_coding %>% dplyr::select(...2, 7:11) %>% row_to_names(row_number = 1) %>% dplyr::mutate(Coder = "AF")
manual_coding_gm <- manual_coding %>% dplyr::select(...2, 12:16) %>% row_to_names(row_number = 1) %>% dplyr::mutate(Coder = "GM")
manual_coding <- rbind(manual_coding_fa, manual_coding_af, manual_coding_gm)

manual_coding <- manual_coding %>% 
  dplyr::mutate(across(where(is.list), ~ unlist(.))) %>% 
  tidyr::pivot_longer(
    cols = -c(CELEX, Coder), # All columns except CELEX and Coder
    names_to = "Measurement", # Name for the new column holding original column names
    values_to = "Score"       # Name for the new column holding values
    )

manual_coding_general_lr <- manual_coding %>% 
  dplyr::filter(Measurement == "General LR") %>% 
  dplyr::select(-Measurement) %>% 
  tidyr::pivot_wider(
    names_from = Coder,   # The column whose values become new column names
    values_from = Score   # The column whose values fill the new columns
  ) %>% 
  tibble::column_to_rownames(var = "CELEX")

manual_coding_econ_relevance <- manual_coding %>% 
  dplyr::filter(Measurement == "Economic relevance") %>% 
  dplyr::select(-Measurement) %>% 
  tidyr::pivot_wider(
    names_from = Coder,   # The column whose values become new column names
    values_from = Score   # The column whose values fill the new columns
  ) %>% 
  tibble::column_to_rownames(var = "CELEX")

manual_coding_social_relevance <- manual_coding %>% 
  dplyr::filter(Measurement == "Social relevance") %>% 
  dplyr::select(-Measurement) %>% 
  tidyr::pivot_wider(
    names_from = Coder,   # The column whose values become new column names
    values_from = Score   # The column whose values fill the new columns
  ) %>% 
  tibble::column_to_rownames(var = "CELEX")

manual_coding_economic_lr <- manual_coding %>% 
  dplyr::filter(Measurement == "Economic LR") %>% 
  dplyr::select(-Measurement) %>% 
  tidyr::pivot_wider(
    names_from = Coder,   # The column whose values become new column names
    values_from = Score   # The column whose values fill the new columns
  ) %>% 
  tibble::column_to_rownames(var = "CELEX")

manual_coding_social_lr <- manual_coding %>% 
  dplyr::filter(Measurement == "Social LR") %>% 
  dplyr::select(-Measurement) %>% 
  tidyr::pivot_wider(
    names_from = Coder,   # The column whose values become new column names
    values_from = Score   # The column whose values fill the new columns
  ) %>% 
  tibble::column_to_rownames(var = "CELEX")


# Measure Intraclass Correlation -----------------------
# Source: https://www.datanovia.com/en/lessons/intraclass-correlation-coefficient-in-r/

general_lr <- icc(manual_coding_general_lr, model = "twoway", type = "agreement", unit = "single")$value
econ_relevance <- icc(manual_coding_econ_relevance, model = "twoway", type = "agreement", unit = "single")$value
social_relevance <- icc(manual_coding_social_relevance, model = "twoway", type = "agreement", unit = "single")$value
economic_lr <- icc(manual_coding_economic_lr, model = "twoway", type = "agreement", unit = "single")$value
social_lr <- icc(manual_coding_social_lr, model = "twoway", type = "agreement", unit = "single")$value

message("General LR: ", round(general_lr, 2))
message("Economic Relevance: ", round(econ_relevance, 2))
message("Social Relevance: ", round(social_relevance, 2))
message("Economic LR: ", round(economic_lr, 2))
message("Social LR: ", round(social_lr, 2))

# Interpretation
# below 0.50: poor
# between 0.50 and 0.75: moderate
# between 0.75 and 0.90: good
# above 0.90: excellent

# Manual Coding vs Machines -----------------------

# Attention: Do scores need to be normalised first?

# # Average human coders score
# avg_manual_coding <- manual_coding %>% 
#   dplyr::filter(Measurement != "Economic relevance" & Measurement != "Social relevance") %>% 
#   dplyr::group_by(Measurement, CELEX) %>% 
#   dplyr::summarise(manual_score = mean(Score)) %>% 
#   dplyr::ungroup()
# 
# avg_manual_coding_general_lr <- avg_manual_coding %>% 
#   dplyr::filter(Measurement == "General LR") %>% 
#   dplyr::select(-Measurement) %>% 
#   left_join(all_data_sample, by = "CELEX") %>% 
#   tibble::column_to_rownames(var = "CELEX") %>% 
#   select(manual_score, hix_hoyland_robert_left_right_preamble)
# 
# human_vs_machines_general_lr <- icc(avg_manual_coding_general_lr, model = "twoway", type = "agreement", unit = "single")$value
# 
# avg_manual_coding_econ_lr <- avg_manual_coding %>% 
#   dplyr::filter(Measurement == "Economic LR") %>% 
#   dplyr::select(-Measurement) %>% 
#   left_join(all_data_sample, by = "CELEX") %>% 
#   tibble::column_to_rownames(var = "CELEX") %>% 
#   select(manual_score, hix_hoyland_bakker_hobolt_econ_preamble)
# 
# human_vs_machines_econ_lr <- icc(avg_manual_coding_econ_lr, model = "twoway", type = "agreement", unit = "single")$value
# 
# message("Human vs Machines General LR: ", round(human_vs_machines_general_lr, 2))
# message("Human vs Machines Economic LR: ", round(human_vs_machines_econ_lr, 2))
