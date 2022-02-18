#' conform reduces a list of answers and concordance statuses to a single conforming answer
#' TODO make this work!
#' @param answer 
#' @return
#' @export
conform = function(answer,resolve.answer){
  stop("not implemented")
}

#' get sysrev answers tibble with answers as rsr types
#' @rdname get_answers
#' @inheritParams get_answers
#' @param conform remove user_ids and use a single answer for each aid+lid
#' @importFrom rlang .data
#' @return a tbl with tidy sysrev answers
#' @export
get_answers_tidy = function(pid,concordance=F,concordant.collapse=F,token=get_srtoken()){

  pco = get_sroptions(pid,token=token)
  
  a1 = get_answers(pid,token = token) |> # get tidy sysrev answers
    group_by(lid) |> mutate(answer = srtidy_answer(answer, value_type)) |> ungroup()
  
  if(!concordance){ return(a1) }
  
  a2 = a1 |> group_by(aid,lid) |> 
    mutate(conc        = concordant(answer, F, pco),
           consensus   = factor(case_when(
             any(resolve) ~ "resolved",
             all(conc)    ~ "concordant",
             n() == 1     ~ "single",
             T            ~ "discordant"
           ))) |> 
    ungroup() 
  
  if(!concordant.collapse){ return(a2) }
  
  not.discordant = a2 |> 
    filter(consensus != "discordant") |> 
    arrange(desc(confirm_time),-resolve) |>
    group_by(aid,lid,short_label,value_type,consensus) |> slice(1) |> ungroup() |> 
    select(aid,lid,short_label,value_type,answer,consensus) |> 
    mutate(concordant = T)
  
  discordant = a2 |> 
    filter(consensus == "discordant") |> 
    group_by(aid,lid,short_label,value_type,consensus) |> 
    summarize(answer = srcollapse(answer)) |> 
    select(aid,lid,short_label,value_type,answer,consensus) |> 
    mutate(concordant = F)
  
  dplyr::bind_rows(not.discordant,discordant)
}

srcollapse = function(answer,pid){
  # input tests
  classes = map(answer,class)
  i       = purrr::detect_index(classes,.f = ~ any(. != classes[[1]]))
  if(i != 0){ rlang::abort(c("elements must be same class",x=glue("row {i} is wrong class"))) }
  
  # dispatch
  if(is.atomic(answer[[1]])){         return( list(unique(answer)) ) }
  if(classes[[1]][1] == "rsr_group"){ return( srcollapse.rsr_group(answer,pid) ) }
  
  abort(c(
    "unsupported srcollapse class",
    x=glue("class {classes[[1]]} is not supported")))
}

srcollapse.rsr_group = function(answer,pid){
  
  a1  = answer |> purrr::imap_dfr( ~ .x |> mutate(i=.y))
  
  # TODO collapse group labels should consider pco$consensus.labels 
  # But it seems like this can have perhaps surprising results for end user
  # For now we collapse a discordant group label by getting all the unique rows
  
  a1 |> 
    tidyr::nest(data = c(lid,value)) |> 
    select(data) |> distinct() |> 
    mutate(row=row_number()) |> 
    unnest(data) |> 
    select(row,lid,value) |> list()

}

#' @rdname get_answers
#' get a list of tidy answer tibbles
#' @description
#' a special `basic` value in the list is populated by categorical boolean and string labels
#' every other value in the list represents a sysrev group label <rsr_group>
#' @inheritParams get_answers
#' @param conform remove user_ids and use a single conformant answer for each aid+lid
#' @return list of tibbles
#' @export
get_answers_list = function(pid,concordance=F,concordant.collapse=F,token=get_srtoken()){
  
  tidy.ans   = get_answers_tidy(pid,
                                concordance         = concordance,
                                concordant.collapse = concordance.collapse)
  
  groupcols  = if(concordant.collapse){ c("aid") }else{ c("aid","user_id") }
  basic.tbl  = tidy.ans |>
    filter(value_type %in% c("categorical","boolean","string")) |>
    pivot_wider(id_cols = all_of(groupcols), names_from=short_label, values_from=answer)
  
  lbl.tbl = get_labels(pid,token=token)
  colnams = lbl.tbl |> pull(short_label)
  lookup.lidname  = lbl.tbl |>
    with(\(n){ pluck(short_label,which(lid==n),.default = n) }) |>
    Vectorize()
  
  tbls = tidy.ans |>
    filter(value_type == "group") |>
    select(-lid,-value_type) |>
    group_split(short_label) %>%
    (\(x){ set_names(x,map_chr(x,\(tbl){tbl$short_label[1]})) }) |>
    map(\(tbl){
      tbl |>
        unnest(answer) |> 
        pivot_wider(names_from=lid, values_from=value) |>
        rename_with(lookup.lidname) 
    })
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
