#' create a data source with pubmed ids (pmids)
#' @param pid the project for which to create a source
#' @param pmids the pubmed ids to import
#' @param token a sysrev token with read access to the given project
#' @return success message
#' @export
#'
import_pmids <- function(pid,pmids,token=get_srtoken()){
  sysrev.rplumber.post("import_pmids",list(pid=pid,pmids=pmids),token)$result
}
