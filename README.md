# rsr <img src="man/figures/logo.svg" align="right" />
<!-- badges: start -->
[![codecov](https://codecov.io/gh/sysrev/rsr/branch/master/graph/badge.svg?token=PPYGBLSWV3)](https://codecov.io/gh/sysrev/rsr)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->
Create and analyze Sysrev data. **rsr is in development. The package name and everything else may change**



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
create_source_pmids(sr,pmids=c(1000,10001))

# pull article data into R
get_articles(sr)
#      aid title                                      
#    <int> <chr>                                      
# 13747809 The amino acid sequence…
# 13747810 Study of the biological…
# # project_id <int>, title <chr> …

browse_sysrev(sr) # Open sysrev in browser
```
