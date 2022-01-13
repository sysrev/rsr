#' @name common_params
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
#' @param multi does this label take multiple answers? (eventually will be automated)
#' @param resolve treat this label update as resolve (use the default if you don't know what this means)
#' @param change treat this label update as a change (use default if you don't know what this means)
#' @return true if successful
#' @export
review <- function(pid,aid,lid,answer,
                   multi = T,change = T,resolve = F,
                   token = get_srtoken()){

  lvals = list(answer) |> stats::setNames(lid) |> jsonlite::toJSON(auto_unbox = !multi)
  query = glue::glue("mutation {{
                     setLabels(
                      projectID:{pid},articleID:{aid},
                      confirm:{confirm},resolve:{resolve},change:{change},
                      labelValues:{glue::double_quote(lvals)}
                     )}}",
                     confirm = jsonlite::toJSON(T,auto_unbox = T),
                     resolve = jsonlite::toJSON(resolve,auto_unbox = T),
                     change  = jsonlite::toJSON(change, auto_unbox = T),
                     lvals   = lvals)

  sysrev.graphql(query = query,token = token)
}
