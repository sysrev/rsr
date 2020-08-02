getAPIToken <- function(email,password){
  res  <- httr::GET(sprintf("https://sysrev.com/web-api/get-api-token?email=%s&password=%s",email,password))
  json <- jsonlite::parse_json(res)
  
  if(!is.null(json$error$message) && json$error$message == "User authentication failed"){
    stop("User authentication failed")
  }else if(is.null(json$result$`api-token`)){
    stop(sprintf("No API Token for %s do you have a pro or team pro account?",email))
  }else{
    json$result$`api-token`
  }
}