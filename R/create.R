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

#' Create a new project based on an existing project
#' @param source.pid project id of the source project
#' @param target.name name of the new project
#' @param add.articles import the articles from source project?
#' @param add.labels import the labels from source project?
#' @param add.members import the members from source project?
#' @param add.answers import the answers from source project?
#' @inheritParams common_params
#' @keyword internal
clone_sysrev <- function(source.pid,target.name,add.articles=T,add.labels=T,add.members=F,add.answers=F,token){
  body = as.list(environment())
  res = srplumber.post("clone_sysrev",body,token)
  if(!is.null(res$error)){stop(res$error$message)}
  res
}


#' create a data source with pubmed ids (pmids)
#' @inheritParams common_params
#' @param name give your source a name
#' @param pmids the pubmed ids to import
#' @return success message
#' @export
create_source_pmids <- function(pid,name,pmids,token=get_srtoken()){
  srplumber.post("create_source_pmids",list(pid=pid,pmids=pmids),token)$result
}
