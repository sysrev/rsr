#' browse_sysrev
#' open browser to sysrev project page
#' @param pid syrev project id
#' @export
browse_sysrev = function(pid){
  utils::browseURL(glue::glue("https://sysrev.com/p/{pid}"))
}
