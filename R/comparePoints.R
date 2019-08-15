#' Create a comparePoints visualization
#'
#' @param data A table of data
#' @param x A numeric variable.
#' @param fill dot color. Either an unquoted column name or valid string or hex color
#' @param compare_mark the x-intercept to compare against values
#' @param title Visualization title
#' @param ... optional variables to include in the tooltip
#'
#' @import htmlwidgets
#'
#' @export
comparePoints <- function(data,
                          x,
                          fill = NULL,
                          compare_mark = NULL,
                          title = "",
                          ...) {

  x <- rlang::enquo(x)
  fill <- rlang::enquo(fill)
  if (inherits(rlang::get_expr(fill), "name")) {
    out_df <- as.data.frame(subset(data, select = c(tidyselect::vars_select(names(data), !!x, !!fill))))
    names(out_df) <- c("x", "fill")
    unique_cats <- sort(unique(out_df$fill))
    fill_color <- NULL
  } else {
    out_df <- as.data.frame(subset(data, select = c(tidyselect::vars_select(names(data), !!x))))
    names(out_df) <- "x"
    unique_cats <- NULL
    fill_color <- ifelse(is.null(rlang::get_expr(fill)), "blue", rlang::get_expr(fill))
  }

  if (is.null(compare_mark)) {
    compare_mark <- mean(out_df$x)
  }
  if (compare_mark > max(out_df$x) & compare_mark < min(out_df$x)) {
    stop("compare_mark outside of x range.", call. = FALSE)
  }

  x = purrr::compact(
    list(
      data = out_df,
      title = title,
      unique_cats = unique_cats,
      fill_color = fill_color,
      compare_mark = compare_mark
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
#' @param comparePoints
#' @param axis_format option to pass to d3.format()
#' @param jitter_width jitter width in pixels
#'
#' @return
#' @export
#'
#' @examples
cp_style <- function(comparePoints,
                     axis_format = ",",
                     jitter_width = 0) {

  comparePoints$x$axis_format <- axis_format
  comparePoints$x$jitter_width <- jitter_width
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
