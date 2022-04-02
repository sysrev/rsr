#' transform answer table to list of answer tables 
#' @description
#' a special `basic` value in the list is populated by categorical boolean and string labels
#' every other value in the list represents a sysrev group label <rsr_group>
#' @inheritParams get_answers
#' @return list of tibbles
#' @export
list_answers = function(answers,concordance=F,collapse=F,enabled_only=T,token=get_srtoken()){
  if(concordance==F && collapse==T){rlang::abort(c(x="concordance must be T if collapse is T"))}
  if(any(map_lgl(answers$answer,~ class(.) != "character"))){ 
    rlang::abort(c(
      x="`answers` must be character that can be transformed to json",
      x="try `rsr::get_answers(...) |> list_answers()"
    ))
  }
  
  pco        = first(answers$opts)
  tidy.ans   = answers |> tidy_answers(concordance,collapse,enabled_only,token = token)
  
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
    else if(all(cons=="single")){    "single"     }
    else if(some(cons,~.=="single") && some(cons,~.=="concordant")){ "discordant" }
    else{ stop("cannot calculate consensus")}
  }
  
  tidy.ans.cons = if(!concordance){tidy.ans}else{
    tidy.ans |>
      group_by(aid) |> 
      mutate(concordant = concordant_collapse(lid,concordant,pco)) |> 
      mutate(consensus  = consensus_collapse(lid,consensus,pco)) |> 
      ungroup()
  }
  
  # TODO need to avoid making api calls in transformation functions
  lbl.tbl     = get_labels(first(answers$pid)) |> select(lid,short_label,project_ordering)
  groupcols   = if(concordance){c("aid","consensus","concordant")}else{c("aid","user_id")}
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