% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers_ggbetweenstats.R
\name{pairwise_p}
\alias{pairwise_p}
\title{Pairwise comparison tests}
\usage{
pairwise_p(data, x, y, type = "parametric", tr = 0.1, paired = FALSE,
  p.adjust.method = "holm", ...)
}
\arguments{
\item{data}{Dataframe from which variables specified are preferentially to be
taken.}

\item{x}{The grouping variable.}

\item{y}{The response - a vector of length the number of rows of \code{x}.}

\item{type}{Type of statistic expected (\code{"parametric"} or \code{"nonparametric"}
or \code{"robust"} or \code{"bayes"}).Corresponding abbreviations are also accepted:
\code{"p"} (for parametric), \code{"np"} (nonparametric), \code{"r"} (robust), or
\code{"bf"}resp.}

\item{tr}{Trim level for the mean when carrying out \code{robust} tests. If you
get error stating "Standard error cannot be computed because of Winsorized
variance of 0 (e.g., due to ties). Try to decrease the trimming level.",
try to play around with the value of \code{tr}, which is by default set to
\code{0.1}. Lowering the value might help.}

\item{paired}{a logical indicating whether you want a paired
    t-test.}

\item{...}{further arguments to be passed to or from methods.}
}
\description{
Calculate pairwise comparisons between group levels with
corrections for multiple testing.
}
\seealso{
\code{\link{ggbetweenstats}}
}
\author{
Indrajeet Patil
}
\keyword{internal}