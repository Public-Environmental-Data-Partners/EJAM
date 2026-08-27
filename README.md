Environmental Justice Analysis Multisite tool
================

# <img src="man/figures/logo659.png" align="right" width="220px"/>

<!-- README.md is generated from README.Rmd. Please edit Rmd not md  -->

<!-- badges: start -->

<!-- or we could comment out the badge 
&#10;[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
 -->

<!-- badges: end -->

The Environmental Justice Analysis Multisite tool lets you easily and
quickly see residential population and environmental information
aggregated within and across hundreds or thousands of places, all at the
same time.

## What Can You Do with EJAM?

[What is
EJAM?](https://public-environmental-data-partners.github.io/EJAM/articles/whatis.html)

EJAM lets you specify the places to analyze in several ways – uploading
a table of point locations (latitude/longitude), picking facilities by
industry category or ID, uploading shapefiles or lists of Census FIPS
codes, or clicking on a map to specify one or more points – and it
returns a summary report comparing residents and environmental
conditions at those places to the rest of the country.

## What’s New in v3.2022.2 (August 2026)

The web app is quicker: the Details tab’s Site-by-Site table appears in
under a second for a 1,000-site analysis instead of six, PDF reports
finish seven seconds sooner, and County reports no longer pause to
download boundaries.

The community report gained rows showing the share of residents whose
block group holds a school, hospital, or place of worship, or overlaps a
Tribal area, impaired waters, or a disadvantaged community, each
compared to the US and State average. Those ratio columns now show by
default in the public app, and `?advanced=TRUE` opens the Advanced
Settings tab.

Fixes: the EJScreen “Send to EJAM” handoff no longer crashes, saved
reports are no longer empty when given a `filename`, zero-population
sites work, per-site API links carry the right site number.

A code-and-docs patch; packaged data unchanged. See [NEWS.md](NEWS.md).

## Status of EJAM package in 2026

See [ejanalysis.org/status](https://ejanalysis.org/status) for more
information.

*In 2025, content related to what had been the USEPA-hosted open source
R package EJAM was archived.*

*Ongoing development since then is not associated with EPA*, and that
development including any open source contributions, has taken place in
a separate repository, called
[Public-Environmental-Data-Partners/EJAM](https://github.com/Public-Environmental-Data-Partners/EJAM),
a non-EPA, detached fork.

### code repositories and open source contributions

See [ejanalysis.org/ejamrepo](https://ejanalysis.org/ejamrepo)

### documentation

See [ejanalysis.org/ejamdocs](https://ejanalysis.org/ejamdocs) for
current documentation.

### datasets

See [ejanalysis.com/ejam-code](https://ejanalysis.com/ejam-code)

Until mid-2025, datasets had been in a repository *archived and/or
unpublished in mid-2025*
([USEPA/ejamdata](https://github.com/USEPA/ejamdata)) with no plans for
it to be further updated by EPA.

### web app hosting

A (non-EPA) version of the EJAM web app may be found from within the
[EJSCREEN app](http://ejanalysis.org/ejscreenapp) (at the bottom of the
list under the “Tools” tab in EJSCREEN), or directly via this link:
[ejanalysis.org/ejamapp](https://ejanalysis.org/ejamapp)

For information about how to host the web app, see [Deploying the Web
App](https://public-environmental-data-partners.github.io/EJAM/articles/dev-deploy-app.html)
