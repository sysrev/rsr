#' Get user answers from project
#'
#' Get user answers in a long form data frame
#' @param project The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
sysrev.getLabelAnswers <- function(project,token=keyring::key_get("sysrev.token")){
  query <- sprintf('{project(id:%d){id articles{id, enabled, labels{id, question, name, answer, created,
    consensus,resolve,confirmed,updated,type,reviewer{id,name}}}}}',project)
  res   <- sysrev.graphql(query,token)
  fnil <- function(v,default=NA){if(is.null(v)){NA}else{v}}
  lists <- purrr::flatten(lapply(res$project$articles,function(art){
    purrr::flatten(lapply(art$labels,function(lbl){
      lapply(lbl$answer,function(answer){
        c(
          project.id      = fnil(res$project$id),
          article.id      = fnil(art$id),
          article.enabled = fnil(art$enabled),
          lbl.id          = fnil(lbl$id),
          lbl.name        = fnil(lbl$name),
          lbl.question    = fnil(lbl$question),
          lbl.type        = fnil(lbl$type),
          answer.created  = fnil(lbl$created),
          answer.updated  = fnil(lbl$updated),
          answer.resolve  = fnil(lbl$resolve),
          answer.confirmed= fnil(lbl$confirmed),
          answer.consensus= fnil(lbl$consensus),
          reviewer.id     = fnil(lbl$reviewer$id),
          reviewer.name   = fnil(lbl$reviewer$name),
          answer          = fnil(answer))
      })
    }))
  }))

  df <- as.data.frame(do.call(rbind,lists),stringsAsFactors = F)


  dplyr::mutate(df,
          project.id      = as.numeric(project.id),
          article.id      = as.numeric(article.id),
          article.enabled = as.logical(article.enabled),
          lbl.id          = as.character(lbl.id),
          lbl.name        = as.character(lbl.name),
          lbl.question    = as.character(lbl.question),
          lbl.type        = as.character(lbl.type),
          answer.resolve  = readr::parse_datetime(answer.resolve),
          answer.created  = readr::parse_datetime(answer.created),
          answer.updated  = readr::parse_datetime(answer.updated),
          answer.confirmed= readr::parse_datetime(answer.confirmed),
          answer.consensus= as.logical(answer.consensus),
          reviewer.id     = as.numeric(reviewer.id),
          reviewer.name   = as.character(reviewer.name),
          answer          = as.character(answer))
}

