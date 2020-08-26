datasource.importDataframe <- function(datasource.id,df,external.ids=NULL,filenames=NULL,token=.token){
  external.ids 	<- if(is.null(external.ids)){as.character(1:nrow(df))}else{external.ids}
  filenames		<- if(is.null(filenames)){sapply(1:nrow(df),function(x){sprintf("%d.json",x)})}else{filenames}
  purrr::walk(1:nrow(df),function(i){
  	entity 				<- jsonlite::toJSON(as.list(df[i,]),auto_unbox=T)
  	encoded_entity	 	<- gsub("\n","",jsonlite::base64_enc(entity))
  	datasource.createEntity(datasource.id,external.ids[i],encoded_entity,filenames[i],token)
  })
}
