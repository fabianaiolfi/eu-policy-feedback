# EU Policy Feedback

## Reports

- [NLP Report](https://github.com/fabianaiolfi/eu-policy-feedback/blob/main/reports/240830_report.html): Overview of the available data, first results using LSS and ChatGPT 0-shot
- [Evaluation and Comparison with Ground Truth](https://github.com/fabianaiolfi/eu-policy-feedback/blob/main/evaluation/250111_evaluation_report.html): How well do different methods compare to a ground truth dataset?

## Data Sets

### [All data](https://www.dropbox.com/s/oo24muau2uxg75e/all_data.rds?dl=0)
N = 74,733 | .rds | 497.6MB

Also available as a [CSV](https://www.dropbox.com/scl/fi/e4e6lw6nwcgx280369kjg/all_data.csv?rlkey=gk0b2kdgsu2q4ig9kpjq0a7lr&dl=0)

| **Category**              | **Column Name**                               | **Description**                                       |
|:--------------------------|--------------------------------------------|-------------------------------------------------------|
| **Meta Information**      | CELEX                                     | Unique ID                                            |
|                           | date                                      | Date of document                                     |
|                           | act_string                                | Full raw text of the act in one string              |
|                           | act_type                                  | Directive or regulation                              |
|                           | act_summary                               | Summary if available                                 |
|                           | eurlex_policy_area                        | EURLEX subject matter                                |
|                           | nanou_broad_policy_area                   | Broad policy area based on Nanou, Zapryanova, and Toth (2017) |
| **Hix and Høyland (2024)**| hix_hoyland_robert_left_right_preamble    |                                                     |
|                           | hix_hoyland_bakker_hobolt_econ_preamble   |                                                     |
|                           | hix_hoyland_bakker_hobolt_social_preamble |                                                     |
|                           | hix_hoyland_cmp_left_right_preamble       |                                                     |
|                           | hix_hoyland_robert_left_right_summary     |                                                     |
|                           | hix_hoyland_bakker_hobolt_econ_summary    |                                                     |
|                           | hix_hoyland_bakker_hobolt_social_summary  |                                                     |
|                           | hix_hoyland_cmp_left_right_summary        |                                                     |
| **LSS Methods**           | lss_econ_preamble                        |                                                     |
|                           | lss_social_preamble                      |                                                     |
|                           | lss_econ_summary                         |                                                     |
|                           | lss_social_summary                       |                                                     |
| **LLM Methods**           | chatgpt_0_shot_econ_preamble             |                                                     |
|                           | chatgpt_0_shot_econ_summary              |                                                     |
|                           | llama_0_shot_econ_preamble               | Note: Does not cover all documents                  |
|                           | llama_0_shot_econ_summary                |                                                     |
|                           | chatgpt_ranking_econ_summary_z_score     |                                                     |
|                           | llama_ranking_econ_summary_z_score       |                                                     |
|                           | deepseek_ranking_econ_summary_z_score    |                                                     |
|                           | deepseek_ranking_social_summary_z_score  |                                                     |
|                           | deepseek_0_shot_econ_summary             |                                                     |
|                           | deepseek_0_shot_social_summary           |                                                     |


Please note that ranking scores have already been converted to z-scores. 

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

### [Hix Høyland method: All directives and regulations](https://www.dropbox.com/scl/fi/asaxyfvma4xd9o7kzpnj7/hix_hoyland_data.rds?rlkey=iwklhk49pnn8h97x8si3uujwj&dl=0)
N = 74,734 | .rds | 301KB  
`>0`: More right  
`<0`: More left  

|    CELEX    | RoBERT_left_right | bakker_hobolt_econ | bakker_hobolt_social | cmp_left_right |
|-------------|-------------------|--------------------|----------------------|----------------|
| 32019L2121  |       -4.1108739   |        -2.944439   |       -0.3364722     |    -0.3364722  |
| 32020L0262  |        0.5108256   |         0.000000   |        0.0000000     |     0.0000000  |
| 32019L1922  |       -1.0986123   |         0.000000   |       -2.1972246     |     0.0000000  |

### [Hix Høyland method: Summaries](https://www.dropbox.com/scl/fi/wfr20zn2ex9xtbck7svhd/hix_hoyland_data_summaries.rds?rlkey=om1zp6bll7gv3b19h48gm2ru8&dl=0)
N = 1637 | .rds | 10KB  
`>0`: More right  
`<0`: More left  

| CELEX      | RoBERT_left_right | bakker_hobolt_econ | bakker_hobolt_social | cmp_left_right |
|------------|-------------------|-------------------|----------------------|----------------|
| 31989L0117 | -1.6094379        | 0.000000          | 0.0000000            | 0.0000000      |
| 31989L0130 | 0.0000000         | 0.000000          | -1.0986123           | 0.0000000      |
| 31989L0297 | 0.0000000         | 0.000000          | -1.9459101           | 0.0000000      |

**Minor differences to paper:**
- Non-english texts were not translated into English (see p. 12)
- Did not split on the median word-length if “Adopted this directive/regulation” does not appear (see p. 12)

### Latent Semantic Scaling (LSS)
LSS is a method to measure the semantic similarity of terms to a set of seed words ([manual](https://koheiw.github.io/LSX/articles/pkgdown/basic.html))
#### [LSS Method: Economic Seed Words](https://www.dropbox.com/scl/fi/xivjtmasr72vmat8mqsih/glove_polarity_scores_all_dir_reg_econ.rds?rlkey=32zmjd08rm9669iww691bd8ls&dl=0)
N = 74,734 | .rds | 663KB | [See seed words](https://github.com/fabianaiolfi/eu-policy-feedback/blob/main/lss/seed_words_econ_manual.yml)  
`>0`: More left  
`<0`: More right  

| CELEX       | avg_glove_polarity_scores |
|-------------|---------------------------|
| 31989L0083  | 0.398                     |
| 31989L0100  | 0.349                     |
| 31989L0117  | 1.01                      |

#### [LSS Method: Social Seed Words](https://www.dropbox.com/scl/fi/496oc0pjyk1g4zqyvzrs2/glove_polarity_scores_all_dir_reg_social.rds?rlkey=idcspqo4bun8mznzstlzxljp6&dl=0)
N = 74,734 | .rds | 663KB | [See seed words](https://github.com/fabianaiolfi/eu-policy-feedback/blob/main/lss/seed_words_social_manual.yml)  
`>0`: More left  
`<0`: More right  

| CELEX       | avg_glove_polarity_scores |
|-------------|---------------------------|
| 31989L0083  | 0.440                     |
| 31989L0100  | 0.0452                    |
| 31989L0117  | 0.519                     |

### ChatGPT 0-Shot: [Preamble](https://www.dropbox.com/scl/fi/b0xt9mc5tqhy0sicroh4b/chatgpt_preamble_0_shot.rds?rlkey=1bf3mtaqwlr1mhh4ed52scy1a&dl=0) and [Summary](https://www.dropbox.com/scl/fi/tawgrzdalylkbsuafpaja/chatgpt_summary_0_shot.rds?rlkey=0shddxnty3bv3tp780nq94l6g&dl=0)
N = 1637 | .rds | 6KB  
`0`: Economic left-wing policies  
`100`: Economic right-wing policies  
Model: `gpt-4o-mini-2024-07-18`  
```
System Prompt: You are an expert in European Union policies. Answer questions and provide information based on that expertise.
```
```
Prompt: I’m going to show you [a summary / the beginning of a preamble] of an EU policy. Please score the policy on a scale of 0 to 100. 0 represents economic left-wing policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. 100 represents economic right-wing policies such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. Please only return the score. Here’s the [summary / preamble]: …
```

| CELEX       | chatgpt_answer |
|-------------|---------------------------|
| 31989L0117  | 75                     |
| 31989L0130  | 70                    |
| 31989L0297  | 65                     |

See also:
- Llama 0-Shot [Preamble](https://www.dropbox.com/scl/fi/6omdykxlrae6z79338y4g/llama_preamble_0_shot.rds?rlkey=5lzgnbwsxl0zhiuuvd7vwmigc&dl=0) (N = 32,719 | .rds | 156KB) and [Summary](https://www.dropbox.com/scl/fi/lsen6mylbu8i1cplcsob8/llama_summary_0_shot.rds?rlkey=oe48i2c3lk1hy1o2kfmaoz2w2&dl=0) (N = 1445 | .rds | 8KB).
- Deepseek [Economic 0-Shot Summary](https://www.dropbox.com/scl/fi/6kjy6ovqoatx9k814keg9/deepseek_llm_output_0_shot_summaries_econ.csv?rlkey=iqyn1j13uwwf1uxmi8jnp3zkt&dl=0) (N = 1637 | .csv | 23KB) and Deepseek [Social 0-Shot Summary](https://www.dropbox.com/scl/fi/ylkuz7ubax3e1sq1ez511/deepseek_llm_output_0_shot_summaries_social.csv?rlkey=d7p1m6regz9yitkhb013he09n&dl=0) (N = 1637 | .csv | 23KB)

### ChatGPT Ranking: [Summary](https://www.dropbox.com/scl/fi/y1edxlie1zp6n43uvquca/chatgpt_combined_rating.rds?rlkey=j7l3lmwybfwau4zjr5s2fykxg&dl=0)
N = 1637 | .rds | 20KB  
`<0`: Economic left-wing policies  
`>0`: Economic right-wing policies  
Model: `gpt-4o-mini` 
```
System Prompt: You are an expert in European Union policies. Answer questions and provide information based on that expertise.
```
```
Prompt for economic *left*: I have two summaries of EU policies, and I need to determine which policy is more economically left-leaning. Please analyze the summaries based on principles commonly associated with economically left policies, such as government intervention in the economy, redistribution of wealth, social welfare programs, progressive taxation, regulation of markets, and support for labor rights. [Summary] Which policy is more economically left? Please return only '1' or '2'.
```
```
Prompt for economic *right* I have two summaries of EU policies, and I need to determine which policy is more economically right-leaning. Please analyze the summaries based on principles commonly associated with economically right policies, such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility. [Summary] Which policy is more economically right? Please return only '1' or '2'.
```
```
Prompt for social *left*: I have two summaries of EU policies, and I need to determine which policy is more socially progressive. Please analyze the summaries based on principles commonly associated with socially progressive policies, such as support for LGBTQ+ rights, gender equality, racial justice, reproductive rights, inclusive social policies, expansive immigration policies, criminal justice reform, environmental justice, secularism in governance, and multiculturalism.
```
```
Prompt for social *right*: I have two summaries of EU policies, and I need to determine which policy is more economically right-leaning. Please analyze the summaries based on principles commonly associated with economically right policies, such as free market capitalism, deregulation, lower taxes, privatization, reduced government spending, and individual financial responsibility.
```

| CELEX       | llm_ranking_z_score |
|-------------|---------------------------|
| 31991L0383  | -1.479584 |
| 32013R1381  | -2.331678 |
| 32013R1304  | -1.463549 |

Ranking datasets combine outputs from both prompts [in this script](https://github.com/fabianaiolfi/eu-policy-feedback/blob/main/llm_ranking/03_post_processing.R) and calculate z-score.  
See also Llama [Economic Ranking Summary](https://www.dropbox.com/scl/fi/akl979vhfmib0iuy0dnmc/llama_combined_rating.rds?rlkey=odcmy7wwaxsym9fn5z9jrb8yo&dl=0) (N = 1637 | .rds | 20KB), Deepseek [Economic Ranking Summary](https://www.dropbox.com/scl/fi/3mtrkitch1cjctvam3t3s/deepseek_combined_rating_summaries.rds?rlkey=0smktp1rn853oxcc8m1dbi8hk&dl=0) (N = 1637 | .rds | 20KB) and Deepseek [Social Ranking Summary](https://www.dropbox.com/scl/fi/tgtg4m1bo3bwvz6bqddnj/deepseek_combined_social_ranking_summaries.rds?rlkey=98oz2hovy80b4j8gv9wmsrwmf&dl=0) (N = 1637 | .rds | 20KB).

### Column Descriptions

| Column Name     | Description                                                                                                                                                          |
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `act_raw_text`  | The full raw text of the act in one string. Mostly includes: title, recitals, legal articles and annex. Please note that the text of older laws is not always clean. (1) |
| `Act_type`      | Is either "Directive" or "Regulation"                                                                                                                                |
| `avg_glove_polarity_scores` (Economic and Social) | LSS score. Negative values: Right; Positive values: Left |
| `bakker_hobolt_econ` | Economic left-right classification based on [Bakker and Hobolt (2013), p. 38](https://www.dropbox.com/scl/fi/htb19lqo8g41l4hxusy34/bakker_hobolt_2013_chapter.pdf?rlkey=l9ofp62s38b73wxu4xpdk2wm0&dl=0)'s modified CMP measures. Negative values: Left; Positive values: Right |
| `bakker_hobolt_social` | Social left-right classification based on [Bakker and Hobolt (2013), p. 38](https://www.dropbox.com/scl/fi/htb19lqo8g41l4hxusy34/bakker_hobolt_2013_chapter.pdf?rlkey=l9ofp62s38b73wxu4xpdk2wm0&dl=0)'s modified CMP measures. Negative values: Left; Positive values: Right |
| `CELEX`         | Unique CELEX identifier of an act ([more info](https://eur-lex.europa.eu/content/help/eurlex-content/celex-number.html)) (1) |
| `cmp_left_right` | Comparative Manifesto Project left-right dimension based on [Bakker and Hobolt (2013), p. 33](https://www.dropbox.com/scl/fi/htb19lqo8g41l4hxusy34/bakker_hobolt_2013_chapter.pdf?rlkey=l9ofp62s38b73wxu4xpdk2wm0&dl=0). Negative values: Left; Positive values: Right |
| `Date_document` | Date of the document. The eur-lex.eu website does not provide an explanation of which exact date in the legislative process this represents. (1) |
| `eurlex_summary_clean` | Summary of directive or regulation retrieved from eur-lex.com ([example summary](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:31989L0117&qid=1725090724730)) |
| `RoBERT_left_right` | Party Manifestos Project Right-Left (RILE) classification. Negative values: Left; Positive values: Right |

(1) Source: [CEPS EurLex codebook](https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/0EGYWY/RVEJU9&version=2.0)

--------

## Open Points and Possible Improvements
**General**
- [ ] How to disregard / ignore laws that are *not* relevant? E.g. a law on abortion has no economic left-right ideology → One possible approach could be using a policy’s tags. Are there tags that indicate that a policy can be ignored?
- [ ] Scrape EUROVOC descriptors ([example](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:32009L0034&qid=1720174976038))
- [ ] Which laws have summaries? When does the EU decide to summarise a legislation? Are more recent policies more likely to be summarised?
- [ ] Replace NA tags/descriptors with generated descriptors

**LSS**
- [ ] Create different set of LSS seed words, find a way to document differences in outcome
- [ ] "Yet, at different points in time, the legislative institutions have delivered more “rightwing” policies, such as market deregulation, and at other times more “leftwing” policies, such as higher environmental and labour market standards." (Hix Høyland 2024, 1)
- [ ] “rile”-index: https://manifesto-project.wzb.eu/down/tutorials/main-dataset

**Ranking Method**
- [ ] Examine different ranking algorithms: https://stackoverflow.com/questions/3937218/comparison-based-ranking-algorithm
- [x] Implement Elo ranking
	- [ ] Prevent algorithm shortcomings by:
		- [ ] Randomize the Order: Randomly shuffle the order of comparisons multiple times and average the final ratings.
		- [ ] Increase the Number of Comparisons: More comparisons will help stabilize the ratings, reducing the impact of any particular order.
		- [ ] Lower the K-Factor: This reduces the volatility of the ratings but can slow down the adjustment process.

**Evaluation**
- [ ] Include spolicy in the overall evaluation
- [ ] Perform evaluation with scraped EUROVOC descriptors
- [ ] How reliable are the summaries compared to the preamble or entire text?
- [ ] Create tags / topics of each document to see if there's a correlation between topics and calculated ideology
- [ ] Compare results with left-right tags defined by Hix Høyland (2024), p. 33
- [ ] Dig deeper: Look into broad policy areas and if certain areas align more between ground truth and calculated measurements than others

**Embeddings**
- [ ] Compare policies with existing data
  - [ ] EP speeches and party manifestos
  - [ ] Policies or laws from another jurisdiction (e.g., UK), where policy author/creater and their political affiliation are known  
- [ ] Create an embedding for each EP faction and topic (e.g., left-wing and climate issues). Then label each policy with a topic. Then calculate embeddings for each policy and assign the policy to the closest faction based on the issue.

**LLM Approach**
- [ ] Potential political bias in LLMs? Try multiple prompts and models.
- [ ] Fine tune an LLM similar to [ManiBERT](https://huggingface.co/niksmer/ManiBERT)
- [ ] Compare policy summary, preamble (like Hix Høyland (2024)) and entire text to evaluate output
- [ ] Approaches
  - [x] 0-shot: Query a single law and ask ChatGPT to place it on a left-right scale. Query must clearly explain economic/social left-right dimension
  - [x] Compare and rank: Compare two policies and pick the more left one. Then apply Elo ranking.
  - [ ] In order to overcome problem that distance between laws is unclear: Somehow combine scores from other techniques in order to retrieve ideological “distance” between laws
  - [ ] See also: BradleyTerry algorithm (applied [here](https://onlinelibrary.wiley.com/doi/full/10.1111/ajps.12703))
