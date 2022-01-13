#' open browser to sysrev project,article,etc.
#' @inheritParams common_params
#' @name browse_
NULL

#' @rdname browse_
#' @export
browse_sysrev = function(pid){
  utils::browseURL(glue::glue("https://sysrev.com/p/{pid}"))
}

#' @rdname browse_
#' @export
browse_article = function(pid,aid){
  utils::browseURL(glue("https://sysrev.com/p/{pid}/article/{aid}"))
}
