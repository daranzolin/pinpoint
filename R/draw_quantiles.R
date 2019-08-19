#' Draw quantile lines
#'
#' @param pinpoint a pinpoint visualization
#' @param probs numeric vector of probabilities with values between 0 and 1
#' @param color color of quantile lines
#'
#' @export
#'
#' @examples
draw_quantiles <- function(pinpoint, probs = c(0.25, 0.75), color = "grey") {
  qs <- quantile(pinpoint$x$data$x, probs = probs)
  pinpoint$x$quantiles <- unname(qs)
  pinpoint$x$quantile_line_color <- color
  return(pinpoint)
}
