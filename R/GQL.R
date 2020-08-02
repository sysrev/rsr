GQL <- function(query,token,
                .variables = NULL,
                .operationName = NULL,
                .url = "https://sysrev.com/graphql"){
  pbody <- list(query = query, variables = .variables, operationName = .operationName)
  if(is.null(token)){
    res <- POST(.url, body = pbody, encode="json")
    res <- POST(.url, body = pbody, encode="json", ...)
  } else {
    auth_header <- paste("Bearer", token)
    req <- httr::POST(.url, body = pbody, encode="json", httr::add_headers(Authorization=auth_header))
  }
  res <- httr::content(req, as = "parsed", encoding = "UTF-8")
  if(!is.null(res$errors)){
    warning(jsonlite::toJSON(res$errors))
  }
  res$data
}
