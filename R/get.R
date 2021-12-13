#' get_articles
#'
#' get the basic article data from a sysrev project
#' @param pid the project to get articles from, i.e sysrev.com/p/<project_id>
#' @param token a sysrev token with read access to the given project
#'
#' @return A dataframe
#' @export
#'
get_articles <- function(pid,token=keyring::key_get("sysrev.token")){
  rplumber("get_articles",list(pid=pid),token)
}

#' get_article
#'
#' get the basic article data from a sysrev project
#' @param aid the project to get articles from, i.e sysrev.com/p/<project_id>
#' @param token a sysrev token with read access to the given project
#'
#' @return A dataframe
#' @export
#'
get_article <- function(aid,token=keyring::key_get("sysrev.token")){
  rplumber("get_article",list(aid=aid),token)
}
