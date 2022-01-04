#' import_pmids
#' creates a data source for the given sysrev project with the given pubme ids
#' @param pid the project for which to create a source
#' @param pmids the pubmed ids to import
#' @param token a sysrev token with read access to the given project
#' @return success message
#' @export
#'
import_pmids <- function(pid,pmids,token=get_srkey()){
  sysrev.rplumber.post("import_pmids",list(pid=pid,pmids=pmids),token)$result
}
