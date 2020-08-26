datasource.createDataset <- function(name,description,url=NULL,token=.token){
  query    <- ifelse(is.null(url),
  	sprintf('mutation M{createDataset(description: "%s" name: "%s") {id}}',description,name),
  	sprintf('mutation M{createDataset(description: "%s" name: "%s" url: "%s") {id}}',description,name,url))
  datasource.graphql(query,token)$createDataset$id
}