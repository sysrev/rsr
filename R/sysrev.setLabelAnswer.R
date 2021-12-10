#' review
#'
#'
#' @param project.id the project id to update
#' @param article.id the article id within the project id to update
#' @param lbl.id the label id to update (see \link[RSysrev]{sysrev.getLabelDefinitions})
#' @param lbl.value the new value
#' @param token a token with write access
#'
#' @return true if successful
#' @export
review <- function(project.id,article.id,lbl.id,lbl.value,token=keyring::key_get("sysrev.token")){
  lvals  = list() %>% (function(l){l[[lbl.id]] = lbl.value; l})
  lvaljs = jsonlite::toJSON(lvals,auto_unbox = T) %>% jsonlite::toJSON(auto_unbox = T)
  params = list(
    projectID   = project.id,
    articleID   = article.id,
    confirm     = jsonlite::toJSON(T,auto_unbox = T),
    resolve     = jsonlite::toJSON(F,auto_unbox = T),
    change      = jsonlite::toJSON(T,auto_unbox = T),
    labelValues = lvaljs)

  qstr   = "mutation {
    setLabels(
        projectID: $projectID,
        articleID: $articleID,
        confirm: $confirm,
        resolve: $resolve,
        change: $change,
        labelValues: $labelValues)}"

  gql.mutation = with(params,gsubfn::fn$identity(qstr))
  sysrev.graphql(gql.mutation,token = token)
}
