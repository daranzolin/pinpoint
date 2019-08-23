#' Create a pinpoint visualization
#'
#' @param data A table of data
#' @param x A numeric variable.
#' @param fill Point color. Either an unquoted column name or valid string/hex color
#' @param tooltip Variable to display within tooltip
#' @param compare_to the x-intercept to compare against values. Either a numeric value or "diff_from_mean", "diff_from_median", or "z-score"
#' @param title Visualization title
#'
#' @import htmlwidgets
#' @importFrom rlang enquo quo_name get_expr
#' @importFrom stats median
#'
#' @export
pinpoint <- function(data,
                          x,
                          fill = NULL,
                          tooltip = NULL,
                          compare_to = "diff_from_mean",
                          title = ""
                          ) {

  x <- enquo(x)
  fill <- enquo(fill)
  tooltip <- enquo(tooltip)
  compare_to <- enquo(compare_to)

  data_df <- as.data.frame(data)
  out_df <- data.frame(x = rep(NA, nrow(data_df)), stringsAsFactors = FALSE)
  out_df$x <- data_df[,quo_name(x)]
  if (!is.numeric(out_df$x)) stop("x must be numeric", call. = FALSE)
  out_df$tooltip <- data_df[,quo_name(tooltip)]

  if (inherits(get_expr(fill), "name")) {
    out_df$fill <- data_df[,quo_name(fill)]
    unique_cats <- sort(unique(out_df$fill))
    fill_color <- NULL
  } else {
    unique_cats <- NULL
    fill_color <- ifelse(is.null(get_expr(fill)), "steelblue", get_expr(fill))
  }
  cm_expr <- get_expr(compare_to)
  if (class(cm_expr) == "name") {
    out_df$compare_to <- data_df[,quo_name(compare_to)]
  } else if (class(cm_expr) == "numeric") {
    if (cm_expr > max(out_df$x) & cm_expr < min(out_df$x)) {
      stop("compare_to outside of x range.", call. = FALSE)
    }
    out_df$compare_to <- cm_expr
  } else {
    stopifnot(cm_expr %in% c("diff_from_mean", "diff_from_median", "z-score"))
    out_df$compare_to <- switch(cm_expr,
                                "diff_from_mean" = mean(out_df$x),
                                "diff_from_median" = median(out_df$x),
                                "z-score" = mean(out_df$x)
    )
  }

  x = purrr::compact(
    list(
      data = out_df,
      title = title,
      unique_cats = unique_cats,
      fill_color = fill_color
    )
  )

  htmlwidgets::createWidget(
    name = 'pinpoint',
    x,
    package = 'pinpoint'
  )
}

#' Style a pinpoint visualization
#'
#' @param pinpoint A pinpoint object
#' @param point_radius Radius of points (in pixels)
#' @param point_opacity Opacity of points
#' @param number_format option to pass to d3.format()
#' @param jitter_width jitter width in pixels
#' @param fill_colors fill colors
#' @param compare_to_stroke_color color of compare mark
#' @param compare_to_stroke_width width of compare mark
#' @param greater_than_color color of diff line and text when value is greater than compare_mark_color
#' @param less_than_color color of diff line and text when value is less than compare_mark_color
#' @param diff_line_type 'solid' or 'dashed'
#' @param axis_range vector of length two, min and maximium range of axis
#' @param draw_line_duration duration in milliseconds to draw the diffline (0 = instant)
#' @param ticks number of axis ticks
#'
#' @return
#' @export
#'
#' @examples
pp_style <- function(pinpoint,
                     point_radius = 10,
                     point_opacity = 0.9,
                     number_format = ".5",
                     jitter_width = 0,
                     fill_colors = NULL,
                     compare_to_stroke_color = "black",
                     compare_to_stroke_width = 1.1,
                     greater_than_color = "forestgreen",
                     less_than_color = "firebrick",
                     diff_line_type = "dashed",
                     axis_range = NULL,
                     draw_line_duration = 800,
                     ticks = 8) {

  stopifnot(diff_line_type %in% c("solid", "dashed"))
  pinpoint$x$point_radius <- point_radius
  pinpoint$x$point_opacity <- point_opacity
  pinpoint$x$fill_colors = fill_colors
  pinpoint$x$number_format <- number_format
  pinpoint$x$jitter_width <- jitter_width
  pinpoint$x$compare_to_stroke_color <- compare_to_stroke_color
  pinpoint$x$compare_to_stroke_width <- compare_to_stroke_width
  pinpoint$x$greater_than_color <- greater_than_color
  pinpoint$x$less_than_color <- less_than_color
  pinpoint$x$line_type <- diff_line_type
  pinpoint$x$ticks <- ticks
  if (!is.null(axis_range)) pinpoint$x$axis_range <- axis_range
  pinpoint$x$draw_line_duration <- draw_line_duration
  return(pinpoint)
}


#' Shiny bindings for pinpoint
#'
#' Output and render functions for using pinpoint within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a pinpoint
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name pinpoint-shiny
#'
#' @export
pinpointOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'pinpoint', width, height, package = 'pinpoint')
}

#' @rdname pinpoint-shiny
#' @export
renderpinpoint <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, pinpointOutput, env, quoted = TRUE)
}
