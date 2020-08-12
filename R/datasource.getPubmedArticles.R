datasource.getPubmedArticles <- function(datasource.ids,token=.token){
  dsrcQ    <- sprintf("{pubmedEntities(pmids:[%s]){
  	id,abstract,authors,date,keywords,locations,primary_title,secondary_title,updated,year,url}}",
  	paste(datasource.ids,collapse=","))
  entities <- datasource.graphql(dsrcQ,token)$pubmedEntities
  dframes  <- purrr::map(entities,function(entity){
    as.data.frame(purrr::map(entity,function(l){
      if(length(l) == 0){as.character(NA)}else{paste(l,collapse=";")}
    }))
  }) 

  df <- do.call(rbind,dframes)
  df <- mutate_all(df,as.character)
  df <- mutate(df,datasource.id = as.numeric(id))
  select(df, datasource.id,abstract,authors,date,keywords,
         primary_title,secondary_title,updated,year,url)
}