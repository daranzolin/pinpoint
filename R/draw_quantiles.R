#' Draw quantile lines
#'
#' @param pinpoint a pinpoint visualization
#' @param probs numeric vector of probabilities with values between 0 and 1
#' @param color color of quantile lines
#' @param stroke_width width of drawn strokes
#'
#' @importFrom stats quantile
#' @export
#'
#' @examples
draw_quantiles <- function(pinpoint, probs = c(0.25, 0.75), color = "grey", stroke_width = 1) {
  qs <- quantile(pinpoint$x$data$x, probs = probs)
  pinpoint$x$quantiles <- unname(qs)
  pinpoint$x$quantiles_stroke_color <- color
  pinpoint$x$quantiles_stroke_width <- stroke_width
  return(pinpoint)
}
