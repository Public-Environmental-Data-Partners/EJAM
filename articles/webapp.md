# Accessing the Web App

## Web app for the public

EJAM’s toolkit can be used to host a web application. The web app
provides public access to batches of reports, with rapid multisite
analysis, by leveraging the EJAM toolkit.

See ejanalysis.org/ejam on where to find a public, non-EPA version of
the EJAM web app.

The version designed for use by the general public was specifically
configured for non-expert users, so it does not include some
less-frequently-used, complex features. More features are available in
the web app version that was invoked using “isPublic=FALSE.” Those
needing even more tools – the full set of complex analytic features –
can find them in the open source R package described below.

## Web app for expert users

Expert users can launch and use the so-called “internal” version of the
web app. It is specifically configured just for use by expert users.
This is the same as the version any developer can run locally using the
public code repository described below.

## Web app for analysts or developers using R/RStudio

The EJAM software and data are available as open source resources, so
that anyone using
[R/RStudio](https://posit.co/download/rstudio-desktop/) can use EJAM on
their own computer.

Analysts or developers using R/RStudio have the option of running a
local copy of the EJAM web app on their own computer. This may be even
faster than relying on a hosted web app, does not time out after
inactivity, and could be customized by a developer. You can also launch
it with customized options or use bookmarked settings (and/or use EJAM
functions and data directly without the web app, for more complex work).

You can install the EJAM R package and datasets as explained in
[Installing the EJAM R
package](https://public-environmental-data-partners.github.io/EJAM/articles/installing.md).
There is also a [Basics - Quick Start
Guide](https://public-environmental-data-partners.github.io/EJAM/articles/basics.md)
and extensive [documentation of EJAM
functions/tools/data](https://public-environmental-data-partners.github.io/EJAM/reference/index.md).

Once EJAM is installed, you can launch the local web app from RStudio as
follows:

``` r

require(EJAM) # or  library(EJAM)

options(shiny.launch.browser = TRUE) # so the web app uses a browser (not the RStudio viewer)

ejamapp()
```

The Multisite Tool configuration is available via `ejamapp(isPublic=T)`
and the version for expert use is available via `ejamapp(isPublic=F)`

See documentation of optional parameters via `?ejamapp()`

Note this is different than running a simple shiny app that is not also
a package via the [golem](https://golemverse.org/) package. You should
use the EJAM package function
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
rather than
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).
