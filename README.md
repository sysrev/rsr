# RSysrev <img src="man/figures/logo.svg" align="right" />

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

``` r
library(RSysrev)
pid = create_project("my new project") # create a project
import_raw_articles(pid,
  lapply(1:10,function(x){list(`primary-title`=lorem::ipsum(sentences=1)[1],abstract=lorem::ipsum()[1])
})) # import some articles
dt = view_articles(pid) # get the articles
# TODO review some articles
# TODO get review data
```
