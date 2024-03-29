#' @name get_
#' @title export tibbles from sysrev projects
#' @param pid a sysrev project id - sysrev.com/p/<pid>
#' @param token a sysrev token with read access to the given project
#' @return A tibble
NULL

#' @rdname get_
#' @export
get_articles <- function(pid,enabled_only=T,token=get_srtoken()){
  res = srplumber("get_articles",list(pid=pid),token) |>
    rename(aid=.data$article_id) |>
    tibble()
  if(enabled_only) res |> filter(enabled) else res
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
#' @description get labels from a sysrev
#' @param enabled_only filter out disabled labels (default T)
#' @export
get_labels <- function(pid,enabled_only=T,token=get_srtoken()){
  a = srplumber("get_labels",list(pid=pid),token) |> 
    rename(lid=label_id) |>
    tibble() 
  
  if(enabled_only){ a |> filter(.data$enabled) }else{ a }
}

#' @rdname get_
#' @export
get_users <- function(pid,token=get_srtoken()){
  srplumber("get_users",list(pid=pid),token) |> tidyr::tibble()
}

#' @rdname get_answers
#' @param enabled_only only get answers from enabled articles?
#' @param concordance whether to compute concordance
#' @param collapse whether to remove user_ids and collapse answers
#' @inheritParams get_
#' @export
get_answers <- function(pid,enabled_only=T,token=get_srtoken()){
  # TODO remove call to get_articles, handle on srplumber side
  articles <- rsr::get_articles(pid,enabled_only,token = token) |> select(aid,title)
  opts     <- rsr::get_sroptions(pid,token=token)
  answers  <- srplumber("get_answers",list(pid=pid),token) |>
    mutate(opts = list(opts), pid = pid) |>
    rename(aid=article_id,lid=label_id) |>
    tibble()
  articles |> inner_join(answers,by="aid")
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