# rsr <img src="man/figures/logo.svg" align="right" />
Tools to create/access/analyze Sysrev data.

## Installation
`rsr` is not yet on CRAN. Install with:
``` r
devtools::install_github('sysrev/rsr')
```

## Authenticate
rsr requires sysrev premium access, a token is available at your user page.


## Example
Get and set sysrev data.

```{r}
library(rsr)
library(dplyr)

# Create or get a sysrev
pid = create_sysrev("rsr",get_if_exists=T)

# Import some pubmed ids
import = import_pmids(pid,uid(esearch("angry bees",db="pubmed"))) # successful import - TODO sourcing needs improvement

labels = get_labels(pid) %>% select(lbl.id,lbl.name) # projects have default 'include' label
# # A tibble: 1 × 2
#   lbl.id                               lbl.name
#   <chr>                                <chr>   
# 1 929aac3c-8731-4462-9e09-3c575319a7da Include

articles = get_articles(pid) %>% select(article_id,title) # get the project articles - TODO show source
#   article_id title                                           
#        <int> <chr>                                           
# 1   13449522 All abuzz. Angry bees ignite an unexpected MCI. 
# 2   13449523 Preserved rapid conceptual processing of emotio…

review(pid,article.id = articles$article_id[1],lbl.id = labels$lbl.id[1], lbl.value = T) # auto-review an article
view_article(pid,articles$article_id[1]) # View the included article in your browser
```
