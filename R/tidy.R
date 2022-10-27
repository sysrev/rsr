#' get sysrev answers tibble with answers as rsr types
#' @rdname get_answers
#' @inheritParams get_answers
#' @param answers answers from a `get_answers` call
#' @return a tbl with tidy sysrev answers
#' @export
tidy_answers <- function(answers,concordance=F,collapse=F,enabled_only=T,token=get_srtoken()){
  pco        = first(answers$opts) # TODO - need to rethink this
  
  a1 = answers |> 
    group_by(lid) |> mutate(answer = srtidy_answer(answer, value_type)) |> ungroup() |> 
    filter(!is.na(answer)) # remove rows where answers tidy transform to NA
  
  if(!concordance && collapse){ warning("collapse cannot complete when concordance is false")}
  if(!concordance){ return(a1) }
  
  a2 = a1 |> # add label concordance and consensus
    group_by(aid,lid) |> 
    mutate(concordant  = concordant(answer, F, pco)) |> 
    mutate(consensus   = factor(case_when(
      any(resolve)    ~ "resolved",
      all(concordant) ~ "concordant",
      n() == 1        ~ "single",
      T               ~ "discordant"
    ))) |> 
    ungroup() 
  
  if(!collapse){ return(a2) }
  
  # collapse to top answer only for not-discordant article labels
  # removes user_id from tibble
  not.discordant = a2 |> 
    filter(consensus != "discordant") |> 
    arrange(desc(confirm_time),-resolve) |>
    group_by(aid,lid,short_label,value_type,consensus) |> slice(1) |> ungroup() |> 
    select(aid,lid,short_label,value_type,answer,consensus) |> 
    mutate(concordant = T)
  
  # collapses discordant article labels with srcollapse
  # removes user_id from tibble
  discordant = a2 |> 
    filter(consensus == "discordant") |> 
    group_by(aid,lid,short_label,value_type,consensus) |> 
    summarize(answer = srcollapse(answer)) |> 
    ungroup() |>
    select(aid,lid,short_label,value_type,answer,consensus) |> 
    mutate(concordant = F)
  
  dplyr::bind_rows(not.discordant,discordant)
}

tidy.answers.basic = function(ans){ map(ans,~ jsonlite::fromJSON(.) |> when(is_empty(.)~NA,~.)) }

#' tidy answers for group labels
#' @importFrom rlang .data
#' @param answer character vector json encoding for group labels
#' @return <rsr_group> vector which is a subclass of <tbl>
#' @keywords internal
tidy.answers.group   = function(answer){
  jsonans = purrr::map(answer,~jsonlite::fromJSON(.)$labels) |>
    purrr::map(\(grouplbl){ 
      a = discard(grouplbl, is_empty) # discard rows with no entries
      if(is_empty(names(a))){ return(NA) }  # discard group labels with no rows
      a |> purrr::set_names(as.character(1:length(a)))
    })
  
  longtb  = tibble( aid=seq_along(answer), answer = jsonans) |>
    filter(!is.na(answer)) |>
    tidyr::unnest_longer(answer,indices_to = "row") |>
    tidyr::unnest_longer(answer,indices_to = "lid") |>
    mutate(row=as.numeric(row)) |>
    select(.data$aid,.data$row,.data$lid,value=answer)
  
  groups  = longtb |> group_by(.data$aid) |> tidyr::nest() |> ungroup() |> 
    tidyr::complete(aid=seq_along(answer),fill=list(data=NA)) |> 
    pull(.data$data)

  groups |> 
    purrr::map_if(.p = ~!is.null(.), ~ structure(. ,class=c("rsr_group",class(.)))) |> 
    purrr::map_if(.p = is.null,      ~ structure(NA,class=c("rsr_group",class(NA)))) 
}

#' @title tidy.answer
#' parses character vector json encodings of answers to rsr value types
#' @param value_type 'boolean', 'categorical', 'string', or 'group'
#' @param answer a json anwer to transform
#' @param simplify if true, unlists the result
#' @keywords internal
srtidy_answer = function(answer,value_type,simplify=F){
  stopifnot(n_distinct(value_type)==1)

  parse = when(first(value_type),
               .=="group"   ~ tidy.answers.group,
                            ~ tidy.answers.basic )
  
  if(simplify){ unlist(parse(answer)) }else{ parse(answer) }
}
