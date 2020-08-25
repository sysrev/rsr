sysrev.getProjectEntities <- function(project,token=.token){
  query <- sprintf("{project(id:%d){articles{id,datasource_id,datasource_name}}}",project)
  projectArticles <- sysrev.graphql(query,token)
}