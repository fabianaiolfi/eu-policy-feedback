# EU Policy Feedback

## Deliverables by end of Aug 2024

### Must

- [x] Collect all data; Update dataset to include all policies up to mid August 2024: `/data/data_collection/all_dir_reg.rds`
- [x] Collect all summaries: `/data/data_collection/all_dir_reg_summaries.rds`

- [ ] Complete Hix Høyland (2024) Recreation
  - [x] Retrieve scores for both economic and social dimensions
  - [x] Apply Hix Høyland (2024) technique on policy summaries
  - [x] To do: Clean text appropriate for word embedding (e.g., remove frequent expressions, see below)

### Nice to Have
- [x] Improve LSS
  - [x] Improve seed words to be more systematic and based on dictionaries such as [Wordscore](https://tutorials.quanteda.io/machine-learning/wordscores/) and [Wordfish](https://tutorials.quanteda.io/machine-learning/wordfish/)
  - [x] Preprocess text (see [this paper](https://www.dropbox.com/scl/fi/u1dpvjp9bzmgbmebuqfs9/word_embeddings_for_the_analysis_of_ideological_placement_in_parliamentary_corpora.pdf?rlkey=x3uam6ph6nywag1rlggcobhe4&dl=0))
    - [x] Subsampling (random removal of frequent words)
    - [x] Remove digits
    - [x] Remove words with two letters or fewer
    - [x] Remove English stop words, including overly common procedural words
    - [x] Limit the vocabulary to tokens with a minimum count of 50 occurrences
  - [ ] ~~Detect collocations~~
  - [x] Calculate both dimensions (economic and social)

- [ ] ChatGPT Approach
  - Compare policy summary, preamble (like Hix Høyland (2024)) and entire text to evaluate output
  - Approaches
	  - 0-shot: Query a single law and ask ChatGPT to place it on a left-right scale. Query must clearly explain economic/social left-right dimension
	  - Compare and rank: Comapare two policy and pick the more left one. Then apply Elo ranking.
  - In order to overcome problem that distance between laws is unclear: Somehow combine scores from other techniques in order to retrieve ideological “distance” between laws

- [ ] Systematic Evaluation of all Measurements
  - Compare results amongst themselves and with expert survey (e.g. [this expert survey](https://www.dropbox.com/scl/fi/392u06vxzhz6sqebe5mam/EU_Competencies_Index_codebook_v1.pdf?rlkey=vgbqc57dmxur7rakqpekdswy8&dl=0), data: https://www.eucompetencies.com/data/)
  - How reliable are the summaries compared to the preamble or entire text?

## General To Do
- [ ] How to disregard / ignore laws that are *not* relevant? E.g. a law on abortion has no economic left-right ideology → One possible approach could be using a policy’s tags. Are there tags that indicate that a policy can be ignored?
- [ ] Publish paper? Consider until end of Aug.

--------

## Documentation

### Data Collection
- Preview of all_dir_reg.rds and all_dir_reg_summaries.rds

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

## Ranking
- Get an LLM to compare two policies with each other: Which policy is more left or more right?
- Try out with the entire policy and also with a summary of the policy
- Based on this, create a ranking of all policies
- BradleyTerry algorithm
- https://onlinelibrary.wiley.com/doi/full/10.1111/ajps.12703

### To Do
- [ ] Scrape summaries: Are there enough to make this work?
- [ ] Examine different ranking algorithms: https://stackoverflow.com/questions/3937218/comparison-based-ranking-algorithm
- [ ] Implement Elo ranking
	- [ ] Prevent algorithm shortcomings by:
		- [ ] Randomize the Order: Randomly shuffle the order of comparisons multiple times and average the final ratings.
		- [ ] Increase the Number of Comparisons: More comparisons will help stabilize the ratings, reducing the impact of any particular order.
		- [ ] Lower the K-Factor: This reduces the volatility of the ratings but can slow down the adjustment process.
- [ ] Try running an LLM locally
- [ ] Use ChatGPT 4o (gpt-4o-2024-08-06, see OpenAI newsletter from 240808)

## Recreate existing measurement techniques
- [ ] Hix Høyland (2024)

## Evaluation
- [ ] Create tags / topics of each document to see if there's a correlation between topics and calculated ideology
- [ ] Compare with existing measurments
- [ ] Compare results with each other
- [ ] Compare results with left-right tags defined by Hix Høyland (2024), p. 33
- [ ] Normalise results between different metrics (e.g., Hix Høyland and ELO Ranking) using standardisation or z-index

## Resources
- https://michalovadek.github.io/eurlex/
- https://eur-lex.europa.eu/
