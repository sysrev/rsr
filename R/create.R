#' get_sysrev
#' TODO need to move this back to get.R file and fix evaluation order
#' get a sysrev metadata
#' @param project_name the sysrev to get metadata from
#' @param token a sysrev token with read access to the given project
#' @importFrom rlang .data
#' @return A dataframe
#' @export
#'
get_sysrev <- function(project_name,token=get_srkey()){
  sysrev.rplumber("get_sysrev",list(project_name=project_name),token) |> purrr::pluck("pid")
}

#' create_sysrev
#' create a sysrev project
#' @param project_name the name of the project you want to create
#' @param token a sysrev token with read access to the given project
#' @return json describing result of call
#' @export
#'
create_sysrev <- function(project_name,token=get_srkey()){
  res = sysrev.rplumber("create_sysrev",list(project_name=project_name),token)
  return(res)
}

#' get a sysrev project by name, or create it.
#' @importFrom purrr possibly
#' @param project_name the name of the project you want to create
#' @param token a sysrev token with read access to the given project
#' @return a sysrev project id pid
#' @export
get_or_create_sysrev <- function(project_name,token=get_srkey()){
  purrr::possibly(create_sysrev,otherwise = get_sysrev(project_name,token))(project_name,token)
}

