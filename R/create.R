#' get sysrev project/options with a name or id
#' @param name the sysrev to get metadata from
#' @inheritParams get_
#' @return A dataframe
#' @export
get_sysrev <- function(name,pid=NA,token=get_srtoken()){
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

#' create a data source with pubmed ids (pmids)
#' @param pid the project for which to create a source
#' @param pmids the pubmed ids to import
#' @param token a sysrev token with read access to the given project
#' @return success message
#' @export
#'
create_source_pmids <- function(pid,pmids,token=get_srtoken()){
  sysrev.rplumber.post("import_pmids",list(pid=pid,pmids=pmids),token)$result
}
