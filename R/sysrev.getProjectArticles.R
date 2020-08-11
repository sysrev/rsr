sysrev.getProjectArticles <- function(project,token){
  query   <- sprintf('{project(id:%d){articles{id,content,enabled,datasource_id,uuid}}}}',project)
  res     <- GQL(query,token)$project$articles
  fnil    <- function(v,default=NA){if(is.null(v)){NA}else{v}}
  dframes <- purrr::map(res,function(art){
  	data.frame(
      project.id 		          = as.numeric(project),
  		article.id        		  = as.numeric(art$id),
  		article.enabled   		  = as.logical(art$enabled),
  		article.content         = as.character(fnil(art$content)),
  		article.datasource.id   = as.numeric(fnil(art$datasource_id)))
  	})
    
  do.call(rbind,dframes)
}