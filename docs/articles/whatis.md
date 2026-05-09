# What is EJAM?

## The Environmental Justice Analysis Multisite tool

### EJAM is a web app but also a toolkit

The Environmental Justice Analysis Multisite tool (EJAM) is both a web
app and a software toolkit:

- [EJAM can be used as a web
  app](https://public-environmental-data-partners.github.io/EJAM/articles/webapp.md),
  providing a simple user interface that lets anyone quickly see the
  results of a basic analysis. EJAM is what powered the EJSCREEN
  Multisite Tool web application in late 2024/early 2025.

- EJAM is also an open-source software package (and local web app) for
  developers and analysts. It is an R package written in the [R
  programming language](https://www.r-project.org/), with source code on
  GitHub. It provides functions to help analysts work with blockgroup
  data, points, and polygons, to quickly aggregate and compare large
  numbers of locations.

### What does it do?

EJAM lets you easily and quickly see residential population and
environmental information aggregated within and across hundreds or
thousands of places, all at the same time.

Using EJAM is like running a community environmental/census data report,
but for hundreds or thousands of places, all at the same time.

You can see a quick summary, explore interactive maps, tables, and
plots, and download a summary report or detailed spreadsheet.

Locations can be defined in a variety of ways, so EJAM can summarize the
following:

- **Conditions near any set of points**  
  (e.g., proximity analysis of residents near all the EPA-regulated
  facilities of a certain type). This can provide information about
  people who live in communities potentially affected by any of the
  industrial facilities on a list, for example.

- **Conditions within any areas you have defined on a map**  
  (e.g., if you have a shapefile of polygons/ zones based on measured or
  modeled exposure or risk, or cities/neighborhoods, etc.).

### EPA Data & Methods

EJAM begins with residential population and environmental data and
indicators. The default indicators are the ones used in EJSCREEN. It
uses the same methods as EJSCREEN but in a way that is optimized for
working with many locations at once.

The tool runs either a polygon-based or proximity-based analysis at each
location, just like EJSCREEN would provide a standard report for a
single location, except EJAM does this for each of a large number of
locations very quickly.

### New & Unique Features

**Summarizing Across Locations**

EJAM can calculate an aggregated summary of overall environmental
conditions and residential population percentages for the average
resident’s location, across all the populations and all of the
locations.

The summary report lets you quickly and easily see which residential
population groups live near the selected facilities or within defined
areas. It also provides new insights into which environmental stressors
may affect specific residential population subgroups to varying degrees,
near a regulated sector overall and at individual sites.

This allows geospatial analysis to move beyond a small number of
indicators for a few residential population groups at one site in a
single permitting decision, to a more complete picture of conditions
near a whole set of facilities that may be the focus of a risk analysis
or proposed action.

**Immediate Results (Speed)**

Compared to related GIS tools this new tool provides a ready-to-use
summary report, plus more flexibility, accuracy, and speed than other
tools have in the past. The website quickly provides results on the fly
– The software was optimized to be extremely fast (allowing real-time
exploratory work), while still using the same block-population
calculation EJSCREEN has been using, making it more consistent with how
EJSCREEN has always worked and more accurate than other approaches
(e.g., using “areal apportionment” of tracts or blockgroups, like some
other tools have used).

**Easy Ways to Specify the Places to Analyze**

The new tool also lets users pick locations through several approaches:
specifying facility points by industry categories (NAICS, SIC, EPA
program, etc.), providing a table of point locations as
latitudes/longitudes, using shapefiles with polygons (e.g., from air
quality modeling), and selecting Census units to compare, such as
counties.

**Open Source Well-Documented Extensible Software**

Also, the data and software are shared as reusable, well-documented
functions in an R package, to allow software developers or analysts to
take advantage of these resources in running their own analyses or
building or supplementing their own tools, websites, or mobile apps.

**Accuracy and Spatial Resolution**

EJAM and EJSCREEN use the same approach to characterizing populations at
each site, to maintain consistency and avoid confusion. Compared to
other common approaches, EJSCREEN/EJAM use high-resolution buffering to
provide more accurate information about which populations live inside a
buffer, which is important in rural areas where a single blockgroup can
cover a very large area. For circular buffers, internal points of Census
2020 blocks are used rather than areal apportionment of blockgroups to
estimate where residents live within each blockgroup. This avoids the
simplistic assumption that people are evenly spread out within each
blockgroup. Instead, it uses blocks to estimate where residents actually
live within each blockgroup. There are several million blocks in the
United States, compared with fewer than a quarter million blockgroups.
The only more accurate approaches are: 1) using areal apportionment of
blocks (not blockgroups), which is very slow, or 2) using very
high-resolution grids (for example, 30x30 meter grids), which require
large amounts of storage and compute time.

EJAM calculations also take note of which residences are near which
sites, to avoid double-counting people in the summary statistics but
still allow a user to view results for one site at a time. This is
something other tools and analyses often cannot provide - when they
aggregate across sites they typically do not retain the statistics on
individual sites, and rarely if ever keep track of which communities are
near multiple facilities. Keeping track of this would also allow an
analyst to explore how many people are near multiple sites, or ask which
sites in communities that already have multiple sites nearby.

EJAM was designed so that it can provide an essentially continuous
distribution of distances, as distributed across blocks or people for
one or all of the nearby facilities. This enables exploration of the
complete picture of proximities, rather than using an arbitrary single
distance defining near versus far. The distribution can be sliced later
for the summary statistics at any distance, and can be summarized as a
distribution of distances within each residential population group.

### Data Updates and Data Vintage

EPA released EJSCREEN version 2.32 in August 2024 and took EJSCREEN
offline in January 2025, with no plans for any further development or
updates. The same underlying dataset was used in EJAM version 2.32.0 and
EJSCREEN version 2.32 released in late 2024. Non-EPA development of EJAM
through version 2.32.8 (April 2026) still used that same dataset, based
on American Community Survey (ACS) data for 2018-2022. In 2026, EJAM
version 2.5.0 incorporated the 2020-2024 ACS data, providing EJSCREEN
with demographic data two years newer than was in the last version EPA
released.

EJAM version 2.5.0 (released May 2026) is based on American Community
Survey (ACS) data representing the five-year period of 2020-2024
(released by the Census Bureau 2026-01-29). The ACS data are the basis
for blockgroup resolution estimates of demographic and other data on
residential populations and households.

Census 2020 block population counts are used for the approximate
distribution of residents within a given blockgroup.
