#' get_articles
#'
#' get the basic article data from a sysrev project
#' @param pid the project to get articles from, i.e sysrev.com/p/<project_id>
#' @param token a sysrev token with read access to the given project
#' @importFrom rlang .data
#' @return A dataframe
#' @export
#'
get_articles <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_articles",list(pid=pid),token) |>
    rename(aid=.data$article_id) |>
    tibble()
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
get_article <- function(aid,token=get_srtoken()){
  sysrev.rplumber("get_article",list(aid=aid),token) %>% tibble()
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
get_predictions <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_predictions",list(pid=pid),token) |>
    mutate(create_time = readr::parse_datetime(.data$create_time)) |>
    tibble()
}

#' get label definitions
#' @import tidyr
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
get_labels <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_labels",list(pid=pid),token) |> rename(lid=label_id) |> tibble()
}

#' get_users
#' get the users in a project
#' @import tidyr
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
get_users <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_users",list(pid=pid),token) |> tibble()
}

#' get_answers
#' @importFrom rlang .data
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
get_answers <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_answers",list(pid=pid),token) |>
    rename(aid=.data$article_id,lid=.data$label_id)|>
    tibble()
}

#' get_entities
#' @concept TODO this should really just be the same as get_articles?
#' @param pid The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @keywords internal
get_entities <- function(pid,token=get_srtoken()){
  query <- sprintf("{project(id:%d){articles{id,datasource_id,datasource_name}}}",pid)
  projectArticles <- sysrev.graphql(query,token)
}
