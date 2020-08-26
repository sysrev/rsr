datasource.importDataframe <- function(datasource.id,df,token=.token){
  apply(1,function(row){
  	entity <- jsonlite::toJSON(row)
  	encoded_entity <- gsub("\n","",jsonlite::base64_enc(entity))
  	query <- sprintf('mutation M{createEntity(dataset: %d external_id: "%s" file: "%s" filename: "%s") {id}}',
  	  dataset,external_id,file,filename)
  	datasource.graphql(query,token)$createEntity$id
  })
}
