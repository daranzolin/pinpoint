#' Create a comparePoints visualization
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
comparePoints <- function(.data, x) {
  
  x <- rlang::enquo(x)
  out_df <- as.data.frame(subset(.data, select = c(tidyselect::vars_select(names(.data), !!x))))

  x = list(
    data = out_df
  )

  htmlwidgets::createWidget(
    name = 'comparePoints',
    x,
    package = 'comparePoints'
  )
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
