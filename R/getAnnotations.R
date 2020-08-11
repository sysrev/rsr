#' Get User Annotations From Project
#'
#' This function allows you to get user annotations from sysrev for a specific project.
#' The project must be public.
#' @param project The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @keywords annotations
#' @export
#' @examples
#' getAnnotations(project=3144)
getAnnotations <- function(project,token){
  req  <- httr::GET(sprintf("https://sysrev.com/web-api/project-annotations?project-id=%d",project),
                    httr::add_headers(Authorization=paste("Bearer",token)))
  res  <- httr::content(req)$result
  list <- lapply(res,function(sl){
    basic <- c(sl[1:5])
    pmid  <- ifelse(is.null(sl$pmid),NA, sl$pmid)
    text  <- sl$context$`text-context`
    start <- sl$context$`start-offset`
    end   <- sl$context$`end-offset`
    unlist(c(sl$selection,sl$annotation,sl$`semantic-class`,pmid,sl$`article-id`,text,start,end))
  })

  df <- do.call(rbind.data.frame,c(list,stringsAsFactors=FALSE))
  colnames(df) <- c("selection","annotation","semantic_class","external_id","sysrev_id","text","start","end")
  df
}
