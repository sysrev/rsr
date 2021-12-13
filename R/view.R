#' view_article
#' opens the given project article in a browser
#' @import utils
#' @import glue
#' @param pid project id to view
#' @param aid article id to view
#' @return nothing
#' @export
view_article = function(pid,aid){
  browseURL(glue("https://sysrev.com/p/{pid}/article/{aid}",pid=pid,aid=aid))
}
