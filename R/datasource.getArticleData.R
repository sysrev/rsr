datasource.getArticleData <- function(article_ids,datasource,token=.token){
	if(datasource == "RIS"){
		datasource.risFileCitationsByIds(article_ids,token)
	}else if(datasource == "pubmed"){
		datasource.getPubmedArticles(article_ids,token)
	}
}