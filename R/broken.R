#' import_source_insilica
#' imports a datasource.insilica.co dataset
#' TODO - fix this or abandon datasource?
#' @param pid the id of the target project
#' @param sid the id of the dataset to import
#' @inheritParams test_token
#' @return success message
#' @export
import_source_insilica <- function(pid,sid,token=get_srkey()){
  stop("this no longer works")
  query <- glue::glue('mutation {{ importDataset( dataset: {sid}, id: {pid} ) }}')
  sysrev.graphql(query,token)
}

#' create_source_insilica
#' @import glue
#' @param name name of the source
#' @param description description of the source
#' @param url a reference url for the source
#' @param token your private token
#' @return the sid of the created source
create_source_insilica <- function(name,description,url,token=get_srkey()){
  stop("this works, but is not useful for sysrev users")
  query = glue("mutation {{ createDataset(
               name: {double_quote(name)},
               description: {double_quote(description)}
               url: {double_quote(url)}){{ id }} }}")
  datasource.gql(query,token = token)$createDataset$id
}

#' create_source_entity
#'
#' @importFrom glue glue double_quote
#' @param sid the datasource sid in which to place the entity
#' @param title a title for the entity
#' @param entity a list that can be converted to json via jsonlite
#' @inheritParams test_token
#' @return eid the entity id
create_source_entity <- function(sid,title,entity,token=get_srkey()){
  stop("this works, but is not useful for sysrev users")
  b64      = entity %>% jsonlite::toJSON() %>% charToRaw() %>% base64enc::base64encode()
  query    = glue('mutation {{ createEntity( dataset: {sid}, filename: {double_quote(title)}, file:{double_quote(b64)}) {{id}} }}')
  datasource.gql(query,token=token)$createEntity$id
}


