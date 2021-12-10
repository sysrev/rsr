#' view_articles
#'
#' get the basic article data from a sysrev project
#' @param pid the project to get articles from, i.e sysrev.com/p/<project_id>
#' @param token a sysrev token with read access to the given project
#'
#' @return A dataframe
#' @export
#'
view_articles <- function(pid,token=keyring::key_get("sysrev.token")){
  rplumber("articles",list(pid=pid),action = httr::GET,token)
}
