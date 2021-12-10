#' import_raw_articles
#' a simple wrapper for rplumber.sysrev.com httr api requests
#' @param pid the service path see rplumber.sysrev.com/__docs__/#/
#' @param articles list(list(`primary-title`=<string>,`abstract`==<string>))
#' @param token a sysrev token with read access to the given project
#' @return success message
#' @export
#'
import_raw_articles <- function(pid,articles,token=keyring::key_get("sysrev.token")){
  res = sysrev.webapi("import-article-text",list(`project-id`=pid,articles=articles),token = token)
  if(!is.null(res$error)){stop(res$error$message)}
  res
}


