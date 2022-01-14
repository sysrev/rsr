sysrev.graphql <- function(query,token,.url = "https://sysrev.com/graphql"){

  req <- {
    if(is.null(token)){ httr::POST(.url, body = list(query = query), encode="json") }
    else{ httr::POST(.url, body = list(query = query), encode="json",httr::add_headers(Authorization=paste("Bearer", token))) }
  }

  res <- httr::content(req, as = "parsed", encoding = "UTF-8")

  if (!is.list(res)){
    stop("Error response from sysrev graphql, please report to tom@sysrev.com.")
  }else if (is.null(res$data)) {
    stop(jsonlite::prettify(jsonlite::toJSON(res, auto_unbox = T)))
  }

  res$data
}
