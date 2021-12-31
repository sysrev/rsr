#' create_sysrev
#' create a sysrev project
#' @param project_name the name of the project you want to create
#' @param token a sysrev token with read access to the given project
#' @return json describing result of call
#' @export
#'
create_sysrev <- function(project_name,token=get_key()){
  res = sysrev.webapi("create-project",list(`project-name`=project_name),token = token)
  pid = res %>% purrr::pluck("result","project","project-id")
  if(!is.null(res$error)){stop(res$error$message)}
  pid
}


#' create_source
#' @import glue
#' @param name name of the source
#' @param description description of the source
#' @param url a reference url for the source
#' @param token your private token
#' @return the sid of the created source
#' @export
create_source <- function(name,description,url,token=get_key()){
  query = glue("mutation {{ createDataset( name: {double_quote(name)}, description: {double_quote(description)} ){{ id }} }}")
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
#' @export
create_source_entity <- function(sid,title,entity,token=get_key()){
  b64      = entity %>% jsonlite::toJSON() %>% charToRaw() %>% base64enc::base64encode()
  query    = glue('mutation {{ createEntity( dataset: {sid}, filename: {double_quote(title)}, file:{double_quote(b64)}) {{id}} }}')
  datasource.gql(query,token=token)$createEntity$id
}
