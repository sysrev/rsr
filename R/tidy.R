tidy.answers.basic   = function(answer){ lapply(answer,jsonparse::from_json) }
tidy.answers.boolean = function(answer){ lapply(answer,\(x) case_when(x=="true"~T,x=="false"~F,NULL)) }

#' @title tidy.answer
#' @importFrom rlang .data
#' @param answer character vector json encoding for group labels
#' @return <srr_group> vector which is a subclass of <tbl>
#' @keywords internal
tidy.answers.group   = function(answer){
  longtb = tibble( aid=seq_along(answer), answer = purrr::map(answer,~jsonparse::from_json(.)$labels)) |>
    tidyr::unnest_longer(answer,indices_to = "row") |>
    tidyr::unnest_longer(answer,indices_to = "lid") |>
    mutate(row=as.numeric(row)) |>
    select(.data$aid,.data$row,.data$lid,value=answer)

  groups = longtb |> group_by(.data$aid) |> nest() |> ungroup() |> pull(data)

  purrr::map(groups, ~ structure(.,class=c("srr_group",class(.))))
}

#' @title tidy.answer
#' parses character vector json encodings of answers to srr value types
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
