#' review
#' @import jsonlite
#' @import dplyr
#' @import glue
#' @param pid the project id to update
#' @param aid the article id within the project id to update
#' @param lid the label id to update (see \link[rsysrev]{get_labels})
#' @param lval the new value
#' @param resolve treat this label update as resolve (use the default if you don't know what this means)
#' @param change treat this label update as a change (use default if you don't know what this means)
#' @param confirm treat this label update as a confirmed label (use default if you don't know what this means)
#' @param token a token with write acces
#' @return true if successful
#' @export
review <- function(pid,aid,lid,lval,resolve=T,change=T,confirm=T,token=keyring::key_get("sysrev.token")){
  query = glue("mutation {{ setLabels( projectID:{pid},articleID:{aid},
               confirm:{confirm},resolve:{resolve},change:{change},
               labelValues:{double_quote(lvals)})}}",
               confirm = toJSON(confirm,auto_unbox = T), resolve = toJSON(resolve,auto_unbox = T), change  = toJSON(change, auto_unbox = T),
               lvals = list() %>% (function(l){l[[lid]] = lval; l}) |> toJSON(auto_unbox=T) |> toString())

  sysrev.graphql(query = query,token = token)
}
