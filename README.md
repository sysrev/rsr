# rsr <img src="man/figures/logo.svg" align="right" />
Create, access and analyze Sysrev data. 

**Install**
``` r
devtools::install_github('sysrev/rsr')
```

**Authenticate**  
Get your sysrev token from your sysrev.com user page.


**Pubmed example**  
Setup a simple review of pubmed title/abstracts.

```{r}
library(rsr)

# Create or get a sysrev and get it's `pid`
pid = create_sysrev("rsr",get_if_exists=T)$pid

# Import articles from pubmed with pmids
import_pmids(pid,pmids=c(1000,10001))

# pull article data into R
get_articles(pid)
# # A tibble: 2 × 11
#        aid datasource_name external_id
#      <int> <chr>           <chr>      
# 1 13747809 pubmed          "\"1000\"" 
# 2 13747810 pubmed          "\"10001\""      
# # project_id <int>, title <chr>, ...

browse_sysrev(pid) # Open sysrev in browser
```
