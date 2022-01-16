#' @name common_params
#' @title common_params
#' @description provides common argument descriptions
#' @param pid the project id to update
#' @param aid the article id within the project id to update
#' @param lid the label id to update
#' @param token a token with write acces
#' @keywords internal
NULL

#' set the value of a given article+label
#' @inheritParams common_params
#' @importFrom jsonlite toJSON
#' @param answer the new value - this is an R object that can be parsed into json.
#' @param resolve treat this label update as resolve (use the default if you don't know what this means)
#' @param change treat this label update as a change (use default if you don't know what this means)
#' @return true if successful
#' @export
review <- function(pid,aid,lid,answer,change = T,resolve = F,token = get_srtoken()){
  body = as.list(environment())
  srplumber.post("review",body,token)
}
