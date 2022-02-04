#' get sysrev answers tibble with answers as rsr types
#' @rdname get_answers
#' @import dplyr
#' @importFrom rlang .data
#' @param drop.resolved.discordant remove answers for articles that have a resolved alternative?
#' @inheritParams get_answers
#' @return a tbl with tidy sysrev answers
#' @export
get_answers_tidy = function(pid,drop.resolved.discordant=F,token=get_srtoken()){

  pco = get_sroptions(pid,token=token)

  a = get_answers(pid,token = token) |> # get tidy sysrev answers
    group_by(.data$lid) |> mutate(answer = srtidy_answer(.data$answer, .data$value_type)) |> ungroup() |>
    group_by(.data$aid) |> # filter out reviews superseded by a resolve review
    (\(tbl){ purrr::when(drop.resolved.discordant,
                         T ~ tbl |> filter(.data$resolve == max(.data$resolve)),
                         F ~ tbl )})() |> ungroup()

  b = a |> # calculate concordance by aid
    group_by(aid, lid) |> mutate(conc = concordant(answer, F, pco)) |> ungroup() |>
    mutate(conc = max(conc, lid %in% pco$consensus.labels)) |>
    group_by(aid) |> mutate(conc = all(conc)) |> ungroup() |>
    group_by(aid) |> mutate(reviews = n_distinct(.data$user_id)) |> ungroup()

  # calculate a concordance status
  b |> mutate(
    conc.status = case_when(
      resolve      ~ "resolved",
      reviews == 1 ~ "single",
      conc         ~ "concordant",
      T            ~ "discordant"
    ),
    .keep = "unused"
  )
}

#' get a list of tidy answer tibbles
#'
#' @description
#' a special `basic` value in the list is populated by categorical boolean and string labels
#' every other value in the list represents a sysrev group label <rsr_group>
#' @rdname get_answers
#' @inheritParams get_answers
#' @importFrom rlang .data
#' @importFrom tidyr pivot_wider unnest
#' @importFrom purrr map_chr map set_names pluck
#' @return list of tibbles
#' @export
get_answers_list = function(pid,token=get_srtoken()){

  tidy.ans   = get_answers_tidy(pid,token=token)

  basic.tbl  = tidy.ans |>
    filter(.data$value_type %in% c("categorical","boolean","string")) |>
    select(-.data$lid,-.data$value_type) |>
    mutate(answer = map_chr(.data$answer,~paste(.,collapse=";"))) |>
    pivot_wider(names_from=.data$short_label,values_from = .data$answer)

  lookup.lidname  = get_labels(pid,token=token) |>
    with(\(n){ pluck(short_label,which(lid==n),.default = n) }) |>
    Vectorize()

  tbls = tidy.ans |>
    filter(.data$value_type == "group") |>
    select(-.data$lid,-.data$value_type) |>
    group_split(.data$short_label) %>%
    (\(x){ set_names(x,map_chr(x,\(tbl){tbl$short_label[1]})) }) |>
    map(\(tbl){
      tbl |>
        unnest(.data$answer) |>
        mutate(value=map_chr(.data$value,~paste(.,collapse=";"))) |>
        pivot_wider(names_from=.data$lid,values_from=.data$value) |>
        rename_with(lookup.lidname)
    })

  c(list(basic=basic.tbl),tbls)
}

tidy.answers.basic   = function(answer){ lapply(answer,jsonlite::fromJSON) }
tidy.answers.boolean = function(answer){ lapply(answer,\(x) case_when(x=="true"~T,x=="false"~F,NULL)) }

#' tidy answers for group labels
#' @importFrom rlang .data
#' @param answer character vector json encoding for group labels
#' @return <rsr_group> vector which is a subclass of <tbl>
#' @keywords internal
tidy.answers.group   = function(answer){
  longtb = tibble( aid=seq_along(answer), answer = purrr::map(answer,~jsonlite::fromJSON(.)$labels)) |>
    tidyr::unnest_longer(answer,indices_to = "row") |>
    tidyr::unnest_longer(answer,indices_to = "lid") |>
    mutate(row=as.numeric(row)) |>
    select(.data$aid,.data$row,.data$lid,value=answer)
  
  empty.t = tibble(row=numeric(),lid=character(),list())
  groups  = longtb |> group_by(.data$aid) |> tidyr::nest() |> ungroup() |> 
    tidyr::complete(aid=seq_along(answer),fill=list(data=list(empty.t))) |> 
    pull(.data$data)

  purrr::map(groups, ~ structure(.,class=c("rsr_group",class(.))))
}

tidy.answers.annotation = function(answer){

}

#' @title tidy.answer
#' parses character vector json encodings of answers to rsr value types
#' @param value_type 'boolean', 'categorical', 'string', or 'group'
#' @param answer a json anwer to transform
#' @param simplify if true, unlists the result
#' @keywords internal
srtidy_answer = function(answer,value_type,simplify=F){
  stopifnot(n_distinct(value_type)==1)

  res = answer |> switch(first(value_type),
                         boolean     = tidy.answers.boolean,
                         categorical = tidy.answers.basic,
                         string      = tidy.answers.basic,
                         annotation  = tidy.answers.annotation,
                         group       = tidy.answers.group)()


  if(simplify){ unlist(res) }else{ res }
}
