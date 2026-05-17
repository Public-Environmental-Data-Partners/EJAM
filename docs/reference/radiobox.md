# DRAFT - addin/ gadget dialog box so RStudio user can pick a radio button Interactive dialog box of choices (RStudio addin that wraps a Shiny Gadget)

DRAFT - addin/ gadget dialog box so RStudio user can pick a radio button
Interactive dialog box of choices (RStudio addin that wraps a Shiny
Gadget)

## Usage

``` r
radiobox(
  choiceNames = c("Points", "Shapes", "FIPS"),
  choiceValues = c("latlon", "shp", "fips"),
  label = "Choose one:",
  title = "",
  height = 250,
  width = 100
)
```

## Arguments

- choiceNames:

  vector of options displayed, e.g., c("Points", "Shapes", "FIPS")

- choiceValues:

  vector of corresponding values as returned by the function, e.g.,
  c("latlon", "shp", "fips")

- label:

  Appears at top of dialog box and between cancel and done, e.g.,
  "Choose one:"

- title:

  Appears just above the list of choices, e.g., "Select One"

- height:

  height of box in pixels, e.g., 250

- width:

  width of box in pixels, e.g., 100

## Value

one of the choiceValues (if not canceled/ error), once Done is clicked.

## Details

uses
[`shiny::runGadget()`](https://rdrr.io/pkg/shiny/man/runGadget.html)

\*\*\* WARNING: AS DRAFTED, CANNOT use within nontrivial scripts or
functions because the
[`stopApp()`](https://rdrr.io/pkg/shiny/man/stopApp.html) seems to
interrupt other processes and cause problems - and seems related to a
quirk seen if a script or function calls radiobox() twice - it will work
the first time but show a blank popup window the 2d time... e.g., if you
try to do this: radius1 \<- radiobox() radius2 \<- radiobox() May all be
related to this issue: https://github.com/rstudio/rstudio/issues/13394

Note this function could be defined as an RStudio addin and assigned a
keyboard shortcut, if that is useful.

## Examples

``` r
# chosen <- EJAM:::radiobox()
# cat("you chose", chosen, '\n')
 junk = function() {
  z =  EJAM:::radiobox()
  # print(z)
  return(z)
if (FALSE) { # \dontrun{
 if (interactive()) {
 # (note this works after load_all or if it is an exported function)
 radius <- EJAM:::radiobox(
  c("Far (3 miles)", "Medium (2 miles)", "Near (1 mile)"),
  c(3,2,1),
  label = "Radius"
 )
 cat("The radius will be", radius, "miles. \n")
}
} # }
}
```
