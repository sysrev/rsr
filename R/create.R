#' get a sysrev with a name
#' @description
#' TODO need to move this back to get.R file and fix evaluation order
#' get a sysrev metadata
#' @param name the sysrev to get metadata from
#' @param token a sysrev token with read access to the given project
#' @importFrom rlang .data
#' @return A dataframe
#' @export
#'
get_sysrev <- function(name,token=get_srtoken()){
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
create_sysrev <- function(name,get_if_exists=F,token=get_srtoken()){
  sr = get_sysrev(name,token)
  sr = if( get_if_exists && sr$exists){ sr }
  else if(!sr$exists){ sysrev.rplumber.post("create_sysrev",list(name=name),token) }
  else if(!get_if_exists && sr$exists){
    stop(glue::glue_col("{red {name}} already exists, rerun with {cyan `get_if_exists=T`}?"))
  }

  sr$pid
}
