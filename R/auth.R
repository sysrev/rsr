#' get_key
#' @return the users sysrev token
get_key = function(){
  tryCatch({
    keyring::key_get("sysrev","token")
  },error=function(e){
    stop(glue::glue_col("\nno cached key found.
                    set a default sysrev token with {red `keyring::key_set(\"sysrev\",\"token\")`}
                    Get your token on sysrev.com user page.
                    You must have a premium account to use rsysrev"))
  })
}


#' test_token
#' @param token sysrev private token. This is an access token for sysrev.com. You can find your personal token on your sysrev user page.
#' @return the users sysrev token
test_token = function(token){
  stop("not yet implemented")
}
