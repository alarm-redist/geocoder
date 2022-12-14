% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep.R
\name{gc_prep_street_db}
\alias{gc_prep_street_db}
\title{Prepare Streets Database}
\usage{
gc_prep_street_db(county = NULL, state = NULL, zip = NULL)
}
\arguments{
\item{county}{The county or counties to download address ranges for. Can be
specified as a FIPS code or county name that will be partially matched to a
list of all counties.}

\item{state}{The state that the county belongs to. Partially matched to a
list of all states.}

\item{zip}{The ZIP code(s) to download address ranges for. Will be converted
to a list of counties that cover all the provided ZIP codes.}
}
\value{
The path to the database, invisibly.
}
\description{
Download and format address ranges from the Census TIGER/Line API, and then
store in Arrow/GeoParquet format. One of \code{county} or \code{zip} must be provided.
}
\examples{
gc_prep_street_db(county = "Dare", state = "NC")

}
