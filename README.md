
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis build
status](https://travis-ci.org/daranzolin/pinpoint.svg?branch=master)](https://travis-ci.org/daranzolin/pinpoint)
![CRAN log](http://www.r-pkg.org/badges/version/pinpoint)

## pinpoint

The goal of pinpoint is to help users explore their smallish data across
a single axis. There are many ways to study a distribution–histograms,
box plots, density plots, etc.–but `pinpoint` lets you see the
proverbial trees from the forest.

### Installation

You can install the released version of pinpoint from GitHub with:

``` r
library(remotes)
install_github("daranzolin/pinpoint")
```

### Example

[A comprehensive introduction to the package can be viewed
here.](http://rpubs.com/daranzolin/pinpoint_intro)

``` r
library(pinpoint)
library(magrittr)
mtcars$name <- rownames(mtcars)
mtcars %>% 
  pinpoint(x = mpg, 
           fill = cyl, 
           tooltip = name,
           compare_mark = "diff_from_mean",
           title = "MPG by Cylinder") %>% 
  pp_style(jitter_width = 60,
           number_format = ".2")
```

![](inst/example1.gif)

### Future work

  - Compare z-scores
  - Multiple levels?
  - Additional styling
