% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{srplumber}
\alias{srplumber}
\title{sysrev.plumber
a simple wrapper for rplumber.sysrev.com httr api requests
TODO - remove get_srtoken}
\usage{
srplumber(path, params = list(), token = get_srtoken())
}
\arguments{
\item{path}{the service path see rplumber.sysrev.com/__docs__/#/}

\item{params}{list of http parameters}

\item{token}{a sysrev token with read access to the given project}
}
\value{
A dataframe
}
\description{
sysrev.plumber
a simple wrapper for rplumber.sysrev.com httr api requests
TODO - remove get_srtoken
}
\keyword{internal}
