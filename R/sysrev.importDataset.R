#' sysrev.importDataset
#' Import a dataset from datasource as a source on SysRev. Result is true when import is successful,false otherwise.
#' @param datasource.id the id of the dataset to import
#' @param project.id the sysrev project to import into
#' @param token a token with write priveleges
#' @return true if the query works
#' @export
sysrev.importDataset <- function(datasource.id,project.id,token=keyring::key_get("sysrev.token")){
  query <- sprintf('mutation M{importDataset(dataset: %d id: %d)}',datasource.id,project.id)
  sysrev.graphql(query,token)
}
