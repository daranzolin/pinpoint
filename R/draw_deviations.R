#' Draw standard deviation lines from the mean
#'
#' @param pinpoint a pinpoint visualization
#' @param deviations either 1, 2, or 3
#' @param color color of deviation lines
#' @param stroke_width width of drawn strokes
#'
#' @importFrom stats sd
#'
#' @export
#'
#' @examples
draw_deviations <- function(pinpoint, deviations = 1, color = "red", stroke_width = 1) {
  stopifnot(deviations %in% 1:3)
  d <- sd(pinpoint$x$data$x)
  m <- mean(pinpoint$x$data$x)
  v <- d * deviations
  pinpoint$x$deviations <- c(m - v, m + v)
  pinpoint$x$deviations_stroke_color <- color
  pinpoint$x$deviations_stroke_width <- stroke_width
  return(pinpoint)
}
