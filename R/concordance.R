#' sroptions
#' @details concordance_options are used to compare two objects of the same type
#' @param consensus.labels which labels are required to have consensus?
#' @param na.rm should empty answers be discarded?
#' @return a project_concordant_options list
#' @keywords internal
sroptions = function(consensus.labels=list(),na.rm=T){
  list(consensus.labels=consensus.labels,na.rm=na.rm)
}

#' get_sroptions
#' @importFrom rlang .data
#' @details concordance_options are used to compare two objects of the same type
#' @param pid sysrev project_id, allows concordance_options to be looked up from sysrev.com
#' @return a project_concordant_options list
#' @export
get_sroptions = function(pid=NA){
  lbl                   = rsr::get_labels(43140)
  lbl.loid              = lbl |> select(.data$lid,loid = .data$label_id_local)
  any.consensus.labels  = lbl |> filter(.data$consensus) |> select(.data$lid,ploid = .data$root_label_id_local)
  root.consensus.labels = lbl.loid |> filter(.data$loid %in% any.consensus.labels$ploid)
  consensus.labels      = c(root.consensus.labels$lid, any.consensus.labels$lid) |> unique()
  sroptions(consensus.labels = consensus.labels)
}

#' concordant
#' @details concordant refers to whether two sysrev answers are equivalent
#' @param a input vector
#' @param single.concordance should length 1 value be considered concordant?
#' @param pco concordance settings from `get_sroptions(pid)`
#' @return `concordant()` returns T when all answers are concordant
#' @keywords sysrev answer comparison
#' @export
concordant = function(a,single.concordance=T,pco){

  # if na.rm remove NA answers
  a = if(pco$na.rm){a[which(!is.na(a))]}else{a}

  # short-circuit single entity arrays
  if(!single.concordance && length(a) == 1){ return(F) }

  # check that every item is concordant with the first
  purrr::every(a[-1], ~ concordant2(a[[1]],.,pco))
}

#' concordant2
#' TODO add a json equality to cover all undefined sysrev types
#' @details concordant refers to whether two sysrev answers are equivalent
#' @param a first object to compare
#' @param b second object to compare
#' @param options additional arguments for specific answer subclasses
#' @return `concordant()` returns T when a and b are 'concordant'
#' @keywords sysrev answer comparison
#' @export
concordant2 = function(a,b,options){
  UseMethod("concordant2")
}

#' @importFrom dplyr filter
#' @importFrom rlang .data
#' @export
concordant2.rsr_group = function(a,b,options){
  a1 = a |> filter(.data$lid %in% options$consensus.labels)
  b1 = b |> filter(.data$lid %in% options$consensus.labels)
  all_equal(a1,b1) == TRUE
}

#' @export
concordant2.default = function(a,b,options){
  setequal(a,b)
}
