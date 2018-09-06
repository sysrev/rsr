#' Get User Annotations From Project
#'
#' This function allows you to get user annotations from sysrev for a specific project.
#' The project must be public.
#' @param project The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @keywords annotations
#' @export
#' @examples
#' getAnnotations(project=3144)
getAnnotations <- function(project){
  res  <- httr::GET(sprintf("https://sysrev.com/web-api/project-annotations?project-id=%d",project))
  lapply(httr::content(res)$result,function(sublist){
    basic <- c(sublist[1:5])
    text  <- sublist[[6]]$`text-context`
    start <- sublist[[6]]$`start-offset`
    end   <- sublist[[6]]$`end-offset`
    unlist(c(basic,text,start,end))
  }) %>% (function(l){
    df <- do.call(rbind.data.frame,c(l,stringsAsFactors=FALSE))
    colnames(df) <- c("selection","annotation","semantic_class","external_id","sysrev_id","text","start","end")
    df
  }) %>% mutate(datasource = "pubmed")
}
