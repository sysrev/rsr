#' browse_sysrev
#' open browser to sysrev project page
#' @param pid syrev project id
#' @export
browse_sysrev = function(pid){
  utils::browseURL(glue::glue("https://sysrev.com/p/{pid}"))
}

#' view_article
#' opens the given project article in a browser
#' @import utils
#' @import glue
#' @param pid project id to view
#' @param aid article id to view
#' @return nothing
#' @export
browse_article = function(pid,aid){
  browseURL(glue("https://sysrev.com/p/{pid}/article/{aid}"))
}
