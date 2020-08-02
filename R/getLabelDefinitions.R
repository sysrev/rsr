#' Get user answers from project
#'
#' Get user answers in a long form data frame
#' @param project The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token your personal token. get it with RSysrev::loginAPIToken()
#' @export
#' @examples
#' getLabelDefinitions(project=3144,getAPIToken())
getLabelDefinitions <- function(project,token){
  query <- sprintf('{project(id:%d){id labelDefinitions{id,name,question,ordering,required,type,consensus,enabled}}}',project)
  res   <- GQL(query,token)
  fnil <- function(v,default=NA){if(is.null(v)){NA}else{v}}
  lists <- lapply(res$project$labelDefinitions,function(ld){
        c(
          project.id   = fnil(res$project$id),
          lbl.id       = fnil(ld$id),
          lbl.name	   = fnil(ld$name),
          lbl.question = fnil(ld$question),
          lbl.ordering = fnil(ld$ordering),
          lbl.required = fnil(ld$required),
          lbl.type     = fnil(ld$type),
          lbl.consensus= fnil(ld$consensus),
          lbl.enabled  = fnil(ld$enabled))
      })
    
  df <- as.data.frame(do.call(rbind,lists),stringsAsFactors = F) 
  

  dplyr::mutate(df,
          project.id      = as.numeric(project.id),
          lbl.id          = as.character(lbl.id),
          lbl.name        = as.character(lbl.name),
          lbl.question    = as.character(lbl.question),
          lbl.ordering	  = as.numeric(lbl.ordering),
          lbl.required	  = as.logical(lbl.required),
          lbl.type        = as.character(lbl.type),
          lbl.consensus	  = as.logical(lbl.consensus),
          lbl.enabled     = as.logical(lbl.enabled))
}

