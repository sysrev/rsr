#' datasource.getArticleData
#' This will be deprecated.
#' @param article_ids datasource article ids to get
#' @param datasource the datasource to get
#' @param token a token with read priveleges
#' @return gets a dataframe for arbitrary datasources from datasource service
#' @export
datasource.getArticleData <- function(article_ids,datasource,token=keyring::key_get("sysrev.token")){
	if(datasource == "RIS"){
		datasource.risFileCitationsByIds(article_ids,token)
	}else if(datasource == "pubmed"){
		datasource.getPubmedArticles(article_ids,token)
	}
}
