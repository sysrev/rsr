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
#' @param source.pid source project
#' @param target.pid target project
#' @return list of modified articles
#' @export
copy_answers = function(source.pid,target.pid){
  
  src.glid = rsr::get_labels(source.pid) |> 
    select(lid,global_label_id)
  
  # get all the labels that were cloned
  CPY.lid = rsr::get_labels(target.pid) |> 
    inner_join(src.glid,by="global_label_id") |>  
    select(lid=.data$lid.y, cpy.lid=.data$lid.x)
  
  # Link articles between ESR and CPY by article_data_id
  ART.link  = rsr::get_articles(source.pid) |> 
    inner_join(rsr::get_articles(target.pid),by="article_data_id") |> 
    select(aid=.data$aid.x,cpy.aid=.data$aid.y)
  
  # Link old answers to new articles
  import = rsr::get_answers(source.pid) |> 
    inner_join(ART.link,by="aid")       |> # link articles
    inner_join(CPY.lid, by="lid")       |> # link labels
    select(aid=.data$cpy.aid,lid=.data$cpy.lid,answer) 
  
  1:nrow(import) |> pbapply::pblapply(function(i){
    review(pid = target.pid, aid = import$aid[i], lid = import$lid[i],
                answer = jsonlite::fromJSON(import$answer[i]))
  })
  
}