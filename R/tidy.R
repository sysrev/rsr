#' get sysrev answers tibble with answers as rsr types
#' @rdname get_answers
#' @inheritParams get_answers
#' @importFrom rlang .data
#' @return a tbl with tidy sysrev answers
#' @export
get_answers_tidy = function(pid,concordance=F,collapse=F,enabled.only=T,token=get_srtoken()){

  pco        = get_sroptions(pid,token=token)
  legal.lbls = get_labels(pid,enabled.only = enabled.only) |> pull(lid)
  
  a1 = get_answers(pid,token = token) |> # get tidy sysrev answers
    group_by(lid) |> mutate(answer = srtidy_answer(answer, value_type)) |> ungroup()
  
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
  
  rlang::abort(c(
    "unsupported srcollapse class",
    x=glue("class {paste(classes[[1]],collapse=', ')} is not supported")))
}

srcollapse.rsr_group = function(answer,pid){
  
  a1  = answer |> purrr::imap_dfr( ~ .x |> mutate(i=.y))
  
  # TODO collapse group labels should consider pco$consensus.labels 
  # But it seems like this can have perhaps surprising results for end user
  # For now we collapse a discordant group label by getting all the unique rows
  
  a1 |> 
    tidyr::nest(data = c(lid,value)) |> 
    select(.data$data) |> distinct() |> 
    mutate(row=row_number()) |> 
    unnest(.data$data) |> 
    select(row,lid,value) |> list()

}

#' get a list of tidy answer tibbles
#' @description
#' a special `basic` value in the list is populated by categorical boolean and string labels
#' every other value in the list represents a sysrev group label <rsr_group>
#' @inheritParams get_answers
#' @return list of tibbles
#' @export
get_answers_list = function(pid,concordance=F,collapse=F,token=get_srtoken()){
  
  if(concordance==F && collapse==T){rlang::abort(c(x="concordance must be T if collapse is T"))}
  pco        = get_sroptions(pid)
  tidy.ans   = get_answers_tidy(pid,concordance,collapse)
  
  
  # gets article level consensus
  # if any label is resolved - treat article as resolved
  # concordant if all labels concordant
  # otherwise single or discordant
  concordant_collapse = function(lid,concordant,pco){
    tibble(lid,concordant) |> 
      filter(lid %in% pco$consensus.labels) |>
      with(all(concordant))
  }
  
  consensus_collapse  = function(lid,cons,pco){
    conc = tibble(lid,cons) |> 
      filter(lid %in% pco$consensus.labels) |>
      with(all(cons=="concordant"))
    
    if("resolved" %in% cons){        "resolved"   }
    else if(conc){                   "concordant" }
    else if("discordant" %in% cons){ "discordant" }
    else if("single"     %in% cons){ "single"     }
    else{ stop("cannot calculate consensus")}
  }
  
  tidy.ans.cons = if(!concordance){tidy.ans}else{
    tidy.ans |>
      group_by(aid) |> 
      mutate(concordant = concordant_collapse(lid,concordant,pco)) |> 
      mutate(consensus  = consensus_collapse(lid,consensus,pco)) |> 
      ungroup()
  }
  
  groupcols   = if(concordance){c("aid","consensus","concordant")}else{c("aid","user_id")}
  lbl.tbl     = get_labels(pid) |> select(lid,short_label,project_ordering)
  basic.tbl   = tidy.ans.cons |>
    filter(value_type %in% c("categorical","boolean","string")) |>
    inner_join(lbl.tbl |> select(lid,project_ordering),by="lid") |>  # filter out excluded labels
    arrange(aid,project_ordering) |> 
    pivot_wider(id_cols = all_of(groupcols), names_from=short_label, values_from=answer)
  
  tbls = tidy.ans.cons |>
    filter(value_type == "group") |>
    select(-lid,-value_type) %>% 
    split(.,.$short_label) |> 
    map(\(tbl){
      tbl |> 
        select(-short_label) |> 
        unnest(answer,keep_empty = F) |> 
        inner_join(lbl.tbl,by="lid") |> # filter out excluded labels
        arrange(aid,project_ordering) |> 
        mutate(value = set_names(value,NULL)) |> 
        pivot_wider(id_cols = c(groupcols,"row"), names_from=short_label, values_from=value, values_fn = list)
    })
  
  res = c(list(basic=basic.tbl),tbls)
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
