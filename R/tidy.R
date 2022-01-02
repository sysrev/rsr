tidy.answers.basic   = function(answer){ lapply(answer,jsonparse::from_json) }
tidy.answers.boolean = function(answer){ lapply(answer,\(x) case_when(x=="true"~T,x=="false"~F,NULL)) }

#' @title tidy.answer
#' @importFrom rlang .data
#' @param answer character vector json encoding for group labels
#' @return <rsr_group> vector which is a subclass of <tbl>
tidy.answers.group   = function(answer){
  tibble(
    aid=seq_along(answer),
    answer = purrr::map(answer,~jsonparse::from_json(.)$labels)) |>
    tidyr::unnest_longer(answer,indices_to = "row") |>
    tidyr::unnest_longer(answer,indices_to = "lid") |>
    select(.data$aid,.data$row,.data$lid,value=.data$.answer) |>
    group_by(.data$aid) |> nest() |> ungroup() |> pull(data) |>
    purrr::map(~ structure(.,class=c(class(.),"rsr_group")))
}

#' @title tidy.answer
#' parses character vector json encodings of answers to rsr value types
#' @param value_type 'boolean', 'categorical', 'string', or 'group'
#' @param answer a json anwer to transform
#' @export
tidy.answer = function(value_type,answer){

  answer |> switch(first(value_type),
                   boolean     = tidy.answers.boolean,
                   categorical = tidy.answers.basic,
                   string      = tidy.answers.basic,
                   group       = tidy.answers.group)()
}
