sysrev.getArticles <- function(project,token=.token){
  query   <- sprintf('{project(id:%d){articles{id,enabled,datasource_id,datasource_name,uuid}}}}',project)
  res     <- sysrev.graphql(query,token)$project$articles
  fnil    <- function(v,default=NA){if(is.null(v)){NA}else{v}}
  dframes <- purrr::map(res,function(art){
  	data.frame(
      project.id 		          = as.numeric(project),
  		article.id        		  = as.numeric(art$id),
  		article.enabled   		  = as.logical(art$enabled),
  		article.datasource.id   = as.numeric(fnil(art$datasource_id)),
      article.datasource.name = as.character(fnil(art$datasource_name)))
  	})
    
  do.call(rbind,dframes)
}