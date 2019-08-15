#' Create a comparePoints visualization
#'
#' @param data A table of data
#' @param x A numeric variable.
#' @param fill Point color. Either an unquoted column name or valid string/hex color
#' @param tooltip Variable to display within tooltip
#' @param compare_mark the x-intercept to compare against values. Either a numeric value or "diff_from_mean", "diff_from_median", or "z-score"
#' @param title Visualization title
#'
#' @import htmlwidgets
#' @importFrom stats median
#'
#' @export
comparePoints <- function(data,
                          x,
                          fill = NULL,
                          tooltip = NULL,
                          compare_mark = "diff_from_mean",
                          title = ""
                          ) {

  x <- rlang::enquo(x)
  fill <- rlang::enquo(fill)
  tooltip <- rlang::enquo(tooltip)

  out_df <- data.frame(x = rep(NA, nrow(data)))
  out_df$x <- data[,rlang::quo_name(x)]
  out_df$tooltip <- data[,rlang::quo_name(tooltip)]

  if (inherits(rlang::get_expr(fill), "name")) {
    out_df$fill <- data[,rlang::quo_name(fill)]
    unique_cats <- sort(unique(out_df$fill))
    fill_color <- NULL
  } else {
    unique_cats <- NULL
    fill_color <- ifelse(is.null(rlang::get_expr(fill)), "steelblue", rlang::get_expr(fill))
  }

  if (!is.numeric(compare_mark)) {
    stopifnot(compare_mark %in% c("diff_from_mean", "diff_from_median", "z-score"))
    mark_intercept <- switch(compare_mark,
                             "diff_from_mean" = mean(out_df$x),
                             "diff_from_median" = median(out_df$x),
                             "z-score" = mean(out_df$x)
                             )
  } else {
    if (compare_mark > max(out_df$x) & compare_mark < min(out_df$x)) {
      stop("compare_mark outside of x range.", call. = FALSE)
    }
    mark_intercept <- compare_mark
  }


  x = purrr::compact(
    list(
      data = out_df,
      title = title,
      unique_cats = unique_cats,
      fill_color = fill_color,
      mark_intercept = mark_intercept
    )
  )

  htmlwidgets::createWidget(
    name = 'comparePoints',
    x,
    package = 'comparePoints'
  )
}

#' Style a comparePoints visualization
#'
#' @param comparePoints A comparePoints object
#' @param number_format option to pass to d3.format()
#' @param jitter_width jitter width in pixels
#' @param fill_colors fill colors
#' @param compare_mark_color color of compare mark
#' @param greater_than_color color of diff line and text when value is greater than compare_mark_color
#' @param less_than_color color of diff line and text when value is less than compare_mark_color
#' @param diff_line_type 'solid' or 'dashed'
#' @param axis_range vector of length two, min and maximium range of axis
#'
#' @return
#' @export
#'
#' @examples
cp_style <- function(comparePoints,
                     number_format = ".5",
                     jitter_width = 0,
                     fill_colors = NULL,
                     compare_mark_color = "black",
                     greater_than_color = "forestgreen",
                     less_than_color = "firebrick",
                     diff_line_type = "dashed",
                     axis_range = NULL) {

  stopifnot(diff_line_type %in% c("solid", "dashed"))
  comparePoints$x$fill_colors = fill_colors
  comparePoints$x$number_format <- number_format
  comparePoints$x$jitter_width <- jitter_width
  comparePoints$x$compare_mark_color <- compare_mark_color
  comparePoints$x$greater_than_color <- greater_than_color
  comparePoints$x$less_than_color <- less_than_color
  comparePoints$x$line_type <- diff_line_type
  if (!is.null(axis_range)) comparePoints$x$axis_range <- axis_range
  return(comparePoints)
}


#' Shiny bindings for comparePoints
#'
#' Output and render functions for using comparePoints within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a comparePoints
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name comparePoints-shiny
#'
#' @export
comparePointsOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'comparePoints', width, height, package = 'comparePoints')
}

#' @rdname comparePoints-shiny
#' @export
renderComparePoints <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, comparePointsOutput, env, quoted = TRUE)
}
