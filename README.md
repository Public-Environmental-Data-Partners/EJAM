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

The web app is noticeably quicker. The Site-by-Site table on the Details
tab now appears in well under a second for a 1,000-site analysis instead
of roughly six, PDF reports finish about seven seconds sooner, and
County reports no longer stop to download boundaries – those are built
into the package now, so Puerto Rico counties map correctly and no
Census API key is needed.

The community report gained a set of rows showing what share of the
analyzed residents live in a block group that contains a school,
hospital, or place of worship, or that overlaps a Tribal area,
nonattainment area, impaired waters, or a disadvantaged-community
designation – each compared against both the US and the relevant State
average. Those ratio-to-US and ratio-to-State columns are now shown by
default in the public app, not only the private one, and `ejam2excel()`
writes a matching “Area Features” tab.

Launching the app with `?advanced=TRUE` opens it with the Advanced
Settings tab visible, even on a public deployment.

Several long-standing bugs are fixed. The EJScreen “Send to EJAM”
handoff no longer crashes the session. Saved reports are no longer empty
when you pass a `filename`. Sites with no residents no longer break
report generation. Per-site report links from the API are labeled with
the correct site number instead of all reading “Site 1”. Percentages
that used to display as “0”, “1”, or “55.30%” now read as whole
percents. Internally, every key project URL moved into `DESCRIPTION` and
is read through `url_package()`.

This is a code-and-docs patch: it reuses the published `ejamdata`
v3.2022.0 release, with no change to the packaged ACS or environmental
data. Full details are in [NEWS.md](NEWS.md).

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
