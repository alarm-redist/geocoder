% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/addresses.R
\name{gc_address}
\alias{gc_address}
\title{Parse Addresses}
\usage{
gc_address(data, ...)
}
\arguments{
\item{data}{A data frame}

\item{...}{TBD}
}
\value{
A data frame containing columns with the parsed address. These match
the Census format for street addresses.
}
\description{
Parse Addresses
}
\examples{
data(nc_addr)
gc_address(nc_addr)

}