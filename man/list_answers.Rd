% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_answer.R
\name{list_answers}
\alias{list_answers}
\title{transform answer table to list of answer tables}
\usage{
list_answers(
  answers,
  concordance = F,
  collapse = F,
  enabled_only = T,
  token = get_srtoken()
)
}
\arguments{
\item{answers}{answers from a `get_answers` call}

\item{concordance}{whether to compute concordance}

\item{collapse}{whether to remove user_ids and collapse answers}

\item{enabled_only}{only get answers from enabled articles?}

\item{token}{a sysrev token with read access to the given project}
}
\value{
list of tibbles
}
\description{
a special `basic` value in the list is populated by categorical boolean and string labels
every other value in the list represents a sysrev group label <rsr_group>
}
