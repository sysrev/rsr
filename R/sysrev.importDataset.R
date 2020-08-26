sysrev.importDataset <- function(datasource.id,sysrev.id,token=.token){
  query <- sprintf('mutation M{importDataset(dataset: %d id: %d)}',
  	datasource.id,sysrev.id)
  sysrev.graphql(query,token)
}