#' create_sysrev
#' create a sysrev project
#' @param project_name the name of the project you want to create
#' @param token a sysrev token with read access to the given project
#' @return json describing result of call
#' @export
#'
create_sysrev <- function(project_name,token=keyring::key_get("sysrev.token")){
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
#' @return
#' @export
create_source <- function(name,description,url,token=get_key()){
  query = glue("mutation {{ createDataset( name: {double_quote(name)}, description: {double_quote(description)} ){{ id }} }")
  datasource.gql(query,token = token)$createDataset$id
}
