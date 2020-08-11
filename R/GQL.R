GQL <- function(query,token,
                .variables = NULL,
                .operationName = NULL,
                .url = "https://sysrev.com/graphql"){
  pbody <- list(query = query, variables = .variables, operationName = .operationName)
  req <- 
    if(is.null(token)){
      httr::POST(.url, body = list(query = query), encode="json")
    } else {
      httr::POST(.url, body = list(query = query), encode="json", 
        httr::add_headers(Authorization=paste("Bearer", token)))
    }
  res <- httr::content(req, as = "parsed", encoding = "UTF-8")
  if(!is.null(res$errors)){
    messages <- lapply(res$errors,function(e){e$message})
    stop(paste(messages,collapse = " AND "))
  }else{
    res$data
  }
}