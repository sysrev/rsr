datasource.importDataframe <- function(datasource.id,df,external.ids=NULL,filenames=NULL,token=.token){
  external.ids 		<- ifelse(is.null(external.ids),as.character(1:nrow(df)),external.ids)
  filenames			<- ifelse(is.null(filenames),sapply(1:nrow(df),function(x){sprintf("%d.json",x)}),filenames)
  entities 			<- apply(df,1,jsonlite::toJSON)
  encoded_entities 	<- lapply(entities,function(entity){gsub("\n","",jsonlite::base64_enc(entity))})
  purrr::walk(1:nrow(df),function(i){
  	datasource.createEntity(datasource.id,external.ids[i],encoded_entities[i],filenames[i],token)
  })
}
