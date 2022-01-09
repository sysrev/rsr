#' review
#' @import jsonlite
#' @import dplyr
#' @import glue
#' @importFrom stats setNames
#' @param pid the project id to update
#' @param aid the article id within the project id to update
#' @param lid the label id to update (see \link[rsr]{get_labels})
#' @param lval the new value - this is an R object that can be parsed into json.
#' @param resolve treat this label update as resolve (use the default if you don't know what this means)
#' @param change treat this label update as a change (use default if you don't know what this means)
#' @param confirm treat this label update as a confirmed label (use default if you don't know what this means)
#' @param token a token with write acces
#' @return true if successful
#' @export
review <- function(pid,aid,lid,lval,resolve=T,change=T,confirm=T,token=get_srtoken()){
  lvals = list(lval) |> setNames(lid) |> jsonlite::toJSON(auto_unbox=T) |> toString()
  query = glue::glue("mutation {{
                     setLabels(
                      projectID:{pid},articleID:{aid},
                      confirm:{confirm},resolve:{resolve},change:{change},
                      labelValues:{glue::double_quote(lvals)}
                     )}}",
                     confirm = jsonlite::toJSON(confirm,auto_unbox = T),
                     resolve = jsonlite::toJSON(resolve,auto_unbox = T),
                     change  = jsonlite::toJSON(change, auto_unbox = T),
                     lvals   = lvals)

  sysrev.graphql(query = query,token = token)
}
