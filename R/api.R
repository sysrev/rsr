#' sysrev.plumber
#' a simple wrapper for rplumber.sysrev.com httr api requests
#' TODO - remove get_srtoken
#' @import glue
#' @import httr
#' @param path the service path see rplumber.sysrev.com/__docs__/#/
#' @param params list of http parameters
#' @param token a sysrev token with read access to the given project
#' @return A dataframe
#' @keywords internal
#'
srplumber = function(path,params=list(),token=get_srtoken()){
  req   <- GET(modify_url(getOption("srplumber.url"), path=path,query=params),add_headers(Authorization=glue("bearer {token}")))
  res   <- content(req, as="text", encoding = "UTF-8") %>% jsonlite::fromJSON()
  
  if(!is.list(res)){ return(res) }
  
  if(!is.null(res$error.srp)){
    a = unlist(res$error.srp) 
    a = set_names(a,map_chr(names(a),\(x){substr(x,1,1)}))
    rlang::abort(a)
  }
  
  if(!is.null(res$error)){ rlang::abort(res$error) }
  
  res
}

#' sysrev.plumber.post
#' a simple wrapper for rplumber.sysrev.com httr api requests
#' @import glue
#' @import httr
#' @param path the service path see rplumber.sysrev.com/__docs__/#/
#' @param params list of http parameters
#' @param token a sysrev token with read access to the given project
#' @return A dataframe
#' @keywords internal
srplumber.post = function(path,body,token,encode="json"){
  req   <- POST(modify_url(getOption("srplumber.url"), path=path),
                add_headers(Authorization=glue("bearer {token}")),
                body=body,encode = encode)
  res   <- content(req, as="text", encoding = "UTF-8") %>% jsonlite::fromJSON()
  
  if(!is.list(res)){ return(res) }
  
  if(!is.null(res$error.srp)){
    a = unlist(res$error.srp) 
    a = set_names(a,map_chr(names(a),\(x){substr(x,1,1)}))
    rlang::abort(a)
  }
    
  if(!is.null(res$error)){ 
    rlang::abort(res$error)
  }
  
  res
}
