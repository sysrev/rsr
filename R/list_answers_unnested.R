#' retrieve clean table data containing Sysrev project answers
#'
#' @param pid A sysrev project id - sysrev.com/p/<pid>
#' @param filter (Optional) aid or short_label from the given project to filter answers on
#' @param filter_type Type of value to filter on - either "aid" or "short_label"
#' @param token A sysrev token with read access to the given project
#'
#' @return A list containing a tibble for each answer
#' @export
#'
#' @examples
#' pid <- 117883
#' p_aid <- 14352862
#' token <- rstudioapi::askForSecret("Sysrev token with project access")
#' 
#' rsr_tables <- list_answers_unnested(pid, p_aid, "aid", token = token)
#' -----
#' pid <- 119108
#' label <- "Clinical_Chemistry"
#' token <- rstudioapi::askForSecret("Sysrev token with project access")
#' 
#' rsr_tables <- list_answers_unnested(pid, label, "short_label", token = token)
list_answers_unnested <- function(pid, filter = NULL, filter_type = c("aid", "short_label"), token){
  tryCatch({
    # retrieve project data answers and labels 
    pid_answers <- rsr::get_answers(pid, token = token)
    pid_labels <- rsr::get_labels(pid, token = token)
  }, error = function(e) stop("Incorrect pid or token. Please make sure the pid and token exist."))
  # if provided, filter data on specific aid
  if(!is.null(filter)){
    if(filter_type == "aid"){
      tryCatch({
        pid_answers <- pid_answers |> 
          filter(aid == aid[which(aid == filter)])
      }, error = function(e) stop("Incorrect project aid. Please make sure the aid exists within the project."))
    }else if(filter_type == "short_label"){
      tryCatch({
        pid_answers <- pid_answers |> 
          filter(short_label == short_label[which(short_label == filter)])
      }, error = function(e) stop("Incorrect short_label. Please make sure the short_label exists within the project."))
    }else{
      stop("Incorrect filter type. Please enter 'aid' or 'short_label' as filter_type.")
    }
  }
  # tidy answers (json to dataframe list)
  pid_answers <- pid_answers |> 
    tidy_answers()
  # convert answers to individual tables
  pid_answer_tables <- lapply(pid_answers$answer, function(x){
    # check if answer is a list
    if(is.list(x)){
      right_join(pid_labels, x) |>
        select(row, short_label, value) |> 
        mutate(value = apply(x["value"], 1, function(x){paste(unname(unlist(x)), collapse = ", ")})) |>
        unique() |>
        pivot_wider(names_from = short_label)
    }
  })
  # change names of tables to match label
  names(pid_answer_tables) <- pid_answers$short_label
  return(pid_answer_tables)
}