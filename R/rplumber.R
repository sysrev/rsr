#' sysrev.plumber.get
#' a simple wrapper for rplumber.sysrev.com httr api requests
#' @import httr
#' @param path the service path see rplumber.sysrev.com/__docs__/#/
#' @param params list of http parameters
#' @param token a sysrev token with read access to the given project
#' @return A dataframe
#'
rplumber = function(path,params=list(),token=keyring::key_get("sysrev.token")){
  req   <- GET(config::get("plumber.sysrev"), path=path,query=params)
  res   <- content(req, as="text", encoding = "UTF-8") %>% jsonlite::fromJSON()
  if(!is.null(res$errors)){ stop(paste(lapply(res$errors,function(e){e$message}),collapse = "\n")) }
  res
}

#' sysrev.webapi
#' a simple wrapper for the sysrev.com/web-api/ service
#' documnetation at https://sysrev.com/web-api/doc
#' @param path the service path see rplumber.sysrev.com/__docs__/#/
#' @param params list of http parameters
#' @param token a sysrev token with read access to the given project
#' @return some json
#'
sysrev.webapi = function(path,params=list(),token=keyring::key_get("sysrev.token")){
  pbody  = params %>% append(list(`api-token`=token))
  apiurl = sprintf("https://sysrev.com/web-api/%s",path)
  req    = httr::POST(apiurl,body=pbody,encode="json")
  res    = httr::content(req, as="text", encoding = "UTF-8") %>% jsonlite::fromJSON()
  if(!is.null(res$errors)){ stop(paste(lapply(res$errors,function(e){e$message}),collapse = "\n")) }
  res
}
