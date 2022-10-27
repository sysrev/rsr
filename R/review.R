#' @name common_params
#' @title common_params
#' @description provides common argument descriptions
#' @param pid the project id to update
#' @param aid the article id within the project id to update
#' @param lid the label id to update
#' @param token a token with write acces
#' @keywords internal
NULL

#' set the value of a given article+label
#' @inheritParams common_params
#' @importFrom jsonlite toJSON
#' @param answer the new value - this is an R object that can be parsed into json.
#' @param resolve treat this label update as resolve (use the default if you don't know what this means)
#' @param change treat this label update as a change (use default if you don't know what this means)
#' @param raw.json treat this as raw.json?
#' @return true if successful
#' @export
review <- function(pid,aid,lid,answer,change = T,resolve = F,raw.json=F,token = get_srtoken()){
  body = as.list(environment())
  srplumber.post("review",body,token)
}

#' set the value of a given article+label
#' @importFrom pbapply pblapply
#' @param src.pid source project
#' @param tgt.pid target project
#' @return list of modified articles
#' @export
copy_answers = function(src.pid,tgt.pid){
  
  src.glid = get_labels(src.pid) |> select(lid,global_label_id)
  
  # get all the labels that were cloned
  CPY.lid = get_labels(tgt.pid) |> 
    inner_join(src.glid,by="global_label_id") |>  
    select(lid=lid.y, cpy.lid=lid.x)
  
  # Link articles between ESR and CPY by article_data_id
  ART.link  = get_articles(src.pid) |> 
    inner_join(get_articles(tgt.pid),by="article_data_id") |> 
    select(aid=aid.x,cpy.aid=aid.y)
  
  # Link old answers to new articles
  import = get_answers(src.pid) |> 
    tidy_answers(concordance=T,collapse=T) |>
    inner_join(ART.link,by="aid") |> # link articles
    inner_join(CPY.lid, by="lid") |> # link labels
    select(aid=cpy.aid,lid=cpy.lid,value_type,answer)
      
  1:nrow(import) |> pbapply::pblapply(function(i){
    if(import$value_type[[i]] == "categorical"){
      answer <- as.list(import$answer[[i]])
      review(pid = tgt.pid, aid = import$aid[[i]], lid = import$lid[[i]], answer = answer)
    }else if(import$value_type[[i]] == "boolean"){
      review(pid = tgt.pid, aid = import$aid[[i]], lid = import$lid[[i]], answer = import$answer[[i]])
    }else{
      stop(sprintf("value type of %s not yet supported",import$value_type[[i]]))
    }
  })
  
}