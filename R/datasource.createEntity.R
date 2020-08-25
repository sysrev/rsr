datasource.createEntity <- function(dataset,external_id,file,filename,token=.token){
  query <- sprintf('mutation M{createEntity(dataset: %d external_id: "%s" file: "%s" filename: "%s") {id}}',
  	dataset,external_id,file,filename)
  datasource.graphql(query,token)$createEntity$id
}
