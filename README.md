# EU Policy Feedback

## Deliverables by end of Aug 2024 (sorted by importance)

1. Collect all data (Must)
- Update dataset to include all policies up to today (Aug 2024)

2. Complete Hix Høyland (2024) Recreation 
- Aim: Retrieve scores for both economic and social dimensions → This will result in 2 scores
- Apply Hix Høyland (2024) technique on policy summaries → This will result in 2 scores
- To do:
	- [ ] Clean text appropriate for word embedding (e.g., remove frequent expressions, see below)

3. Improve LSS (Nice to Have)
- Improve seed words to be more systematic and based on dictionaries such as [Wordscore](https://tutorials.quanteda.io/machine-learning/wordscores/) and [Wordfish](https://tutorials.quanteda.io/machine-learning/wordfish/)
- Remove most frequent expressions (see [this paper](https://www.dropbox.com/scl/fi/u1dpvjp9bzmgbmebuqfs9/word_embeddings_for_the_analysis_of_ideological_placement_in_parliamentary_corpora.pdf?rlkey=x3uam6ph6nywag1rlggcobhe4&dl=0))
- Calculate both dimensions (economic and social)

4. ChatGPT Approach (Nice to Have)
- Compare policy summary, preamble (like Hix Høyland (2024)) and entire text to evaluate output
- Approaches
	- 0-shot: Query a single law and ask ChatGPT to place it on a left-right scale. Query must clearly explain economic/social left-right dimension
	- Compare and rank: Comapare two policy and pick the more left one. Then apply Elo ranking.
- In order to overcome problem that distance between laws is unclear: Somehow combine scores from other techniques in order to retrieve ideological “distance” between laws

5. Systematic Evaluation of all Measurements (Nice to Have)
- Compare results amongst themselves and with expert survey (e.g. [this expert survey](https://www.dropbox.com/scl/fi/392u06vxzhz6sqebe5mam/EU_Competencies_Index_codebook_v1.pdf?rlkey=vgbqc57dmxur7rakqpekdswy8&dl=0))

## General To Do
- [ ] How to disregard / ignore laws that are *not* relevant? E.g. a law on abortion has no economic left-right ideology → One possible approach could be using a policy’s tags. Are there tags that indicate that a policy can be ignored?
- [ ] Publish paper? Consider until end of Aug.

## Data Collection 1989 – Today
- [x] CEPS EurLex (1952 – 2019)
- [ ] Moodley (1971 – 2022)
- [ ] Scrape summaries
	- [Example](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:32019L0904&qid=1719922563047)
	- [More info](https://eur-lex.europa.eu/browse/summaries.html) 
- [ ] Scrape EUROVOC descriptors ([example](https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:32009L0034&qid=1720174976038))

### To Do
- [ ] Which laws have summaries? When does the EU decide to summarise a legislation?

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
