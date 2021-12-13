#' import_pmids
#' creates a data source for the given sysrev project with the given pubme ids
#' @param pid the project for which to create a source
#' @param pmids the pubmed ids to import
#' @param token a sysrev token with read access to the given project
#' @return success message
#' @export
#'
import_pmids <- function(pid,pmids,token=keyring::key_get("sysrev.token")){
  ent = list(`project-id`=pid,pmids=as.numeric(pmids))
  res = sysrev.webapi("import-pmids",ent,token = token)
  if(!is.null(res$error)){stop(res$error$message)}
  res
}
