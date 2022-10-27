srcollapse = function(answer){
  # input tests
  if(length(answer)==0){return(answer)}
  classes = map(answer,class)
  i       = purrr::detect_index(classes,.f = ~ any(. != classes[[1]]))
  if(i != 0){ rlang::abort(c("elements must be same class",x=glue("row {i} is wrong class"))) }
  
  # dispatch
  if(is.atomic(answer[[1]])){ return( list(unique(unlist(answer))) ) }
  if(classes[[1]][1] == "rsr_group"){ return( srcollapse.rsr_group(answer) ) }
  
  rlang::abort(c(
    "unsupported srcollapse class",
    x=glue("class {paste(classes[[1]],collapse=', ')} is not supported")))
}

srcollapse.rsr_group = function(answer){
  
  a1  = answer |> purrr::imap_dfr( ~ .x |> mutate(i=.y))
  
  # TODO collapse group labels should consider pco$consensus.labels 
  # But it seems like this can have perhaps surprising results for end user
  # For now we collapse a discordant group label by getting all the unique rows
  
  a1 |> 
    tidyr::nest(data = c(lid,value)) |> 
    select(.data$data) |> distinct() |> 
    mutate(row=row_number()) |> 
    unnest(.data$data) |> 
    select(row,lid,value) |> list()
  
}