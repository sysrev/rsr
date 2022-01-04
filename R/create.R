#' get_sysrev
#' TODO need to move this back to get.R file and fix evaluation order
#' get a sysrev metadata
#' @param name the sysrev to get metadata from
#' @param token a sysrev token with read access to the given project
#' @importFrom rlang .data
#' @return A dataframe
#' @export
#'
get_sysrev <- function(name,token=get_srkey()){
  sysrev.rplumber("get_sysrev",list(name=name),token)
}

#' create_sysrev
#' create a sysrev project
#' @param name the name of the project you want to create
#' @param get_if_exists get the project if it already exists
#' @param token a sysrev token with read access to the given project
#' @return json describing result of call
#' @export
#'
create_sysrev <- function(name,get_if_exists=F,token=get_srkey()){
  pid = if(get_if_exists){ get_sysrev(name,token) }
  if(get_if_exists && pid$exists){ pid }else{ sysrev.rplumber.post("create_sysrev",list(name=name),token) }
}
