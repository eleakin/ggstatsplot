% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers_pairwise_comparison.R
\name{pairwise_p}
\alias{pairwise_p}
\title{Pairwise comparison tests}
\usage{
pairwise_p(data, x, y, type = "parametric", tr = 0.1, paired = FALSE,
  var.equal = FALSE, p.adjust.method = "holm", k = 2,
  messages = TRUE, ...)
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

\item{var.equal}{a logical variable indicating whether to treat the
    variances in the samples as equal.  If \code{TRUE}, then a simple F
    test for the equality of means in a one-way analysis of variance is
    performed.  If \code{FALSE}, an approximate method of Welch (1951)
    is used, which generalizes the commonly known 2-sample Welch test to
    the case of arbitrarily many samples.}

\item{p.adjust.method}{Adjustment method for \emph{p}-values for multiple
comparisons. Possible methods are: \code{"holm"} (default), \code{"hochberg"},
\code{"hommel"}, \code{"bonferroni"}, \code{"BH"}, \code{"BY"}, \code{"fdr"}, \code{"none"}.}

\item{k}{Number of digits after decimal point (should be an integer)
(Default: \code{k = 2}).}

\item{messages}{Decides whether messages references, notes, and warnings are
to be displayed (Default: \code{TRUE}).}

\item{...}{further arguments to be passed to or from methods.}
}
\description{
Calculate pairwise comparisons between group levels with
corrections for multiple testing.
}
\examples{
# time consuming, so not run on `CRAN` machines
\dontrun{
# for reproducibility
set.seed(123)

#------------------- between-subjects design ----------------------------

# parametric
# if `var.equal = TRUE`, then Student's *t*-test will be run
ggstatsplot::pairwise_p(
  data = ggplot2::msleep,
  x = vore,
  y = brainwt,
  type = "p",
  var.equal = TRUE,
  paired = FALSE,
  p.adjust.method = "bonferroni"
)

# if `var.equal = FALSE`, then Games-Howell test will be run
ggstatsplot::pairwise_p(
  data = ggplot2::msleep,
  x = vore,
  y = brainwt,
  type = "p",
  var.equal = FALSE,
  paired = FALSE,
  p.adjust.method = "bonferroni"
)

# non-parametric
ggstatsplot::pairwise_p(
  data = ggplot2::msleep,
  x = vore,
  y = brainwt,
  type = "np",
  paired = FALSE,
  p.adjust.method = "none"
)

# robust
ggstatsplot::pairwise_p(
  data = ggplot2::msleep,
  x = vore,
  y = brainwt,
  type = "r",
  paired = FALSE,
  p.adjust.method = "fdr"
)

#------------------- within-subjects design ----------------------------

# parametric
ggstatsplot::pairwise_p(
  data = ggstatsplot::intent_morality,
  x = condition,
  y = rating,
  type = "p",
  paired = FALSE,
  p.adjust.method = "BH"
)

# non-parametric
ggstatsplot::pairwise_p(
  data = ggstatsplot::intent_morality,
  x = condition,
  y = rating,
  type = "np",
  paired = FALSE,
  p.adjust.method = "BY"
)

# robust
ggstatsplot::pairwise_p(
  data = ggstatsplot::intent_morality,
  x = condition,
  y = rating,
  type = "r",
  paired = FALSE,
  p.adjust.method = "hommel"
)
}
}
\seealso{
\code{\link{ggbetweenstats}}, \code{\link{grouped_ggbetweenstats}}

Other helper_messages: \code{\link{bartlett_message}},
  \code{\link{grouped_message}},
  \code{\link{normality_message}},
  \code{\link{palette_message}}
}
\author{
Indrajeet Patil
}
\concept{helper_messages}
