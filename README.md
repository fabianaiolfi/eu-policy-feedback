# EU Policy Feedback

## Data Sets

### [All directives and regulations](https://www.dropbox.com/scl/fi/pk1kt8adgv39880o5pq21/all_dir_reg.rds?rlkey=2zp2ugclhux2jv4gj4dtipgzo&dl=0)
N = 75,570 | .rds | 497.6MB

| CELEX      | Date_document | act_raw_text                                                         | Act_type |
|------------|---------------|----------------------------------------------------------------------|----------|
| 32019L2121 | 2019-11-27    | "DIRECTIVE (EU) 2019/2121 OF THE EUROPEAN PARLIAMENT AND OF THE CO…" | Directive |
| 32020L0262 | 2019-12-19    | "COUNCIL DIRECTIVE (EU) 2020/262\n\nof 19 December 2019\n\nlaying …" | Directive |
| 32019L1922 | 2019-11-18    | "COMMISSION DIRECTIVE (EU) 2019/1922\n\nof 18 November 2019\n\name…" | Directive |

### [Summaries of all directives and regulations](https://www.dropbox.com/scl/fi/q2fm5su8k02353rmb5li4/all_dir_reg_summaries.rds?rlkey=q34f7y5hwf4ksrvlhvuqvoml2&dl=0)
N = 1637 | .rds | 2.6MB

| CELEX      | eurlex_summary_clean                                                                                                                        |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| 31989L0117 | "Accounting documents of branches of foreign credit and financial institutions SUMMARY OF: Directive 89/117/EEC — obligations of branches of …" |
| 31989L0130 | "Harmonisation of the compilation of GNP The creation of an additional own resource for the Communities, based on the gross national product …" |
| 31989L0297 | "Motor vehicles with trailers: lateral protection for goods vehicles (until 2014) 1) OBJECTIVE To harmonize the requirements to be met by veh…" |

### [Hix Høyland data: All directives and regulations](https://www.dropbox.com/scl/fi/asaxyfvma4xd9o7kzpnj7/hix_hoyland_data.rds?rlkey=iwklhk49pnn8h97x8si3uujwj&dl=0)
N = 74,734 | .rds | 301KB

|    CELEX    | RoBERT_left_right | bakker_hobolt_econ | bakker_hobolt_social | cmp_left_right |
|-------------|-------------------|--------------------|----------------------|----------------|
| 32019L2121  |       -4.1108739   |        -2.944439   |       -0.3364722     |    -0.3364722  |
| 32020L0262  |        0.5108256   |         0.000000   |        0.0000000     |     0.0000000  |
| 32019L1922  |       -1.0986123   |         0.000000   |       -2.1972246     |     0.0000000  |

### [Hix Høyland data: Summaries](https://www.dropbox.com/scl/fi/wfr20zn2ex9xtbck7svhd/hix_hoyland_data_summaries.rds?rlkey=om1zp6bll7gv3b19h48gm2ru8&dl=0)
N = 1637 | .rds | 10KB

| CELEX      | RoBERT_left_right | bakker_hobolt_econ | bakker_hobolt_social | cmp_left_right |
|------------|-------------------|-------------------|----------------------|----------------|
| 31989L0117 | -1.6094379        | 0.000000          | 0.0000000            | 0.0000000      |
| 31989L0130 | 0.0000000         | 0.000000          | -1.0986123           | 0.0000000      |
| 31989L0297 | 0.0000000         | 0.000000          | -1.9459101           | 0.0000000      |

**Minor differences to paper:**
- Non-english texts were not translated into English (see p. 12)
- Did not split on the median word-length if “Adopted this directive/regulation” does not appear (see p. 12)

### [LSS: Economic Seed Words](https://www.dropbox.com/scl/fi/xivjtmasr72vmat8mqsih/glove_polarity_scores_all_dir_reg_econ.rds?rlkey=32zmjd08rm9669iww691bd8ls&dl=0)
N = 74,734 | .rds | 663KB

| CELEX       | avg_glove_polarity_scores |
|-------------|---------------------------|
| 31989L0083  | 0.398                     |
| 31989L0100  | 0.349                     |
| 31989L0117  | 1.01                      |

### [LSS: Social Seed Words](https://www.dropbox.com/scl/fi/496oc0pjyk1g4zqyvzrs2/glove_polarity_scores_all_dir_reg_social.rds?rlkey=idcspqo4bun8mznzstlzxljp6&dl=0)
N = 74,734 | .rds | 663KB

| CELEX       | avg_glove_polarity_scores |
|-------------|---------------------------|
| 31989L0083  | 0.440                     |
| 31989L0100  | 0.0452                    |
| 31989L0117  | 0.519                     |


### Column Descriptions

| Column Name     | Description                                                                                                                                                          |
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `act_raw_text`  | The full raw text of the act in one string. Mostly includes: title, recitals, legal articles and annex. Please note that the text of older laws is not always clean. (1) |
| `Act_type`      | Is either "Directive" or "Regulation"                                                                                                                                |
| `avg_glove_polarity_scores` (Economic and Social) | LSS score. Negative values: Right; Positive values: Left |
| `bakker_hobolt_econ` | Economic left-right classification based on [Bakker and Hobolt (2013), p. 38](https://www.dropbox.com/scl/fi/htb19lqo8g41l4hxusy34/bakker_hobolt_2013_chapter.pdf?rlkey=l9ofp62s38b73wxu4xpdk2wm0&dl=0)'s modified CMP measures. Negative values: Left; Positive values: Right |
| `bakker_hobolt_social` | Social left-right classification based on [Bakker and Hobolt (2013), p. 38](https://www.dropbox.com/scl/fi/htb19lqo8g41l4hxusy34/bakker_hobolt_2013_chapter.pdf?rlkey=l9ofp62s38b73wxu4xpdk2wm0&dl=0)'s modified CMP measures. Negative values: Left; Positive values: Right |
| `CELEX`         | Unique CELEX identifier of an act ([more info](https://eur-lex.europa.eu/content/help/faq/celex-number.html) (1))                                                        |
| `cmp_left_right` | Comparative Manifesto Project left-right dimension based on [Bakker and Hobolt (2013), p. 33](https://www.dropbox.com/scl/fi/htb19lqo8g41l4hxusy34/bakker_hobolt_2013_chapter.pdf?rlkey=l9ofp62s38b73wxu4xpdk2wm0&dl=0). Negative values: Left; Positive values: Right |
| `Date_document` | Date of the document. The eur-lex.eu website does not provide an explanation of which exact date in the legislative process this represents. (1) |
| `eurlex_summary_clean` | Summary of directive or regulation retrieved from eur-lex.com ([example summary](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:31989L0117&qid=1725090724730)) |
| `RoBERT_left_right` | Party Manifestos Project Right-Left (RILE) classification. Negative values: Left; Positive values: Right |

(1) Source: [CEPS EurLex codebook](https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/0EGYWY/RVEJU9&version=2.0)

--------

## General To Do
- [ ] How to disregard / ignore laws that are *not* relevant? E.g. a law on abortion has no economic left-right ideology → One possible approach could be using a policy’s tags. Are there tags that indicate that a policy can be ignored?

## Data Collection 1989 – Today
- [x] CEPS EurLex (1952 – 2019)
- [ ] Moodley (1971 – 2022)
- [ ] Scrape summaries
	- [Example](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:32019L0904&qid=1719922563047)
	- [More info](https://eur-lex.europa.eu/browse/summaries.html) 
- [ ] Scrape EUROVOC descriptors ([example](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:32009L0034&qid=1720174976038))

### To Do
- [ ] Which laws have summaries? When does the EU decide to summarise a legislation? Are more recent policies more likely to be summarised?

## Latent Semantic Scaling (LSS)
- LSS is a method to measure the semantic similarity of terms to a set of seed words
- Manual: https://koheiw.github.io/LSX/articles/pkgdown/basic.html

### To Do 
- [x] Compare outcome between use of sentences and use of paragraphs ([link to script](https://github.com/fabianaiolfi/eu-policy-feedback/blob/25eb77853a3c13fc64313bf19f83ab684a378693/lss/01_run_lss.R#L23)) → No discernible difference in outcome
- [x] What is the subject matter "marketing"?
- [x] Perform LSS "background" checks, i.e., synonyms for seed words
- [ ] Create different set of seed words, find a way to document differences in outcome
- [ ] Continue here: Complete evaluation with new, bigger dataset that includes Regulations: Examine correlations
- [ ] Perform evaluation with scraped EUROVOC descriptors
- [ ] Replace NA tags/descriptors with generated descriptors
- [ ] Alternative seed words
  - [ ] "Yet, at different points in time, the legislative institutions have delivered more “rightwing” policies, such as market deregulation, and at other times more “leftwing” policies, such as higher environmental and labour market standards." (Hix Høyland 2024, 1)
  - [ ] “rile”-index: https://manifesto-project.wzb.eu/down/tutorials/main-dataset

## Embeddings
- Compare policies with existing data
	- EP speeches and party manifestos
	- Policies or laws from another jurisdiction (e.g., UK), where policy author/creater and their political affiliation are known
- Create an embedding for each EP faction and topic (e.g., left-wing and climate issues). Then label each policy with a topic. Then calculate embeddings for each policy and assign the policy to the closest faction based on the issue.

## ChatGPT Approach
- Compare policy summary, preamble (like Hix Høyland (2024)) and entire text to evaluate output
- Approaches
  - 0-shot: Query a single law and ask ChatGPT to place it on a left-right scale. Query must clearly explain economic/social left-right dimension
  - Compare and rank: Comapare two policy and pick the more left one. Then apply Elo ranking.
  - In order to overcome problem that distance between laws is unclear: Somehow combine scores from other techniques in order to retrieve ideological “distance” between laws
  - See also: BradleyTerry algorithm (applied [here](https://onlinelibrary.wiley.com/doi/full/10.1111/ajps.12703))

### To Do
- [ ] Scrape summaries: Are there enough to make this work?
- [ ] Examine different ranking algorithms: https://stackoverflow.com/questions/3937218/comparison-based-ranking-algorithm
- [ ] Implement Elo ranking
	- [ ] Prevent algorithm shortcomings by:
		- [ ] Randomize the Order: Randomly shuffle the order of comparisons multiple times and average the final ratings.
		- [ ] Increase the Number of Comparisons: More comparisons will help stabilize the ratings, reducing the impact of any particular order.
		- [ ] Lower the K-Factor: This reduces the volatility of the ratings but can slow down the adjustment process.
- [ ] Try running an LLM locally
- [x] Use ChatGPT 4o mini

## Systematic Evaluation of all Measurements
- [ ] Compare results amongst themselves and with expert survey (e.g. [this expert survey](https://www.dropbox.com/scl/fi/392u06vxzhz6sqebe5mam/EU_Competencies_Index_codebook_v1.pdf?rlkey=vgbqc57dmxur7rakqpekdswy8&dl=0), data: https://www.eucompetencies.com/data/)
- [ ] How reliable are the summaries compared to the preamble or entire text?
- [ ] Create tags / topics of each document to see if there's a correlation between topics and calculated ideology
- [ ] Compare with existing measurments
- [ ] Compare results with each other
- [ ] Compare results with left-right tags defined by Hix Høyland (2024), p. 33
- [ ] Normalise results between different metrics (e.g., Hix Høyland and ELO Ranking) using standardisation or z-index

## Resources
- https://michalovadek.github.io/eurlex/
- https://eur-lex.europa.eu/
