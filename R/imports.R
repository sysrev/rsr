#' #' import_pmids
#' #' creates a data source for the given sysrev project with the given pubme ids
#' #' @param pid the project for which to create a source
#' #' @param pmids the pubmed ids to import
#' #' @param token a sysrev token with read access to the given project
#' #' @return success message
#' #' @export
#' #'
#' import_pmids <- function(pid,pmids,token=get_srkey()){
#'   ent = list(`project-id`=pid,pmids=as.numeric(pmids))
#'   res = sysrev.webapi("import-pmids",ent,token = token)
#'   if(!is.null(res$error)){stop(res$error$message)}
#'   res
#' }
#'
#'
#' #' import_article_text
#' #' creates a data source for the given sysrev project with articles generated from combined title and abstract
#' #' @param pid the project for which to create a source
#' #' @param title titles for articles
#' #' @param abstract abstracts for articles
#' #' @param token a sysrev token with read access to the given project
#' #' @return success message
#' #' @export
#' #'
#' import_article_text <- function(pid,title,abstract,token=get_srkey()){
#'   articles=lapply(1:length(title),function(i){list(`primary-title`=title[i],abstract=abstract[i])})
#'   ent = list(`project-id`=pid,articles=articles)
#'   res = sysrev.webapi("import-article-text",ent,token = token)
#'   if(!is.null(res$error)){stop(res$error$message)}
#'   res
#' }
