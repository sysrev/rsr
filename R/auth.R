#' get_key
#'
#' @return
#' @examples
get_key = function(){
  keyring::key_get("sysrev","token")
}
