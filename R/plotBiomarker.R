#' Given a set of genes, return a ggplot of expression
#' values.
#'
#' @param inSCE Input SCtkExperiment object. Required
#' @param gene genelist to run the method on.
#' @param binary binary/continuous color for the expression.
#' @param shape shape parameter for the ggplot.
#' @param useAssay Indicate which assay to use. The default is "logcounts".
#' @param reducedDimName the name which has stored the results of the dimension reduction
#' coordinates obtained from this method. This is stored in the SingleCellExperiment
#' object in the reducedDims slot. Required.
#' @param comp1 label for x-axis
#' @param comp2 label for y-axis
#'
#' @return A Biomarker plot
#' @export
#' @examples
#' data("mouseBrainSubsetSCE")
#' plotBiomarker(mouseBrainSubsetSCE, gene="C1qa", shape="level1class", reducedDimName="TSNE_counts")
#'
plotBiomarker <- function(inSCE, gene, binary="Binary",
                          shape="No Shape",
                          useAssay="counts", reducedDimName="PCA",
                          comp1 = NULL, comp2 = NULL){
  if (shape == "No Shape"){
    shape <- NULL
  }
  variances <- NULL
  if (class(inSCE) == "SCtkExperiment"){
    variances <- pcaVariances(inSCE)
  }
  if (is.null(SingleCellExperiment::reducedDim(inSCE, reducedDimName))) {
    stop("Please supply a correct reducedDimName")
  } else {
    axisDf <- data.frame(SingleCellExperiment::reducedDim(inSCE,
                                                          reducedDimName))
  }
  if (!is.null(comp1) & !is.null(comp2)) {
    x <- comp1
    y <- comp2
    colnames(axisDf) <- c(x, y)
  } else {
    x <- colnames(axisDf)[1]
    y <- colnames(axisDf)[2]
  }
  if (length(gene) > 9) {
    gene <- gene[seq_len(9)]
  }
  for (i in seq_along(gene)){
    bioDf <- getBiomarker(inSCE = inSCE, gene = gene[i], binary = binary,
                          useAssay = useAssay)
    l <- axisDf
    if (!is.null(shape)){
      l$shape <- factor(SingleCellExperiment::colData(inSCE)[, shape])
    }
    geneName <- colnames(bioDf)[2]
    colnames(bioDf)[2] <- "expression"
    l$Sample <- as.character(bioDf$sample)
    l$expression <- bioDf$expression
    c <- SummarizedExperiment::assay(inSCE, useAssay)[c(geneName), ]
    percent <- round(100 * sum(c > 0) / length(c), 2)
    if (binary == "Binary"){
        l$expression <- ifelse(l$expression, "Yes", "No")
        g <- ggplot2::ggplot(l, ggplot2::aes_string(x, y, label = "Sample",
                                                    color = "expression")) +
          ggplot2::geom_point() +
          ggplot2::scale_color_manual(limits = c("Yes", "No"),
                                      values = c("Black", "Grey")) +
          ggplot2::labs(color = "Expression")
      }
      else if (binary == "Continuous"){
        if (min(round(l$expression, 6)) == max(round(l$expression, 6))){
          g <- ggplot2::ggplot(l, ggplot2::aes_string(x, y, label = "Sample")) +
            ggplot2::geom_point(color = "grey")
        } else{
          g <- ggplot2::ggplot(l, ggplot2::aes_string(x, y, label = "Sample",
                                                      color = "expression")) +
            ggplot2::scale_colour_gradient(limits = c(min(l$expression),
                                                      max(l$expression)),
                                           low = "grey", high = "black") +
            ggplot2::geom_point()
        }
        g <- g + ggplot2::labs(color = "Expression")
      }
      g <- g +
        ggplot2::ggtitle(paste(geneName, " - ", percent, "%", " cells",
                               sep = "")) +
        ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
      if (is.null(variances)){
        g <- g + ggplot2::labs(x = x, y = y)
      } else {
        if (any(grepl("PC", colnames(l)))){
          g <- g + ggplot2::labs(
            x = paste0(x, " ", toString(round(variances[x, ] * 100, 2)), "%"),
            y = paste0(y, " ", toString(round(variances[y, ] * 100, 2)), "%"))
        }
      }
    if (!is.null(shape)){
      g <- g + ggplot2::aes_string(shape = "shape") +
        ggplot2::labs(shape = shape)
    }
    if (i == 1) {
      plist <- list(g)
    } else{
      plist <- cbind(plist, list(g))
    }
  }
  return(grid::grid.draw(gridExtra::arrangeGrob(
    grobs = plist, ncol = ceiling(sqrt(length(gene))))))
}
