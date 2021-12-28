#' get_articles
#'
#' get the basic article data from a sysrev project
#' @param pid the project to get articles from, i.e sysrev.com/p/<project_id>
#' @param token a sysrev token with read access to the given project
#'
#' @return A dataframe
#' @export
#'
get_articles <- function(pid,token=keyring::key_get("sysrev.token")){
  rplumber("get_articles",list(pid=pid),token) %>% tibble()
}

#' get_article
#'
#' get the basic article data from a sysrev project
#' @param aid the article to get data for
#' @param token a sysrev token with read access to the given project
#'
#' @return A dataframe
#' @export
#'
get_article <- function(aid,token=keyring::key_get("sysrev.token")){
  rplumber("get_article",list(aid=aid),token) %>% tibble()
}

#' get_predictions
#'
#' get the predictions for a project
#' @param pid the project to get articles from, i.e sysrev.com/p/<project_id>
#' @param token a sysrev token with read access to the given project
#' @importFrom rlang .data
#' @return A dataframe
#' @export
#'
get_predictions <- function(pid,token=keyring::key_get("sysrev.token")){
  rplumber("get_predictions",list(pid=pid),token) |>
    mutate(create_time = readr::parse_datetime(.data$create_time)) |>
    tibble()
}

#' get_labels
#' TODO this needs some refactoring
#' get the label definitions in a project
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
get_labels <- function(pid,token=keyring::key_get("sysrev.token")){
  query <- sprintf('{project(id:%d){id labelDefinitions{id,name,question,ordering,required,type,consensus,enabled}}}',pid)
  res   <- sysrev.graphql(query,token)
  fnil <- function(v,default=NA){if(is.null(v)){NA}else{v}}
  lists <- lapply(res$project$labelDefinitions,function(ld){
    c(
      project.id   = fnil(res$project$id),
      lbl.id       = fnil(ld$id),
      lbl.name	   = fnil(ld$name),
      lbl.question = fnil(ld$question),
      lbl.ordering = fnil(ld$ordering),
      lbl.required = fnil(ld$required),
      lbl.type     = fnil(ld$type),
      lbl.consensus= fnil(ld$consensus),
      lbl.enabled  = fnil(ld$enabled))
  })

  df <- as.data.frame(do.call(rbind,lists),stringsAsFactors = F)


  dplyr::mutate(df,
                project.id      = as.numeric(project.id),
                lbl.id          = as.character(lbl.id),
                lbl.name        = as.character(lbl.name),
                lbl.question    = as.character(lbl.question),
                lbl.ordering	  = as.numeric(lbl.ordering),
                lbl.required	  = as.logical(lbl.required),
                lbl.type        = as.character(lbl.type),
                lbl.consensus	  = as.logical(lbl.consensus),
                lbl.enabled     = as.logical(lbl.enabled)) %>% tibble()
}

#' get_labels_tbl
#' a simpler verison of get_labels
#' @import tidyr
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
get_labels_tbl <- function(pid,token=keyring::key_get("sysrev.token")){
  rplumber("get_labels",list(pid=pid),token) |> rename(lbl.id=label_id)|> tibble()
}

#' get_users
#' get the users in a project
#' @import tidyr
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
get_users <- function(pid,token=keyring::key_get("sysrev.token")){
  rplumber("get_users",list(pid=pid),token) |> tibble()
}

#' get_answers
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
get_answers <- function(pid,token=keyring::key_get("sysrev.token")){
  rplumber("get_answers",list(pid=pid),token) |> rename(lbl.id=label_id)|> tibble()
}
