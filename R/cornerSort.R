#' Candidate combinations as corners
#'
#' Given a set of data points, return possible combinations of data points as
#' corners. These combinations are selected by ranking the sum of
#' margin-of-errors.
#' @param X    Data in a matrix. Each column is a data point.
#' @param K    The number of corner points.
#' @param nComb    The number of returned combinations of data points as
#'     corners. All combinations will be returned if the number of all
#'     combinations is less than nComb.
#' @details This function is to detect \eqn{K} corner points from \eqn{M} data
#' points by conducting an exhaustive combinatorial search (with total
#' \eqn{C_M^K} combinations), based on a convex-hull-to-data fitting criterion:
#' sum of margin-of-errors. \code{nComb} combinations are returned for further
#' selection based on reconstruction errors of all data points in original
#' space.
#'
#' The function is implemented in Java with R-to-Java interface provided by
#' \code{rJava} package. It relies on NonNegativeLeastSquares class in Parallel
#' Java Library (https://www.cs.rit.edu/~ark/pj.shtml).
#' @return A list containing the following components:
#' \item{idx}{A matrix to show the indexes of data points in combinations to
#' construct a convex hull. Each column is one combination.}
#' \item{error}{A vector of margin-of-error sums for each combination.}
#' @export
#' @examples
#' data <- matrix(c(0.1,0.2,1.0,0.0,0.0,0.5,0.3,
#'                  0.1,0.7,0.0,1.0,0.0,0.5,0.3,
#'                  0.8,0.1,0.0,0.0,1.0,0.0,0.4), nrow =3, byrow = TRUE)
#' topconv <- cornerSort(data, 3, 10)
cornerSort <- function(X, K, nComb){
    corner.detect <- .jnew("CornerDetectTopN", .jarray(X, dispatch=TRUE),
                            as.integer(K), as.integer(nComb))
    .jcall(corner.detect, "Z", "search")
    idx <- .jcall(corner.detect, "[[I", "getTopNConv")
    idx <- vapply(idx, .jevalArray, integer(K))
    error <- .jcall(corner.detect, "[D", "getTopNConvErr")
    return(list(idx=idx,error=error))
}
