#' update_entity
#' updates the primary title or abstract of an entity
#' @import keyring
#' @import httr
#' @import jsonlite
#' @import glue
#' @param article_id the sysrev article_id to modify
#' @param key the key to modify (either 'primary-title' or 'abstract')
#' @param value what string value to update the key
#' @param token a sysrev token with read access to the given project
#' @return a success message
#' @export
update_entity = function(article_id,key,value,token=get_srkey("sysrev.token")){
  req   <- POST(url    = modify_url(getOption("rsysrev.sysrev.plumber.url"),path="/update_article"),
                body   = list(aid=article_id,key=key,value=value),
                encode = "json")
  res   <- content(req, as="text", encoding = "UTF-8")
  json  <- fromJSON(res)
  if(!is.null(json$errors)){ stop(paste(lapply(json$errors,function(e){e$message}),collapse = "\n")) }
  json
}
