#' Get user group label answers from project. returns a list with named dataframes corresponding to group label answers
#'
#' Get user answers in a long form data frame
#' @import dplyr
#' @param project_id The project identifier.  For sysrev.com/p/3144 the identifier is 3144
#' @param token a sysrev token with read access to the given project
#' @export
sysrev.getGroupLabelAnswers <- function(project_id,token=get_srkey()){
  query <- sprintf('{project(id:%s){articles{id, enabled, groupLabels{name,reviewer{id,name},answer{name, answer}}}}}',project_id)
  data = sysrev.graphql(query,token)

  parse_data_frame_from_grouplabel <- function(gl){
    df <- data.frame()
    for(i in seq_along(gl$answer)){
      for(answer in gl$answer[[i]]){ df[i,answer$name] <- paste(answer$answer,collapse=";") }
    }
    return(df)
  }

  parse_grouplabels_from_article <- function(article){
    grouplabelDFs <- list()
    for(gl in article$groupLabels){
      old_gl_df = if(is.null(grouplabelDFs[[gl$name]])){data.frame()}else{grouplabelDFs[[gl$name]]}
      new_gl_df <- parse_data_frame_from_grouplabel(gl) %>%
        mutate(Article.ID=article$id, User.ID=gl$reviewer$id, User.Name = gl$reviewer$name)
      grouplabelDFs[[gl$name]] = dplyr::bind_rows(old_gl_df, new_gl_df)
    }
    return(grouplabelDFs)
  }

  gldfs <- list()
  for(article in data$project$articles){
    art_gldfs <- parse_grouplabels_from_article(article)
    for(gl in names(art_gldfs)){
      oldgldf     = if(is.null(gldfs[[gl]])) data.frame() else gldfs[[gl]]
      gldfs[[gl]] = dplyr::bind_rows(oldgldf, art_gldfs[[gl]])
    }
  }
  return(gldfs)
}

