# Package index

## Start an Analysis - Key Functions

Starting the Analysis

- [`EJAM`](https://public-environmental-data-partners.github.io/EJAM/reference/EJAM.md)
  [`EJAM-package`](https://public-environmental-data-partners.github.io/EJAM/reference/EJAM.md)
  : EJAM - Environmental Justice Analysis Multisite tool
- [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
  : Launch EJAM as Shiny web app (e.g. to run it locally in RStudio)
- [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  : Get an EJ analysis (residential population and environmental
  indicators) in or near a list of locations
- [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)
  : Compare EJAM results overall for more than one radius Run ejamit()
  once per radius, get a summary table with a row per radius
- [`ejamit_compare_types_of_places()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_types_of_places.md)
  : Compare subsets (types) of places that are all from one list

## View Results - Key Functions

Viewing the Results

- [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
  : Save EJAM results in a spreadsheet
- [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  : View HTML Report on EJAM Results (Overall or at 1 Site)
- [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md)
  : Show EJAM results as a map of points
- [`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md)
  : Barplot of ratios of residential population (or other) scores to
  averages - simpler syntax
- [`ejam2barplot_indicators()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_indicators.md)
  : Create facetted barplots of groups of indicators
- [`ejam2barplot_areafeatures()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_areafeatures.md)
  : barplot of summary stats on special areas and features at the sites
- [`ejam2boxplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2boxplot_ratios.md)
  : Make boxplot of ratios to US averages
- [`ejam2barplot_sites()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_sites.md)
  : Barplot comparing sites on 1 indicator, based on full output of
  ejamit() easy high-level function for getting a quick look at top few
  sites
- [`ejam2barplot_sitegroups()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_sitegroups.md)
  : Barplot comparing groups of sites on 1 indicator, for output of
  ejamit_compare_types_of_places() easy high-level function for getting
  a quick look at top few groups of sites
- [`ejam2barplot_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_distances.md)
  : Barplot comparing ejamit_compare_distances() results for more than
  one radius
- [`ejam2histogram()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2histogram.md)
  : Histogram of single indicator from EJAM output
- [`ejam2ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2ratios.md)
  : Quick view of summary stats by type of stat, but lacks rounding
  specific to each type, etc.
- [`ejam2means()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2means.md)
  : ejam2means - quick look at averages, via ejamit() results
- [`ejam2tableviewer()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2tableviewer.md)
  : See ejamit()\$results_bysite in interactive table in RStudio viewer
  pane
- [`ejam2table_tall()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2table_tall.md)
  : Simple quick look at results of ejamit() in RStudio console
- [`ejam2shapefile()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2shapefile.md)
  : export EJAM results as geojson/zipped shapefile/kml for use in
  ArcPro, EJSCREEN, etc.

## Specify Points by Lat/Lon

Utilities for working with latitude/ longitude or address

- [`testpoints_n()`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_n.md)
  : Random points in USA - average resident, facility, BG, block, or
  square mile
- [`sitepoints_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/sitepoints_from_any.md)
  [`sitepoints_from_anything()`](https://public-environmental-data-partners.github.io/EJAM/reference/sitepoints_from_any.md)
  : Get lat/lon flexibly - from file, data.frame, data.table, or lat/lon
  vectors Like latlon_from_anything() but this also adds a ejam_uniq_id
  column
- [`latlon_from_anything()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_anything.md)
  : Get lat/lon flexibly - from file, data.frame, data.table, or lat/lon
  vectors
- [`latlon_from_address_table()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_address_table.md)
  : get lat,lon from table that contains USPS addresses
- [`latlon_from_address()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_address.md)
  : geocode, but only if AOI package is installed and attached and what
  it imports like tidygeocoder etc.
- [`latlon_from_shapefile()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_shapefile.md)
  : Convert shapefile (class sf) to data.table of lat and lon columns
  Makes lat and lon columns, from a sfc_POINT class geometry field, or
  finds centroids of POLYGONS
- [`latlon_from_shapefile_centroids()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_shapefile_centroids.md)
  : get coordinates of each polygon centroid, using INTPTLAT,INTPTLON if
  those columns already exist
- [`latlon_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_fips.md)
  : get approx centroid of each fips census unit
- [`address_from_table()`](https://public-environmental-data-partners.github.io/EJAM/reference/address_from_table.md)
  : get USPS addresses from a table of that info
- [`latlon_is.valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.valid.md)
  : Check if lat lon are OK – validate latitudes and longitudes
- [`lat_alias`](https://public-environmental-data-partners.github.io/EJAM/reference/lat_alias.md)
  : lat_alias, lon_alias (DATA) Synonyms for lat and lon
- [`islandareas`](https://public-environmental-data-partners.github.io/EJAM/reference/islandareas.md)
  : islandareas (DATA) table, bounds info on lat lon of US Island Areas

## Specify Facilities by ID

- [`latlon_from_regid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_regid.md)
  : Get latitude, longitude (and NAICS) via EPA Facility Registry ID See
  FRS Facility Registry Service data on EPA-regulated sites
- [`regids_valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/regids_valid.md)
  : validate regids by checking if they are in the database being used
  currently
- [`latlon_from_programid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_programid.md)
  : Get lat lon, Registry ID, and NAICS, for given FRS Program System ID
- [`frs_from_programid()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_programid.md)
  : Use EPA Program ID to see FRS Facility Registry Service data on
  those EPA-regulated sites
- [`frs_from_sitename()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_sitename.md)
  : Use site name text search to see FRS Facility Registry Service data
  on those EPA-regulated sites
- [`frs`](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md)
  : frs (DATA) EPA Facility Registry Service table of regulated sites
- [`frs_by_programid`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_programid.md)
  : frs_by_programid (DATA) data.table of Program System ID code(s) for
  each EPA-regulated site in the Facility Registry Service

## Specify Facilities by Type

NAICS, SIC, MACT, or EPA Program

### Choosing NAICS/SIC Industry Codes

- [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
  : NAICS - General way to search for industry names and NAICS codes
- [`sic_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_from_any.md)
  : General way to search for industry names and NAICS codes
- [`naics_is.valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_is.valid.md)
  : validate industry NAICS codes
- [`naics_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_categories.md)
  : NAICS - See the names of industrial categories and their NAICS code
- [`sic_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_categories.md)
  : See the names of SIC industrial categories and their codes
- [`naics_url_of_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_url_of_code.md)
  : NAICS - Get URL for page with info about industry sector(s) by NAICS
- [`naics_findwebscrape()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_findwebscrape.md)
  : for query term, show list of roughly matching NAICS, scraped from
  web
- [`naics_subcodes_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_subcodes_from_code.md)
  : NAICS - find subcategories of the given overall NAICS industry
  code(s)
- [`sic_subcodes_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_subcodes_from_code.md)
  : Find subcategories of the given overall SIC industry code(s)
- [`naics2children()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics2children.md)
  : NAICS - query NAICS codes and also see all children (subcategories)
  of any of those
- [`sic_from_name()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_from_name.md)
  : Search for industry names and SIC codes by query string
- [`sic_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_from_code.md)
  : Search for industry names by SIC code(s), 4 digits each

### Using NAICS/SIC Industry Codes

- [`latlon_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_naics.md)
  : Find EPA-regulated facilities in FRS by NAICS code (industrial
  category)
- [`latlon_from_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_sic.md)
  : Find EPA-regulated facilities in FRS by SIC code (industrial
  category)
- [`regid_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/regid_from_naics.md)
  : Find registry ids of EPA-regulated facilities in FRS by NAICS code
  (industrial category) Like latlon_from_naics() but returns only regid
- [`frs_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_naics.md)
  : Use NAICS code or industry title text search to see FRS Facility
  Registry Service data on those EPA-regulated sites
- [`frs_from_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_sic.md)
  : Use SIC code or industry title text search to see FRS Facility
  Registry Service data on those EPA-regulated sites

### NAICS/SIC datasets

- [`testinput_naics`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_naics.md)
  : testinput_naics dataset
- [`naics_counts`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_counts.md)
  : naics_counts (DATA) data.frame with regulated facility counts for
  each industry code
- [`NAICS`](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md)
  : NAICS (DATA) named list of all NAICS code numbers and industry name
  for each
- [`SIC`](https://public-environmental-data-partners.github.io/EJAM/reference/SIC.md)
  : SIC (DATA) named list of all SIC code numbers and category name for
  each
- [`naicstable`](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md)
  : naicstable (DATA) data.table of NAICS code(s) and industry names for
  each EPA-regulated site
- [`sictable`](https://public-environmental-data-partners.github.io/EJAM/reference/sictable.md)
  : sictable (DATA) data.table of SIC code(s) and industry names for
  each EPA-regulated site
- [`frs_by_naics`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_naics.md)
  : frs_by_naics (DATA) data.table of NAICS code(s) for each
  EPA-regulated site in Facility Registry Service
- [`frs_by_sic`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_sic.md)
  : frs_by_sic (DATA) data.table of SIC code(s) for each EPA-regulated
  site in Facility Registry Service

### EPA Programs

- [`testinput_program_name`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_program_name.md)
  : testinput_program_name dataset
- [`testinput_program_sys_id`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_program_sys_id.md)
  : test data, EPA program names and program system ID numbers to try
  using
- [`epa_programs`](https://public-environmental-data-partners.github.io/EJAM/reference/epa_programs.md)
  : epa_programs (DATA) named vector with program counts
- [`epa_programs_defined`](https://public-environmental-data-partners.github.io/EJAM/reference/epa_programs_defined.md)
  : Full names and definitions for acronyms of EPA programs in Facility
  Registry Services (FRS)
- [`latlon_from_program()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_program.md)
  : Get lat lon, Registry ID, and NAICS, for given FRS Program System
  CATEGORY
- [`frsprogramcodes`](https://public-environmental-data-partners.github.io/EJAM/reference/frsprogramcodes.md)
  : frsprogramcodes DATA EPA programs listed in Facility Registry
  Service
- [`frs_from_program()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_program.md)
  : Use EPA Program acronym like TRIS to see FRS Facility Registry
  Service data on those EPA-regulated sites

### MACT Categories

- [`testinput_mact`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_mact.md)
  : testinput_mact dataset
- [`mact_table`](https://public-environmental-data-partners.github.io/EJAM/reference/mact_table.md)
  : mact_table (DATA) MACT NESHAP subparts (the code and the
  description)
- [`latlon_from_mactsubpart()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_mactsubpart.md)
  : Get point locations for US EPA-regulated facilities that have
  sources subject to Maximum Achievable Control Technology (MACT)
  standards under the Clean Air Act.
- [`frs_by_mact`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_mact.md)
  : frs_by_mact (DATA) MACT NESHAP subpart(s) that each EPA-regulated
  site is subject to

## Specify Places by Shapefile

- [`testinput_shapes_2`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_shapes_2.md)
  : testinput_shapes_2 dataset
- [`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
  : Read shapefile from any file or folder (trying to infer the format)
- [`shapefile_from_sitepoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_sitepoints.md)
  : Convert table of lat,lon points/sites into spatial data.frame /
  shapefile
- [`shapefile_clean()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_clean.md)
  : Drop invalid rows, warn if all invalid, add unique ID, transform
  (CRS)
- [`shape_buffered_from_shapefile()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape_buffered_from_shapefile.md)
  : shape_buffered_from_shapefile - add buffer around shape
- [`shape_buffered_from_shapefile_points()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape_buffered_from_shapefile_points.md)
  : shape_buffered_from_shapefile_points - add buffer around shape
  (points, here)
- [`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
  : Download shapefiles based on FIPS codes of States, Counties,
  Cities/CDPs, Tracts, or Blockgroups (not blocks)
- [`shapes_counties_from_countyfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_counties_from_countyfips.md)
  : Get Counties boundaries via API, to map them
- [`shapes_blockgroups_from_bgfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_blockgroups_from_bgfips.md)
  : Get blockgroups boundaries, via API, to map them
- [`shape2zip()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape2zip.md)
  : Save spatial data.frame as shapefile.zip
- [`ejam2shapefile()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2shapefile.md)
  : export EJAM results as geojson/zipped shapefile/kml for use in
  ArcPro, EJSCREEN, etc.
- [`shape2geojson()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape2geojson.md)
  : convert spatial data.frame to a vector of geojson text strings
- [`latlon_from_shapefile()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_shapefile.md)
  : Convert shapefile (class sf) to data.table of lat and lon columns
  Makes lat and lon columns, from a sfc_POINT class geometry field, or
  finds centroids of POLYGONS
- [`latlon_from_shapefile_centroids()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_shapefile_centroids.md)
  : get coordinates of each polygon centroid, using INTPTLAT,INTPTLON if
  those columns already exist

## Specify Counties etc.

Tools to work with Census units & FIPS codes - blockgroups, tracts,
counties, states, & EPA Regions

### FIPS tools

- [`name2fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/name2fips.md)
  : Get FIPS codes from names of states or counties inverse of
  fips2name(), 1-to-1 map statename, ST, countyname to FIPS of each
- [`fips2name()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2name.md)
  : FIPS - Get county or state names from county or state FIPS codes
- [`fips2countyfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2countyfips.md)
  : FIPS - Get FIPS codes of the Counties CONTAINING the given census
  units (of any type)
- [`fipstype()`](https://public-environmental-data-partners.github.io/EJAM/reference/fipstype.md)
  : FIPS - Identify what type of Census geography each FIPS code seems
  to be (block, county, etc.)
- [`fips_valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_valid.md)
  : check if FIPS code is valid, meaning it is an actual Census FIPS
  code for a State, County, City/CDP, etc.
- [`fips_lead_zero()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_lead_zero.md)
  : FIPS - Add leading zeroes to fips codes if missing, replace with NA
  if length invalid
- [`latlon_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_fips.md)
  : get approx centroid of each fips census unit
- [`fips2pop()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2pop.md)
  : Get population counts (ACS EJSCREEN) by FIPS Utility to aggregate
  just population count for each FIPS Census unit
- [`fips_from_table()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_from_table.md)
  : FIPS - Read and clean FIPS column from a table, after inferring
  which col it is
- [`fips_bgs_in_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_bgs_in_fips.md)
  : FIPS - Get unique blockgroup fips in or containing specified fips of
  any type
- [`fips_place_from_placename()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_place_from_placename.md)
  : search using names of cities, towns, etc. to try to find matches and
  get FIPS helper used by name2fips()
- [`censusplaces`](https://public-environmental-data-partners.github.io/EJAM/reference/censusplaces.md)
  : censusplaces (DATA) Census FIPS and other basic info on roughly
  40,000 cities/towns/places

### Counties

- [`counties_as_sites()`](https://public-environmental-data-partners.github.io/EJAM/reference/counties_as_sites.md)
  : FIPS - Analyze US Counties as if they were sites, to get summary
  indicators summary for each county
- [`fips_counties_from_statefips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_counties_from_statefips.md)
  : FIPS - Get ALL county fips in specified states
- [`fips_counties_from_state_abbrev()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_counties_from_state_abbrev.md)
  : FIPS - Get ALL county fips in specified states
- [`fips_counties_from_statename()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_counties_from_statename.md)
  : FIPS - Get ALL county fips in specified states
- [`fips2countyname()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2countyname.md)
  : FIPS - Get names for the Counties CONTAINING the given census units
  (of any type)
- [`fips2countyfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2countyfips.md)
  : FIPS - Get FIPS codes of the Counties CONTAINING the given census
  units (of any type)
- [`shapes_counties_from_countyfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_counties_from_countyfips.md)
  : Get Counties boundaries via API, to map them
- [`acs_bycounty()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_bycounty.md)
  : download ACS 5year data from Census API, at County resolution
- [`plot_bycounty()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_bycounty.md)
  : plot comparison of counties in 1 state, for 1 indicator (variable)
- [`url_county_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_health.md)
  : URL functions - Get URLs of useful report(s) on Counties containing
  the given fips, from countyhealthrankings.org
- [`url_county_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_equityatlas.md)
  : URL functions - Get URLs of useful report(s) on County containing
  the given fips from nationalequityatlas.org

### States

- [`states_shapefile`](https://public-environmental-data-partners.github.io/EJAM/reference/states_shapefile.md)
  : This is used to figure out which state contains each point
  (facility/site).
- [`states_as_sites()`](https://public-environmental-data-partners.github.io/EJAM/reference/states_as_sites.md)
  : FIPS - Analyze US States as if they were sites, to get summary
  indicators summary
- [`fips_state_from_state_abbrev()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_state_from_state_abbrev.md)
  : FIPS - Get state fips for each state abbrev
- [`fips_state_from_statename()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_state_from_statename.md)
  : FIPS - Get state fips for each state name
- [`fips_states_in_eparegion()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_states_in_eparegion.md)
  : FIPS - Get state fips for all States in EPA Region(s)
- [`fips2statename()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2statename.md)
  : FIPS - Get names of the States CONTAINING the given census units (of
  any type)
- [`fips2stateabbrev()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2stateabbrev.md)
  : FIPS - Get state abbreviations of the states containing the given
  census units (of any type)
- [`fips2statefips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2statefips.md)
  : FIPS - Get FIPS codes of the States CONTAINING the given census
  units (of any type)
- [`state_from_fips_bybg()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_fips_bybg.md)
  : Get FIPS of ALL BLOCKGROUPS in the States or Counties specified
- [`state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_latlon.md)
  : Find what state is where each point is located
- [`url_state_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_health.md)
  : URL functions - Get URLs of useful report(s) on STATES containing
  the given fips, from countyhealthrankings.org
- [`url_state_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_equityatlas.md)
  : URL functions - Get URLs of useful report(s) on STATE containing the
  given fips, from equity atlas

### Regions

- [`fips_st2eparegion()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_st2eparegion.md)
  : FIPS - Get EPA Region number (1-10) from state FIPS code

## Residents, Blocks, & Distances

GIS tools calculating which blocks (& residents) are in or near each
place (within given radius of point or in FIPS or polygon), & their
distances

- [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  : Very fast way to distances to all nearby Census blocks
- [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
  : Find all blocks within each of the FIPS codes provided
- [`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md)
  : Find all Census blocks in a polygon, using internal point of block
- [`getblocks_diagnostics()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocks_diagnostics.md)
  : utility - How many blocks and many other stats about blocks and
  sites
- [`get_ejscreen_facilities_nearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_ejscreen_facilities_nearby.md)
  : find, count, map nearby facilities (NPL, TSDF, TRI, etc., as
  available in EJSCREEN) via API
- [`getpointsnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearby.md)
  : Find IDs of and distances to all nearby points (e.g., schools, or
  EPA-regulated facilities, etc.)
- [`getfrsnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getfrsnearby.md)
  : Find all EPA-regulated facilities nearby each specified point and
  distances
- [`proxistat()`](https://public-environmental-data-partners.github.io/EJAM/reference/proxistat.md)
  : DRAFT - Create a custom proximity score for every blockgroup,
  representing count and proximity of specified points Indicator of
  proximity of residents in each US blockgroup to a custom set of
  facilities or sites
- [`indexblocks()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexblocks.md)
  : Create localtree (a quadtree index of all US block centroids) in
  global environment
- [`indexpoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexpoints.md)
  : Utility to create efficient quadtree spatial index of any set of
  lat,lon
- [`indexfrs()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexfrs.md)
  : Utility to create an efficient quadtree spatial index of
  EPA-regulated facility locations
- [`convert_units()`](https://public-environmental-data-partners.github.io/EJAM/reference/convert_units.md)
  : Convert units of distance or area
- [`fips2pop()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2pop.md)
  : Get population counts (ACS EJSCREEN) by FIPS Utility to aggregate
  just population count for each FIPS Census unit

### Datasets with Indicators (raw data, means, percentiles)

- [`blockgroupstats`](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md)
  : blockgroupstats (DATA) residential population and environmental
  indicators for Census blockgroups
- [`bgej`](https://public-environmental-data-partners.github.io/EJAM/reference/bgej.md)
  : bgej (DATA) Summary Indexes for Census blockgroups
- [`bgpts`](https://public-environmental-data-partners.github.io/EJAM/reference/bgpts.md)
  : bgpts (DATA) lat lon of popwtd center of blockgroup, and count of
  blocks per blockgroup
- [`bg_cenpop2020`](https://public-environmental-data-partners.github.io/EJAM/reference/bg_cenpop2020.md)
  : bg_cenpop2020 (DATA) data.table with all US Census 2020 blockgroups
- [`avg.in.us`](https://public-environmental-data-partners.github.io/EJAM/reference/avg.in.us.md)
  : avg.in.us (DATA) national averages of key indicators, for
  convenience
- [`usastats`](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md)
  : usastats (DATA) data.frame of 100 percentiles and means
- [`stateinfo`](https://public-environmental-data-partners.github.io/EJAM/reference/stateinfo.md)
  : stateinfo (DATA) data.frame of state abbreviations and state names
  (50+DC+PR; not AS, GU, MP, VI, UM)
- [`stateinfo2`](https://public-environmental-data-partners.github.io/EJAM/reference/stateinfo2.md)
  : stateinfo2 (DATA) data.frame of state abbreviations and state names
  (50+DC+PR; not AS, GU, MP, VI, UM)
- [`statestats`](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md)
  : statestats (DATA) data.frame of 100 percentiles and means for each
  US State and PR and DC.
- [`modelDoaggregate`](https://public-environmental-data-partners.github.io/EJAM/reference/modelDoaggregate.md)
  : Regression model to predict runtime for doaggregate
- [`modelEjamit`](https://public-environmental-data-partners.github.io/EJAM/reference/modelEjamit.md)
  : Regression model to predict runtime for ejamit

### Using ACS Data to Calculate New Indicators

- [`url_acs_table_info()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_acs_table_info.md)
  : get URL(s) of Census Bureau pages showing ACS 5-year tables examples
- [`acs_endyear()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_endyear.md)
  : check which ACS 5-year survey is available from Census Bureau or in
  EJAM/EJSCREEN
- [`tables_ejscreen_acs`](https://public-environmental-data-partners.github.io/EJAM/reference/tables_ejscreen_acs.md)
  : tables_ejscreen_acs dataset
- [`formulas_ejscreen_acs`](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md)
  : formulas_ejscreen_acs dataset
- [`acs_bybg()`](https://public-environmental-data-partners.github.io/EJAM/reference/acs_bybg.md)
  : download ACS 5year data from Census API, at blockgroup resolution
  (slowly if for entire US)
- [`calc_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejam.md)
  : DRAFT utility to use formulas provided as text, to calculate
  indicators
- [`calc_byformula()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_byformula.md)
  : DRAFT utility to use formulas provided as text, to calculate
  indicators

## Calculating and Aggregating

Tools that Create or Aggregate Indicators at each Place & Overall, &
Report Percentiles or Means

- [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  : Summarize environmental and residential population indicators at
  each location and overall
- [`calc_ejam()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejam.md)
  : DRAFT utility to use formulas provided as text, to calculate
  indicators
- [`calc_byformula()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_byformula.md)
  : DRAFT utility to use formulas provided as text, to calculate
  indicators
- [`pctile_from_raw_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)
  [`lookup_pctile()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_from_raw_lookup.md)
  : Find approx percentiles in lookup table for just 1 indicator or 1
  zone (State or US)
- [`pctile_x_is_hit_by_score()`](https://public-environmental-data-partners.github.io/EJAM/reference/pctile_x_is_hit_by_score.md)
  : Check whether raw scores meet a percentile cutoff (e.g., to see
  which blockgroups are at high percentiles)
- [`usastats_means()`](https://public-environmental-data-partners.github.io/EJAM/reference/usastats_means.md)
  : usastats_means - convenient way to see US MEANS of ENVIRONMENTAL and
  residential population indicators
- [`usastats_query()`](https://public-environmental-data-partners.github.io/EJAM/reference/usastats_query.md)
  : usastats_query - convenient way to see US mean, pctiles of Envt and
  Demog indicators in lookup table
- [`usastats_queryd()`](https://public-environmental-data-partners.github.io/EJAM/reference/usastats_queryd.md)
  : usastats_queryd - convenient way to see US mean, pctiles of
  residential population indicators in lookup table
- [`usastats_querye()`](https://public-environmental-data-partners.github.io/EJAM/reference/usastats_querye.md)
  : usastats_querye - convenient way to see US mean, pctiles of
  ENVIRONMENTAL indicators in lookup table
- [`statestats_means()`](https://public-environmental-data-partners.github.io/EJAM/reference/statestats_means.md)
  : statestats_means - convenient way to see STATE MEANS of
  ENVIRONMENTAL and RESIDENTIAL POPULATION indicators
- [`statestats_query()`](https://public-environmental-data-partners.github.io/EJAM/reference/statestats_query.md)
  : statestats_query - convenient way to see mean, pctiles of Env or
  Demog indicators from lookup table
- [`statestats_queryd()`](https://public-environmental-data-partners.github.io/EJAM/reference/statestats_queryd.md)
  : statestats_queryd - convenient way to see mean, pctiles of DEMOG
  indicators from lookup table
- [`statestats_querye()`](https://public-environmental-data-partners.github.io/EJAM/reference/statestats_querye.md)
  : statestats_querye - convenient way to see mean, pctiles of
  ENVIRONMENTAL indicators from lookup table

### Calculating Summary Stats, etc.

- [`count_sites_with_n_high_scores()`](https://public-environmental-data-partners.github.io/EJAM/reference/count_sites_with_n_high_scores.md)
  : Answers questions like how many sites have certain indicators \>2x
  the state avg?
- [`colcounter()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter.md)
  : Count columns (indicators) with Value (at or) above (or below)
  threshold Counts high scores, by site
- [`colcounter_summary_all()`](https://public-environmental-data-partners.github.io/EJAM/reference/colcounter_summary_all.md)
  : Summarize count (and percent) of rows with exactly (and at least) N
  cols \>= various thresholds
- [`popshare_at_top_n()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_at_top_n.md)
  : top N sites account for what percent of residents?
- [`popshare_at_top_x_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_at_top_x_pct.md)
  : top X percent of sites account for what percent of residents?
- [`popshare_p_lives_at_what_n()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_p_lives_at_what_n.md)
  : how many sites account for P percent of residents?
- [`popshare_p_lives_at_what_pct()`](https://public-environmental-data-partners.github.io/EJAM/reference/popshare_p_lives_at_what_pct.md)
  : what percent of sites is enough to account for (at least) P percent
  of residents? minimum share of sites that can account for at least P%
  of population
- [`distance_trends()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_trends.md)
  : Which indicators fall most as proximity does? (i.e., are higher if
  closer to site) Which variables have strongest trend with distance
  based on slope of linear fit

### Comparing Distances / Multiple Radius Values

- [`ejamit_compare_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances.md)
  : Compare EJAM results overall for more than one radius Run ejamit()
  once per radius, get a summary table with a row per radius
- [`ejamit_compare_distances_fulloutput()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit_compare_distances_fulloutput.md)
  : Compare ejamit() full results for more than one radius Helper used
  by ejamit_compare_distances() to run ejamit() once per radius, get
  FULL ejamit() output list per radius
- [`ejam2barplot_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_distances.md)
  : Barplot comparing ejamit_compare_distances() results for more than
  one radius
- [`distance_by_group_by_site()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_by_group_by_site.md)
  : Ratios at each site, of avg dist of group / avg dist of everyone
  else near site
- [`distance_by_group_plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_by_group_plot.md)
  [`distance_cdf_by_group_plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_by_group_plot.md)
  [`plot_distance_cdf_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_by_group_plot.md)
  : Each groups distribution of distances
- [`plot_distance_mean_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  [`plot_distance_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  [`distance_mean_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  [`distance_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  : Barplot of Average Proximity, by Group
- [`distance_trends()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_trends.md)
  : Which indicators fall most as proximity does? (i.e., are higher if
  closer to site) Which variables have strongest trend with distance
  based on slope of linear fit

## Viewing Results - Deep Dive

### Tables

- [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  : View HTML Report on EJAM Results (Overall or at 1 Site)
- [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
  : Save EJAM results in a spreadsheet
- [`ejam2ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2ratios.md)
  : Quick view of summary stats by type of stat, but lacks rounding
  specific to each type, etc.
- [`ejam2areafeatures()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2areafeatures.md)
  : simple way to see the table of summary stats on special areas and
  features like schools
- [`ejam2means()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2means.md)
  : ejam2means - quick look at averages, via ejamit() results
- [`ejam2tableviewer()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2tableviewer.md)
  : See ejamit()\$results_bysite in interactive table in RStudio viewer
  pane
- [`ejam2table_tall()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2table_tall.md)
  : Simple quick look at results of ejamit() in RStudio console
- [`table_ratios_from_ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_ratios_from_ejamit.md)
  : Quick view of summary stats by type of stat, but lacks rounding
  specific to each type, etc.
- [`table_gt_from_ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_gt_from_ejamit.md)
  : Create a gt-format table of results from EJAM
- [`table_gt_from_ejamit_1site()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_gt_from_ejamit_1site.md)
  : Create a formatted table of results for 1 site from EJAM
- [`table_gt_from_ejamit_overall()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_gt_from_ejamit_overall.md)
  : Create a formatted table of results from EJAM overall summary stats

### Maps of Points

- [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md)
  : Show EJAM results as a map of points
- [`ejam2shapefile()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2shapefile.md)
  : export EJAM results as geojson/zipped shapefile/kml for use in
  ArcPro, EJSCREEN, etc.
- [`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md)
  : Map - points - Create leaflet html widget map of points using table
  with lat lon
- [`mapfastej()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfastej.md)
  : Map - points - Create leaflet html widget map of points using EJAM
  results with EJ stats
- [`map2browser()`](https://public-environmental-data-partners.github.io/EJAM/reference/map2browser.md)
  : quick way to open a map html widget in local browser (saved as
  tempfile you can share)
- [`map_google()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_google.md)
  : Map - Open Google Maps in browser
- [`mapfast_gg()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast_gg.md)
  : Map - points - ggplot2 map of points in the USA - very basic map
- [`plot_blocks_nearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_blocks_nearby.md)
  : plot_blocks_nearby - Map view of Census blocks (their centroids)
  near one or more sites Utility to quickly view one or more facility
  points on map with the blocks found nearby

### Maps of Shapes (Polygons)

- [`mapfastej_counties()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfastej_counties.md)
  : Map - County polygons / boundaries - Create leaflet or static map of
  results of analysis
- [`map_counties_in_state()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_counties_in_state.md)
  : Basic map of county outlines within specified state(s) Not used by
  shiny app
- [`map_shapes_leaflet()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_shapes_leaflet.md)
  : Map - polygons - Create leaflet map from shapefile, in shiny app
- [`map_shapes_mapview()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_shapes_mapview.md)
  : Map - polygons - Use mapview package if available
- [`map_shapes_plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_shapes_plot.md)
  : Map - polygons - Use base R plot() to map polygons
- [`map_blockgroups_over_blocks()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_blockgroups_over_blocks.md)
  : Map - Blockgroup polygons / boundaries near 1 site - Create leaflet
  map
- [`shapes_blockgroups_from_bgfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_blockgroups_from_bgfips.md)
  : Get blockgroups boundaries, via API, to map them

### Map Popups

- [`popup_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/popup_from_any.md)
  :

  Map popups - Simple map popup from a table in
  [data.table](https://r-datatable.com) format or data.frame, one point
  per row

### Plots: Mean of each indicator (comparing populations/groups, comparing environmental factors, etc.)

- [`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md)
  : Barplot of ratios of residential population (or other) scores to
  averages - simpler syntax
- [`ejam2barplot_indicators()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_indicators.md)
  : Create facetted barplots of groups of indicators

### Plots: Mean of one indicator at each site or type of site (comparing sites or categories of sites)

- [`ejam2barplot_sites()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_sites.md)
  : Barplot comparing sites on 1 indicator, based on full output of
  ejamit() easy high-level function for getting a quick look at top few
  sites
- [`plot_barplot_sites()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_sites.md)
  : barplot comparing sites on 1 indicator, based on table of site data
  a quick way to plot a calculated variable at each site, which
  ejam2barplot_sites() can't
- [`plot_lorenz_popcount_by_site()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_lorenz_popcount_by_site.md)
  : lorenz plot bysite (cumulative share of x vs cum share of y) -
  DRAFT/EXPERIMENTAL COMPARES TWO subsets OF SITES (or people??)
- [`ejam2barplot_sitegroups()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_sitegroups.md)
  : Barplot comparing groups of sites on 1 indicator, for output of
  ejamit_compare_types_of_places() easy high-level function for getting
  a quick look at top few groups of sites
- [`plot_barplot_sitegroups()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_sitegroups.md)
  : barplot comparing groups of sites on 1 indicator, based on table of
  grouped site data

### Plots: Mean of each indicator as ratio to average (comparing populations/groups, comparing environmental factors, etc.)

- [`ejam2barplot()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot.md)
  : Barplot of ratios of residential population (or other) scores to
  averages - simpler syntax
- [`ejam2barplot_areafeatures()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_areafeatures.md)
  : barplot of summary stats on special areas and features at the sites
- [`plot_barplot_ratios_ez()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_ratios_ez.md)
  : Helper - Barplot of ratios of indicators (at a site or all sites
  overall) to US or State average
- [`plot_barplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_barplot_ratios.md)
  : helper - Barplot of ratios of residential population percentages (or
  other scores) to averages (or other references)

### Plots: Distribution of one indicator across residents or sites (comparing populations/groups, comparing environmental factors, etc.)

- [`ejam2histogram()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2histogram.md)
  : Histogram of single indicator from EJAM output
- [`ejam2boxplot_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2boxplot_ratios.md)
  : Make boxplot of ratios to US averages
- [`plot_boxplot_pctiles()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_boxplot_pctiles.md)
  : Boxplots comparing a few indicators showing how each varies across
  sites Visualize mean median etc. for each of several percentile
  indicators
- [`plot_ridgeline_ratios_ez()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_ridgeline_ratios_ez.md)
  : Make ridgeline plot of ratios of residential population percentage
  to its average
- [`plot_ridgeline_ratios()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_ridgeline_ratios.md)
  : Make ridgeline plot of ratios of residential population percentage
  to its average

### Plots: Distance(s) for each population/group

- [`ejam2barplot_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_distances.md)
  : Barplot comparing ejamit_compare_distances() results for more than
  one radius

### Plots: Indicator as a function of distance (comparing distances & indicators)

- [`ejam2barplot_distances()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2barplot_distances.md)
  : Barplot comparing ejamit_compare_distances() results for more than
  one radius
- [`plot_distance_by_pctd()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_by_pctd.md)
  : What percentage of this group's population lives less than X miles
  from a site? — \*\*\* DRAFT - NEED TO RECHECK CALCULATIONS
- [`plot_distance_mean_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  [`plot_distance_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  [`distance_mean_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  [`distance_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
  : Barplot of Average Proximity, by Group
- [`distance_by_group_plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_by_group_plot.md)
  [`distance_cdf_by_group_plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_by_group_plot.md)
  [`plot_distance_cdf_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/distance_by_group_plot.md)
  : Each groups distribution of distances
- [`plot_demogshare_by_distance()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_demogshare_by_distance.md)
  : plot_demogshare_by_distance - work in progress
- [`plot_lorenz_distance_by_dcount()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_lorenz_distance_by_dcount.md)
  : lorenz plot bybg_people (cumulative share of x vs cum share of y) -
  DRAFT/EXPERIMENTAL COUNT OF SITES (or PEOPLE?) BY BIN

## Examples of Input & Output Data

### Finding Examples of Inputs/Outputs

- [`testdata()`](https://public-environmental-data-partners.github.io/EJAM/reference/testdata.md)
  : utility to show dir_tree of available files in testdata folders See
  list of samples of input files to try in EJAM, and output examples
  from EJAM functions
- [`testdatafolder()`](https://public-environmental-data-partners.github.io/EJAM/reference/testdatafolder.md)
  : utility to show path to testdata folders see folder that has samples
  of input files to try in EJAM, and output examples from EJAM functions
- [`pkg_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_data.md)
  : UTILITY - DRAFT - See names and size of data sets in installed
  package(s) - internal utility function

### Examples of Inputs (polygons/ shapefiles)

- [`testshapes_2`](https://public-environmental-data-partners.github.io/EJAM/reference/testshapes_2.md)
  : testshapes_2 dataset

### Examples of Inputs (Census units by FIPS)

- [`testinput_fips_mix`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_fips_mix.md)
  : testinput_fips_mix dataset
- [`testinput_fips_states`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_fips_states.md)
  : testinput_fips_states dataset
- [`testinput_fips_counties`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_fips_counties.md)
  : testinput_fips_counties dataset
- [`testinput_fips_cities`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_fips_cities.md)
  : testinput_fips_cities dataset
- [`testinput_fips_tracts`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_fips_tracts.md)
  : testinput_fips_tracts dataset
- [`testinput_fips_blockgroups`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_fips_blockgroups.md)
  : testinput_fips_blockgroups dataset

### Examples of Inputs (Points by lat/lon or address)

- [`testpoints_n()`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_n.md)
  : Random points in USA - average resident, facility, BG, block, or
  square mile
- [`testpoints_5`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_5.md)
  : test points data.frame with columns sitenumber, lat, lon
- [`testpoints_10`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_10.md)
  : test points data.frame with columns sitenumber, lat, lon
- [`testpoints_50`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_50.md)
  : test points data.frame with columns sitenumber, lat, lon
- [`testpoints_100`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_100.md)
  : test points data.frame with columns sitenumber, lat, lon
- [`testpoints_500`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_500.md)
  : test points data.frame with columns sitenumber, lat, lon
- [`testpoints_1000`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_1000.md)
  : test points data.frame with columns sitenumber, lat, lon
- [`testpoints_10000`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_10000.md)
  : test points data.frame with columns sitenumber, lat, lon
- [`testinput_address_table`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_address_table.md)
  : datasets for trying address-related functions

### Examples of Inputs (Points by regulated facility)

- [`testinput_registry_id`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_registry_id.md)
  : test data, EPA Facility Registry ID numbers to try using
- [`testinput_program_sys_id`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_program_sys_id.md)
  : test data, EPA program names and program system ID numbers to try
  using
- [`testinput_program_name`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_program_name.md)
  : testinput_program_name dataset
- [`testinput_naics`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_naics.md)
  : testinput_naics dataset
- [`testinput_sic`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_sic.md)
  : testinput_sic dataset
- [`testinput_mact`](https://public-environmental-data-partners.github.io/EJAM/reference/testinput_mact.md)
  : testinput_mact dataset

### Examples of Outputs

- [`testoutput_ejamit_10pts_1miles`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_ejamit_10pts_1miles.md)
  : test output of ejamit()
- [`testoutput_ejamit_100pts_1miles`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_ejamit_100pts_1miles.md)
  : test output of ejamit()
- [`testoutput_ejamit_1000pts_1miles`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_ejamit_1000pts_1miles.md)
  : test output of ejamit()
- [`testoutput_ejamit_shapes_2`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_ejamit_shapes_2.md)
  : testoutput_ejamit_shapes_2 dataset
- [`testoutput_ejamit_fips_cities`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_ejamit_fips_cities.md)
  : testoutput_ejamit_fips_cities dataset
- [`testoutput_ejamit_fips_counties`](https://public-environmental-data-partners.github.io/EJAM/reference/testoutput_ejamit_fips_counties.md)
  : testoutput_ejamit_fips_counties dataset

## Utilities providing URL or API info

- [`ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi.md)
  : Get EJScreen community report or data via the EJAM API
- [`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
  : Get URL(s) of HTML summary reports for use with EJAM-API
- [`url_ejscreenmap()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreenmap.md)
  : Get URL(s) for (new) EJSCREEN app with map centered at given
  point(s)
- [`url_enviromapper()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_enviromapper.md)
  : Get URLs of EnviroMapper reports
- [`url_echo_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_echo_facility.md)
  : Get URLs of ECHO reports
- [`url_frs_facility()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_frs_facility.md)
  : Get URLs of FRS reports
- [`url_county_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_health.md)
  : URL functions - Get URLs of useful report(s) on Counties containing
  the given fips, from countyhealthrankings.org
- [`url_state_health()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_health.md)
  : URL functions - Get URLs of useful report(s) on STATES containing
  the given fips, from countyhealthrankings.org
- [`url_county_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_county_equityatlas.md)
  : URL functions - Get URLs of useful report(s) on County containing
  the given fips from nationalequityatlas.org
- [`url_state_equityatlas()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_state_equityatlas.md)
  : URL functions - Get URLs of useful report(s) on STATE containing the
  given fips, from equity atlas
- [`url_naics.com()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_naics.com.md)
  : URL functions - url_naics.com - Get URL for page with info about
  industry sectors by text query term
- [`url_ejscreentechdoc()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejscreentechdoc.md)
  : utility to get URL of .pdf of EJSCREEN Technical Documentation

## Utilities handling variable names

Utilities to handle variable names, indicator metadata, formulas, etc.

- [`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
  : helper function to rename variables that are colnames of data.frame
- [`names_d`](https://public-environmental-data-partners.github.io/EJAM/reference/names_d.md)
  : a list of variable names for internal use in EJAM
- [`names_e`](https://public-environmental-data-partners.github.io/EJAM/reference/names_e.md)
  : a list of variable names for internal use in EJAM
- [`map_headernames`](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
  : map_headernames provides metadata about all indicators in EJSCREEN /
  EJAM
