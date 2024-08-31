# EU Policy Feedback

## Data Sets

[All directives and regulations](https://www.dropbox.com/scl/fi/pk1kt8adgv39880o5pq21/all_dir_reg.rds?rlkey=2zp2ugclhux2jv4gj4dtipgzo&dl=0) (N = 75,570 | .rds | 497.6MB)

| CELEX      | Date_document | act_raw_text                                                         | Act_type |
|------------|---------------|----------------------------------------------------------------------|----------|
| 32019L2121 | 2019-11-27    | "DIRECTIVE (EU) 2019/2121 OF THE EUROPEAN PARLIAMENT AND OF THE CO…" | Directive |
| 32020L0262 | 2019-12-19    | "COUNCIL DIRECTIVE (EU) 2020/262\n\nof 19 December 2019\n\nlaying …" | Directive |
| 32019L1922 | 2019-11-18    | "COMMISSION DIRECTIVE (EU) 2019/1922\n\nof 18 November 2019\n\name…" | Directive |
| 32019L2034 | 2019-11-27    | "DIRECTIVE (EU) 2019/2034 OF THE EUROPEAN PARLIAMENT AND OF THE CO…" | Directive |
| 32019L1995 | 2019-11-21    | "COUNCIL DIRECTIVE (EU) 2019/1995\n\nof 21 November 2019\n\namendi…" | Directive |
| 32021L0338 | 2021-02-16    | "DIRECTIVE (EU) 2021/338 OF THE EUROPEAN PARLIAMENT AND OF THE COU…" | Directive |

[Summaries of all directives and regulations](https://www.dropbox.com/scl/fi/q2fm5su8k02353rmb5li4/all_dir_reg_summaries.rds?rlkey=q34f7y5hwf4ksrvlhvuqvoml2&dl=0) (N = 1637 | .rds | 2.6MB)

| CELEX      | eurlex_summary_clean                                                                                                                        |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| 31989L0117 | "Accounting documents of branches of foreign credit and financial institutions SUMMARY OF: Directive 89/117/EEC — obligations of branches of …" |
| 31989L0130 | "Harmonisation of the compilation of GNP The creation of an additional own resource for the Communities, based on the gross national product …" |
| 31989L0297 | "Motor vehicles with trailers: lateral protection for goods vehicles (until 2014) 1) OBJECTIVE To harmonize the requirements to be met by veh…" |
| 31989L0361 | "Intra-Community trade in pure-bred breeding sheep and goats The European Union (EU) harmonises the rules applicable to the trade in pure-bre…" |
| 31989L0384 | "Health criteria for untreated and heat-treated milk SUMMARY The European Union lays down health criteria for heat-treated milk (pasteurised, …" |
| 31989L0391 | "Health and safety at work — general rules SUMMARY OF: Council Directive 89/391/EEC — measures to improve the safety and health of workers at…" |


| Column Name     | Description                                                                                                                                                          |
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `CELEX`         | Unique CELEX identifier of an act ([more info](https://eur-lex.europa.eu/content/help/faq/celex-number.html))                                                        |
| `Date_document` | Date of the document. The eur-lex.eu website does not provide an explanation of which exact date in the legislative process this represents.                         |
| `act_raw_text`  | The full raw text of the act in one string. Mostly includes: title, recitals, legal articles and annex. Please note that the text of older laws is not always clean. |
| `Act_type`      | Is either "Directive" or "Regulation"                                                                                                                                |
| `eurlex_summary_clean`      | Summary of directive or regulation retrieved from eur-lex.com ([example summary](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:31989L0117&qid=1725090724730)) |

Descriptions provided by the [CEPS EurLex codebook](https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/0EGYWY/RVEJU9&version=2.0).


### Recreating Hix Høyland (2024)
Preview of `hix_hoyland_data.rds` (N = 74,734):

|    CELEX    | RoBERT_left_right | bakker_hobolt_econ | bakker_hobolt_social | cmp_left_right |
|-------------|-------------------|--------------------|----------------------|----------------|
| 32019L2121  |       -4.1108739   |        -2.944439   |       -0.3364722     |    -0.3364722  |
| 32020L0262  |        0.5108256   |         0.000000   |        0.0000000     |     0.0000000  |
| 32019L1922  |       -1.0986123   |         0.000000   |       -2.1972246     |     0.0000000  |
| 32019L2034  |       -4.2046926   |        -1.098612   |       -1.0986123     |    -1.6094379  |
| 32019L1995  |       -1.0986123   |         0.000000   |        0.0000000     |     0.0000000  |
| 32021L0338  |       -3.4339872   |         0.000000   |        0.0000000     |     1.0986123  |

`CELEX`: Unique CELEX identifier of an act ([more info](https://eur-lex.europa.eu/content/help/faq/celex-number.html))
`RoBERT_left_right`: …
`bakker_hobolt_econ`: …
`bakker_hobolt_social`: …
`cmp_left_right`: …

**Minor differences to paper:**
- Non-english texts were not translated into English (see p. 12)
- Did not split on the median word-length if “Adopted this directive/regulation” does not appear (see p. 12)

### LSS
Preview of `glove_polarity_scores_all_dir_reg_econ.rds` (N = 74,734):

| CELEX       | avg_glove_polarity_scores |
|-------------|---------------------------|
| 31989L0083  | 0.398                     |
| 31989L0100  | 0.349                     |
| 31989L0117  | 1.01                      |
| 31989L0130  | 0.431                     |
| 31989L0174  | -0.0563                   |
| 31989L0178  | 0.00868                   |

Preview of `glove_polarity_scores_all_dir_reg_social.rds` (N = 74,734):

| CELEX       | avg_glove_polarity_scores |
|-------------|---------------------------|
| 31989L0083  | 0.440                     |
| 31989L0100  | 0.0452                    |
| 31989L0117  | 0.519                     |
| 31989L0130  | 0.503                     |
| 31989L0174  | -0.669                    |
| 31989L0178  | -0.242                    |


#### Seed Word Selection
- systematic approach: using Wordfish and Wordscores to extract seed words from legislations and from party manifestos


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
