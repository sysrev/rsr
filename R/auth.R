#' get_key
#' @return the users sysrev token
get_srtoken = function(){
  res = tryCatch({
    st    = Sys.getenv("SYSREV_TOKEN")
    token = if(nchar(st) > 0){ st }else{ keyring::key_get("sysrev","token") }
    list(token=token,success=T)
  },error=function(e){
    list(success=F,error = glue::glue_col('no default token found. either
    1. provide a `token` arg eg {cyan `rsr::get_labels(3144,token="...")`}
    2. set a default token with {cyan `Sys.setenv(SYSREV_TOKEN="...")`}
    3. set a default token with {cyan `keyring::key_set("sysrev","token")`}'))
  })
  if(res$success){ res$token }else{ stop(res$error) }
}

#' test_token
#' @param token sysrev private token. This is an access token for sysrev.com. You can find your personal token on your sysrev user page.
#' @return the users sysrev token
#' @keywords internal
test_token = function(token){
  stop("not yet implemented")
}
