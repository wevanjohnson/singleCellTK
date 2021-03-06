% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotDimRed.R
\name{plotDimRed}
\alias{plotDimRed}
\title{Plot results either on already run results of reduced dimensions data.}
\usage{
plotDimRed(inSCE, colorBy = "No Color", shape = "No Shape",
  reducedDimName = NULL, useAssay = "logcounts", comp1 = NULL,
  comp2 = NULL)
}
\arguments{
\item{inSCE}{Input SCtkExperiment object with saved dimension reduction components
or a variable with saved results. Required}

\item{colorBy}{color by a condition(any column of the annotation data).}

\item{shape}{add shapes to each condition.}

\item{reducedDimName}{saved dimension reduction name in the SCtkExperiment object. Required.}

\item{useAssay}{Indicate which assay to use. The default is "logcounts"}

\item{comp1}{label for x-axis}

\item{comp2}{label for y-axis}
}
\value{
a ggplot of the reduced dimensions.
}
\description{
Plot results either on already run results of reduced dimensions data.
}
\examples{
plotDimRed(inSCE = mouseBrainSubsetSCE, colorBy = "No Color", shape = "No Shape",
           reducedDimName = "TSNE_counts", useAssay = "counts",
           comp1 = "tSNE1", comp2 = "tSNE2")

}
