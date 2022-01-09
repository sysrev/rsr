# rsr <img src="man/figures/logo.svg" align="right" />
Create and analyze Sysrev data. 

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

# Create/get a sysrev project
sr = create_sysrev("rsr",get_if_exists=T)

# Import articles from pubmed with pmids
import_pmids(sr,pmids=c(1000,10001))

# pull article data into R
get_articles(sr)
#      aid title                                      
#    <int> <chr>                                      
# 13747809 The amino acid sequence…
# 13747810 Study of the biological…
# # project_id <int>, title <chr> …

browse_sysrev(sr) # Open sysrev in browser
```
