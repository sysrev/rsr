#' get sysrev project/options with a name or id
#' @param name the sysrev to get metadata from
#' @inheritParams get_
#' @return A dataframe
#' @export
get_sysrev <- function(name,pid=NA,token=get_srtoken()){
  srplumber("get_sysrev",list(name=name),token)
}

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
  else if(!sr$exists){ srplumber.post("create_sysrev",list(name=name),token) }
  else if(!get_if_exists && sr$exists){
    stop(glue::glue_col("{red {name}} already exists, rerun with {cyan `get_if_exists=T`}?"))
  }

  sr$pid
}

#' create a data source with pubmed ids (pmids)
#' @inheritParams common_params
#' @param name give your source a name
#' @param pmids the pubmed ids to import
#' @return success message
#' @export
create_source_pmids <- function(pid,name,pmids,token=get_srtoken()){
  srplumber.post("import_pmids",list(pid=pid,pmids=pmids),token)$result
}
