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
