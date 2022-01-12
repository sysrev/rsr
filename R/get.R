#' basic getters
#' @description export tibbles from sysrev projects
#' @param pid the project to get articles from, i.e sysrev.com/p/<project_id>
#' @param token a sysrev token with read access to the given project
#' @return A tibble
#' @name get_
NULL

#' @rdname get_
#' @export
get_articles <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_articles",list(pid=pid),token) |>
    rename(aid=.data$article_id) |>
    tibble()
}

#' @rdname get_
#' @export
get_predictions <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_predictions",list(pid=pid),token) |>
    mutate(create_time = readr::parse_datetime(.data$create_time)) |>
    tibble()
}

#' @rdname get_
#' @export
get_labels <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_labels",list(pid=pid),token) |> dplyr::rename(lid=label_id) |> tidyr::tibble()
}

#' @rdname get_
#' @export
get_users <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_users",list(pid=pid),token) |> tidyr::tibble()
}

#' @rdname get_answers
#' @inheritParams get_
#' @export
get_answers <- function(pid,token=get_srtoken()){
  sysrev.rplumber("get_answers",list(pid=pid),token) |>
    rename(aid=.data$article_id,lid=.data$label_id)|>
    tibble()
}
