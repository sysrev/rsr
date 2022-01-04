#' sysrev.plumber.get
#' a simple wrapper for rplumber.sysrev.com httr api requests
#' @import glue
#' @import httr
#' @param path the service path see rplumber.sysrev.com/__docs__/#/
#' @param params list of http parameters
#' @param token a sysrev token with read access to the given project
#' @return A dataframe
#' @keywords internal
#'
sysrev.rplumber = function(path,params=list(),token=get_srkey()){
  req   <- GET(modify_url(getOption("rsr.sysrev.plumber.url"), path=path,query=params),add_headers(Authorization=glue("bearer {token}")))
  res   <- content(req, as="text", encoding = "UTF-8") %>% jsonlite::fromJSON()
  if(!is.null(res$error)){ stop(res$message) }
  res
}
