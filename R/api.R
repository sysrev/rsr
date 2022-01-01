#' sysrev.plumber.get
#' a simple wrapper for rplumber.sysrev.com httr api requests
#' @import glue
#' @import httr
#' @param path the service path see rplumber.sysrev.com/__docs__/#/
#' @param params list of http parameters
#' @param token a sysrev token with read access to the given project
#' @return A dataframe
#'
rplumber = function(path,params=list(),token=get_srkey()){
  req   <- GET(modify_url(getOption("rsr.sysrev.plumber.url"), path=path,query=params),add_headers(Authorization=glue("bearer {token}")))
  res   <- content(req, as="text", encoding = "UTF-8") %>% jsonlite::fromJSON()
  if(!is.null(res$errors)){ stop(paste(lapply(res$errors,function(e){e$message}),collapse = "\n")) }
  res
}

#' sysrev.webapi
#' a simple wrapper for the sysrev.com/web-api/ service
#' documentation at https://sysrev.com/web-api/doc
#' @param path the service path see rplumber.sysrev.com/__docs__/#/
#' @param params list of http parameters
#' @param unbox whether to unbox the params when parsing json
#' @param token a sysrev token with read access to the given project
#' @return some json
#'
sysrev.webapi = function(path,params=list(),unbox=F,token=get_srkey()){
  pbody  = params %>% append(list(`api-token`=token))
  pbody  = if(unbox){ jsonlite::toJSON(pbody,auto_unbox = T)}else{pbody}
  apiurl = sprintf("https://sysrev.com/web-api/%s",path)
  req    = httr::POST(apiurl,body=pbody,encode="json")
  res    = httr::content(req, as="text", encoding = "UTF-8") %>% jsonlite::fromJSON()
  if(!is.null(res$errors)){ stop(paste(lapply(res$errors,function(e){e$message}),collapse = "\n")) }
  res
}


#' datasource.gql
#' a simple wrapper for datasource.insilica.co
#' @param query the graphql query
#' @param token a sysrev token with read access to the given project
#' @param .url the url for datasource
#' @return A dataframe
#' @export
#'
datasource.gql = function(query,token=get_srkey(),.url = "https://datasource.insilica.co/graphql"){
  req <- {
    if(is.null(token)){ httr::POST(.url, body = list(query = query), encode="json") }
    else{ httr::POST(.url, body = list(query = query), encode="json",httr::add_headers(Authorization=paste("Bearer", token))) }
  }

  res <- httr::content(req, as = "parsed", encoding = "UTF-8")

  if(is.null(res$data)){ jsonlite::prettify(jsonlite::toJSON(res,auto_unbox = T)) |> stop() }
  res$data
}
