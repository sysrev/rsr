#' sroptions
#' @details concordance_options are used to compare two objects of the same type
#' @param consensus.labels which labels are required to have consensus?
#' @param na.rm should empty answers be discarded?
#' @return a project_concordant_options list
#' @keywords internal
sroptions = function(consensus.labels=list(),na.rm=T){
  list(consensus.labels=consensus.labels,na.rm=na.rm)
}

#' @rdname get_sysrev
#' @export
get_sroptions = function(pid=NA,token=get_srtoken()){
  lbl           = rsr::get_labels(pid,token = token)
  consensus.lbl = lbl |> filter(.data$consensus)

  group.consensus = if("root_label_id_local" %in% colnames(lbl)){
    lbl |> filter(.data$label_id_local %in% consensus.lbl$root_label_id_local)
  } # A group label with a consensus child is a consensus label

  sroptions(consensus.labels = unique(c(consensus.lbl$lid,
                                        group.consensus$lid)))
}

#' concordant
#' @description Is an answer vector concordant?
#' @details concordant refers to whether two sysrev answers are equivalent
#' @param a answer vector
#' @param single.concordance should length 1 value be considered concordant?
#' @param pco concordance settings from `get_sroptions(pid)`
#' @return True or False
#' @keywords internal sysrev answer comparison
#' @export
concordant = function(a,single.concordance=T,pco){

  # if na.rm remove NA answers
  a = if(pco$na.rm){a[which(!is.na(a))]}else{a}

  # short-circuit single entity arrays
  if(!single.concordance && length(a) == 1){ return(F) }

  # check that every item is concordant with the first
  purrr::every(a[-1], ~ concordant2(a[[1]],.,pco))
}

#' check for binary answer concordance
#' @details
#' concordant refers to whether two sysrev answers are equivalent
#' TODO add a json equality to cover all undefined sysrev types
#' @param a first object to compare
#' @param b second object to compare
#' @param options additional arguments for specific answer subclasses
#' @return T when a and b are 'concordant'
#' @keywords internal sysrev answer comparison
concordant2 = function(a,b,options){
  UseMethod("concordant2")
}

#' @keywords internal
concordant2.rsr_group = function(a,b,pco){
  clab = pco$consensus.labels
  
  if(nrow(a) != nrow(b)){ return(F) }
  if(nrow(a) == 0){ return(T) }
  
  a1 |> inner_join(b1,by=c("lid","value")) |> filter(lid %in% clab) |> with({
    all(row.x == a1$row)
  })
}

#' @keywords internal
concordant2.default = function(a,b,options){
  setequal(a,b)
}
