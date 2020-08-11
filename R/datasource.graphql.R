datasource.graphql <- function(query,token,.url = "https://datasource.insilica.co/graphql"){
  req <- httr::POST(.url, 
  	body = list(query = query), encode="json", 
  	httr::add_headers(Authorization=paste("Bearer", token)))

  httr::content(req,as = "parsed", encoding = "UTF-8")$data
}
