#' view_article
#' opens the given project article in a browser
#' @import utils
#' @import glue
#' @param pid project id to view
#' @param aid article id to view
#' @return nothing
#' @export
view_article = function(pid,aid){
  browseURL(glue("https://sysrev.com/p/{pid}/article/{aid}"))
}


#' view_project
#' opens the given project in your browser
#' @param pid project id to view
#' @return nothing
#' @export
view_project = function(pid){
  browseURL(glue("https://sysrev.com/p/{pid}"))
}
