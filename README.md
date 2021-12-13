# rsysrev <img src="man/figures/logo.svg" align="right" />

The RSysrev package provides tools to access and analyze data generated in sysrev.com projects.

## Installation

RSysrev is not yet on CRAN. The latest development version can be installed from github:

``` r
devtools::install_github('sysrev/RSysrev')
```

## Authenticate
Sysrev premium is required to use RSysrev.  
RSysrev functions take a `token` argument which defaults to `keyring::key_get("sysrev.token")`. This is likely to change in the future. Find your token at your sysrev profile page.


## Example

Get and set sysrev data.

```{r}
library(rsysrev)
library(reutils) # library to search pubmed
library(dplyr)

pid    = create_project("my new project") # create a project 105561 - TODO this should be idempotent
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
