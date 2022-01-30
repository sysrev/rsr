#' @name get_
#' @title export tibbles from sysrev projects
#' @param pid a sysrev project id - sysrev.com/p/<pid>
#' @param token a sysrev token with read access to the given project
#' @return A tibble
NULL

#' @rdname get_
#' @export
get_articles <- function(pid,token=get_srtoken()){
  srplumber("get_articles",list(pid=pid),token) |>
    rename(aid=.data$article_id) |>
    tibble()
}

#' @rdname get_
#' @export
get_article_content <- function(pid,token=get_srtoken()){
  srplumber("get_article_content",list(pid=pid),token) |> tibble()
}


#' @rdname get_
#' @export
get_predictions <- function(pid,token=get_srtoken()){
  srplumber("get_predictions",list(pid=pid),token) |>
    mutate(create_time = readr::parse_datetime(.data$create_time)) |>
    tibble()
}

#' @rdname get_
#' @export
get_labels <- function(pid,token=get_srtoken()){
  srplumber("get_labels",list(pid=pid),token) |> dplyr::rename(lid=label_id) |> tidyr::tibble()
}

#' @rdname get_
#' @export
get_users <- function(pid,token=get_srtoken()){
  srplumber("get_users",list(pid=pid),token) |> tidyr::tibble()
}

#' @rdname get_answers
#' @inheritParams get_
#' @export
get_answers <- function(pid,token=get_srtoken()){
  srplumber("get_answers",list(pid=pid),token) |>
    rename(aid=.data$article_id,lid=.data$label_id)|>
    tibble()
}

#' get sysrev project/options with a name or id
#' @param name the sysrev to get metadata from
#' @inheritParams get_
#' @return A dataframe
#' @export
get_sysrev <- function(name,pid=NA,token=get_srtoken()){
  srplumber("get_sysrev",list(name=name),token)
}

#' get sysrevs owned by the given organization
#' @param oname organization name (cap sensitive for now)
#' @inheritParams common_params
#' @export
get_sysrevs = function(oname,token=get_srtoken()){
  srplumber("get_sysrevs",list(oname=oname),token) |> tibble()
}

# get_reviewer_activity = function(pid,uid){
#   a = tbl(.pool,"reviewer_event") |> filter(user_id==4741) |> collect() 
#   b = a |> mutate(day = lubridate::date(created)) |> group_by(day) |> count() |> ungroup()
#   c= b |> 
#     complete(day=seq(ymd("2021-08-13"),ymd("2021-12-30"),by="days"),fill = list(n=0)) |> 
#     mutate(n = factor(case_when(
#       day > today() ~ "NA",
#       n ==0~"none",
#       n<2~"low",
#       n<14~"med",
#       T ~"high"),levels=c("none","low","med","high"))) |>
#     mutate(week = week(day))
#   
#   ggplot(c,aes(x=week, y=(wday(day)+1)%%7, fill=n)) + geom_tile(col="#0e1117ff",size=2) + coord_fixed() +
#     scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand = c(0,0)) +
#     scale_fill_manual(values = c("#171b22ff","#1d3642ff","#29606aff","#5ecec0ff"),na.value = "#0e1117ff") + 
#     theme(plot.background = element_rect(fill = "#0e1117ff")) + xlab("") + ylab("") +
#     ggtitle("vanessa-saul@t-online.de activity") + xlab("") + ylab("")
#   
# }