# EU Policy Feedback

## Data Collection
- Work with summaries? Example: https://eur-lex.europa.eu/legal-content/EN/LSU/?uri=CELEX:32019L0904&qid=1719922563047

## Latent Semantic Scaling (LSS)
- LSS is a method to measure the semantic similarity of terms to a set of seed words
- Manual: https://koheiw.github.io/LSX/articles/pkgdown/basic.html
- To do: Compare output of sentences with paragraphs?

## Embeddings
- Compare policies with EP speeches and party manifestos
- Create an embedding for each EP faction and topic (e.g., left-wing and climate issues). Then label each policy. Then calculate embeddings for each policy and assign the policy to a faction and issue.

## Ranking
- Get an LLM to compare two policies with each other: Which policy is more left or more right?
- Try out with the entire policy and also with a summary of the policy
- Based on this, create a ranking of all policies
- BradleyTerry algorithm
- https://onlinelibrary.wiley.com/doi/full/10.1111/ajps.12703

## Evaluation
- Create tags / topics of each document to see if there's a correlation between topics and left/right ideology
