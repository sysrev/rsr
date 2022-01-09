#' get sysrev answers tibble with answers as rsr types
#' @import dplyr
#' @importFrom rlang .data
#' @param drop.resolved.discordant remove answers for articles that have a resolved alternative?
#' @inheritParams get_answers
#' @return a tbl with tidy sysrev answers
#' @export
get_answers_tidy = function(pid,drop.resolved.discordant=F,token=get_srtoken()) {

  pco = get_sroptions(pid,token=token)

  a = get_answers(pid,token = token) |> # get tidy sysrev answers
    group_by(.data$lid) |> mutate(answer = srtidy_answer(.data$answer, .data$value_type)) |> ungroup() |>
    group_by(.data$aid) |> # filter out reviews superseded by a resolve review
    (\(tbl){ purrr::when(drop.resolved.discordant,
                         T ~ tbl |> filter(.data$resolve == max(.data$resolve)) |> ungroup(),
                         F ~ tbl )})()

  b = a |> # calculate concordance by aid
    group_by(.data$aid, .data$lid) |> mutate(conc = concordant(.data$answer, F, pco)) |> ungroup() |>
    mutate(conc = max(.data$conc, .data$lid %in% pco$consensus.labels)) |>
    group_by(.data$aid) |> mutate(conc    = all(.data$conc)) |> ungroup() |>
    group_by(.data$aid) |> mutate(reviews = n_distinct(.data$user_id)) |> ungroup()

  # calculate a concordance status
  b |> mutate(
    conc.status = case_when(
      resolve      ~ "resolved",
      conc         ~ "concordant",
      reviews == 1 ~ "single",
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

tidy.answers.basic   = function(answer){ lapply(answer,jsonparse::from_json) }
tidy.answers.boolean = function(answer){ lapply(answer,\(x) case_when(x=="true"~T,x=="false"~F,NULL)) }

#' @title tidy.answer
#' @importFrom rlang .data
#' @param answer character vector json encoding for group labels
#' @return <rsr_group> vector which is a subclass of <tbl>
#' @keywords internal
tidy.answers.group   = function(answer){
  longtb = tibble( aid=seq_along(answer), answer = purrr::map(answer,~jsonparse::from_json(.)$labels)) |>
    tidyr::unnest_longer(answer,indices_to = "row") |>
    tidyr::unnest_longer(answer,indices_to = "lid") |>
    mutate(row=as.numeric(row)) |>
    select(.data$aid,.data$row,.data$lid,value=answer)

  groups = longtb |> group_by(.data$aid) |> nest() |> ungroup() |> pull(data)

  purrr::map(groups, ~ structure(.,class=c("rsr_group",class(.))))
}

#' @title tidy.answer
#' parses character vector json encodings of answers to rsr value types
#' @param value_type 'boolean', 'categorical', 'string', or 'group'
#' @param answer a json anwer to transform
#' @param simplify if true, unlists the result
#' @export
srtidy_answer = function(answer,value_type,simplify=F){
  stopifnot(n_distinct(value_type)==1)

  res = answer |> switch(first(value_type),
                         boolean     = tidy.answers.boolean,
                         categorical = tidy.answers.basic,
                         string      = tidy.answers.basic,
                         group       = tidy.answers.group)()


  if(simplify){ unlist(res) }else{ res }
}
