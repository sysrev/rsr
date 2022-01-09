#' get_key
#' @return the users sysrev token
get_srtoken = function(){
  res = tryCatch({
    list(token = keyring::key_get("sysrev","tokens"),success=T)
  },error=function(e){
    list(success=F,error = glue::glue_col(
    'no default token found. use:
    1. {cyan `> keyring::key_set("sysrev","token")`}  # to cache a token
    2. {cyan `> rsr::get_*(3144,token="some-token")`} # to manually set a token for a function'))
  })
  if(res$success){ stop(res$token) }else{ stop(res$error) }
}

#' test_token
#' @param token sysrev private token. This is an access token for sysrev.com. You can find your personal token on your sysrev user page.
#' @return the users sysrev token
#' @keywords internal
test_token = function(token){
  stop("not yet implemented")
}
