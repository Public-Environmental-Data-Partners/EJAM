# Updating EJAM Datasets

The EJAM package and Shiny app make use of many data objects, including
numerous datasets stored in the package’s /data/ folder as well as
several large tables stored in a separate repository specifically
created for holding those large tables, which contain information on
Census blockgroups, Census block internal points, Census block
population weights, and EPA FRS facilities.

## How to Update Datasets in EJAM

The process begins from within the EJAM code repo, using the various
`datacreate_*` scripts to create updated arrow datasets. Notes and
scripts are consolidated in the /data-raw/ folder, and the starting
point is the overarching set of scripts and comments in the file called
*`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`*. Almost all updates of
data objects and their documentation are organized within that file in
functions/scripts for the various datasets. Documentation of datasets
via `EJAM/R/data_*.R` files is generally handled by those same scripts
while creating/updating the datasets.

That file covers not only the large arrow datasets that are stored in a
separate repository, but also many smaller data objects that are
installed along with the package in the /data/ folder. Updating all the
package’s data objects can be complicated because there are many
different data objects of various types and formats and locations.

The various data objects need to be updated at various frequencies –
some only yearly (ACS data) and others when facility IDs and locations
change (as often as possible, as when [EPA’s
FRS](https://www.epa.gov/frs) is updated). Some need to be updated only
when the package features/code changes, such as the important data
object called `map_headernames` (which in turn is used to update objects
such as `names_e`).

See the draft utility `EJAM:::pkg_data()` for a view of datasets if
useful:

``` r
x <- EJAM:::pkg_data()
```

    ## Get more info with pkg_data(simple = FALSE)
    ## 
    ## ignoring sortbysize because simple=TRUE

``` r
x$Item[!grepl("names_|^test", x$Item)]
```

    ##  [1] "NAICS"                            "SIC"                             
    ##  [3] "avg.in.us"                        "bg_cenpop2020"                   
    ##  [5] "bgpts"                            "blockgroupstats"                 
    ##  [7] "censusplaces"                     "custom"                          
    ##  [9] "ejamdata_version"                 "ejampackages"                    
    ## [11] "epa_programs"                     "epa_programs_defined"            
    ## [13] "formulas_all"                     "formulas_d"                      
    ## [15] "formulas_ejscreen_acs"            "formulas_ejscreen_acs_disability"
    ## [17] "formulas_ejscreen_demog_index"    "frsprogramcodes"                 
    ## [19] "high_pctiles_tied_with_min"       "islandareas"                     
    ## [21] "lat_alias"                        "lon_alias"                       
    ## [23] "mact_table"                       "map_headernames"                 
    ## [25] "meters_per_mile"                  "modelDoaggregate"                
    ## [27] "modelEjamit"                      "naics_counts"                    
    ## [29] "naicstable"                       "namez"                           
    ## [31] "sictable"                         "stateinfo"                       
    ## [33] "stateinfo2"                       "states_shapefile"                
    ## [35] "statestats"                       "tables_ejscreen_acs"             
    ## [37] "usastats"                         "x_anyother"

### Where the datasets are stored

EJAM relies on datasets mostly stored in the package itself or in a
separate, data-related repository:

- Datasets stored within the EJAM package (.rda files):
  [Documentation](https://public-environmental-data-partners.github.io/EJAM/reference/index.html#datasets-with-indicators-raw-data-means-percentiles-)
  and [access to package data
  files](https://github.com/Public-Environmental-Data-Partners/EJAM/tree/main/data)

- Datasets used by EJAM but stored separately (large .arrow files):
  [Documentation](https://public-environmental-data-partners.github.io/EJAM/reference/index.html#datasets-with-indicators-raw-data-means-percentiles-)
  and [access to the large data
  files](https://github.com/Public-Environmental-Data-Partners/ejamdata/tree/main/data)

### Key datasets

Some notable data files, code details, and other objects that may need
to be changed ANNUALLY or more often:

- ***Blockgroup Datasets (Demographic and Environmental data)***: These
  include datasets included with the package
  [`?blockgroupstats`](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md),
  [usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md),
  [`?statestats`](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md),
  etc.) as well as larger tables stored in a separate repository and
  downloaded by the EJAM package
  ([`?bgpts`](https://public-environmental-data-partners.github.io/EJAM/reference/bgpts.md),
  [`?bgej`](https://public-environmental-data-partners.github.io/EJAM/reference/bgej.md),
  [`?bgid2fips`](https://public-environmental-data-partners.github.io/EJAM/reference/bgid2fips.md),
  [`?bg_cenpop2020`](https://public-environmental-data-partners.github.io/EJAM/reference/bg_cenpop2020.md),
  etc.). They are all created or modified using scripts/functions
  organized from within
  *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`*.

  - NOTE: Prior to 2025, several key datasets used by EJAM were obtained
    from EPA’s EJSCREEN data FTP site and others directly from relevant
    staff. Many of the indicators on the Community Report for the v2.2
    (early 2024) EJSCREEN data were NOT provided in the gdb and csv
    files on the FTP site, so they had to be obtained directly from the
    EJSCREEN team as a separate .csv file. The code referred to from
    *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`* assumes the basic
    datasets from EPA are available, and then converts them into the
    datasets actually used by EJAM. However, if those are no longer
    available from those sources, the data could mostly be independently
    recreated, but this would require a combination of existing code and
    significant new work.

  - Some relevant code was in archived EJSCREEN repositories, for
    creating environmental datasets. Some code is in EJAM functions that
    can get ACS datasets. Much relevant code was in an older non-EPA
    package called ejscreen, which had been made private as of early
    2025 but could be refreshed. That package had tools such as
    ejscreen.create() that had been able to reproduce parts of the
    blockgroupstats and usastats/statestats datasets.

- ***Block Datasets***: The *block* (not blockgroup) tables might be
  updated less often, but Census fips codes do change yearly so the
  [`?blockwts`](https://public-environmental-data-partners.github.io/EJAM/reference/blockwts.md),
  [`?blockpoints`](https://public-environmental-data-partners.github.io/EJAM/reference/blockpoints.md),
  [`?quaddata`](https://public-environmental-data-partners.github.io/EJAM/reference/quaddata.md),
  [`?blockid2fips`](https://public-environmental-data-partners.github.io/EJAM/reference/blockid2fips.md),
  and related additional data.tables should be updated as needed. This
  is also done from within
  *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`* See package
  `census2020download` on github for the function
  `census2020_get_data()` that may be useful.

- ***Facilities Datasets for creating updated proximity scores each
  year***: Facility (and roadway) locations for key types of sites were
  used once a year to calculate updated several [environmental
  indicators (proximity scores) in
  EJSCREEN](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#environmental-burden-indicators).
  The resulting environmental indicators are stored with EJAM, but these
  facility location datasets are not stored in EJAM. EJSCREEN obtains
  their locations for mapping purposes, via an API accessing [hosted
  datasets with facility
  locations](https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer).
  In general, scripts for updating environmental indicators (including
  documentation of sources of facility location data, etc.) [were stored
  by
  EPA](https://github.com/Public-Environmental-Data-Partners/EJSCREEN-Data-Processing),
  and after 2025 new code for updating indicators may be found in the
  non-EPA source package EJAM/data-raw folder. Proximity scores in
  EJSCREEN as of 2024-2026 were calculated based on the locations of
  these types of sites:

  - [Major roadways
    (traffic)](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#traffic-proximity-and-volume)
  - [Superfund NPL
    sites](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#environmental-burden-indicators)
  - [Facilities with hazardous waste
    (TSDF)](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#hazardous-waste-proximity)
  - [Water bodies downstream of wastewater
    discharges](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#wastewater-discharge-stream-proximity-and-toxic-concentration)
  - [Risk management plan (RMP)
    facilities](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#risk-management-program-rmp-facility-proximity)
  - [Underground storage tanks
    (UST)](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#underground-storage-tanks-ust)
    (for a facility density indicator, similar to a proximity
    indicator).

- ***Facilities Datasets for a user to specify places to analyze/report
  on***: Facility locations and categories are used in EJAM to help a
  user specify sets of EPA-regulated facilities or other types of sites
  to analyze and report on in EJSCREEN reports, using their
  *NAICS/SIC/MACT/program* information and coordinates. All of that
  information may need frequent updates, ideally, since facilities open,
  close, relocate, or have their information corrected or otherwise
  updated. EPA’s FRS is the source for much of this information and the
  FRS is updated by EPA frequently and is available via an API. Through
  at least v2.32.8, EJAM (and therefore the community reports in
  EJSCREEN) used a snapshot of the EPA FRS data rather than using an API
  to obtain the latest info on demand – that is something that could be
  changed in a future version. Facility-related info is stored in tables
  EJAM uses, such as these:
  [`?frs`](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md),
  [`?frs_by_programid`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_programid.md),
  [`?frs_by_naics`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_naics.md),
  [`?frs_by_sic`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_sic.md),
  and
  [`?frs_by_mact`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_mact.md),
  [`?NAICS`](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md),
  [`?SIC`](https://public-environmental-data-partners.github.io/EJAM/reference/SIC.md),
  [`?naics_counts`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_counts.md),
  [`?naicstable`](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md),
  [`?SIC`](https://public-environmental-data-partners.github.io/EJAM/reference/SIC.md),
  [`?sictable`](https://public-environmental-data-partners.github.io/EJAM/reference/sictable.md),
  [`?mact_table`](https://public-environmental-data-partners.github.io/EJAM/reference/mact_table.md),
  and
  [`?epa_programs`](https://public-environmental-data-partners.github.io/EJAM/reference/epa_programs.md),
  [`?frsprogramcodes`](https://public-environmental-data-partners.github.io/EJAM/reference/frsprogramcodes.md),
  etc. These FRS, MACT, and Program info tables of EPA-relevant data are
  updated in the EJAM package from within
  *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`* The
  [`?NAICS`](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md),
  [`?naicstable`](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md),
  and
  [`?sictable`](https://public-environmental-data-partners.github.io/EJAM/reference/sictable.md)
  objects (viewable using
  [`naics_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_categories.md)
  and
  [`sic_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_categories.md)
  utilities) have no EPA-specific data so they do not need frequent
  updates – The NAICS data object stores just the name of each NAICS
  code number, and new codes/names are published every five years, such
  as in 2017 and 2022, so a new version would typically be expected
  in 2027. The tables called
  [`?SIC`](https://public-environmental-data-partners.github.io/EJAM/reference/SIC.md)
  (unlike the NAICS table) and
  [`?naics_counts`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_counts.md)
  (which has no analogous sic version), however, contain counts of EPA
  FRS facilities, so they need updates when FRS data are updated. The
  inconsistency in how NAICS vs SIC tables and the naics_counts table
  were named and defined was by historical accident, not intentional, so
  it would be OK if refactoring later made them consistent or even
  switched entirely to more frequent automated updates or even reliance
  on the FRS API.

- [`?map_headernames`](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
  and associated .xlsx, etc. store critical metadata. This needs to
  updated especially if indicator names change or are added, for
  example.
  [`?map_headernames`](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
  holds most of the useful metadata about each variable (each indicator,
  like %low income) – e.g., how many digits to use in rounding, units, a
  long name of indicator, the type or category of indicator, sort order
  to use in reports, method of calculating aggregations of the indicator
  over blockgroups, etc. This is modified directly in the spreadsheet at
  data-raw/map_headernames\_\_\_\_.xlsx (renamed for each package
  version), and then functions or scripts read that .xlsx to create the
  map_headernames dataset. See
  *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`*

- [Test data (inputs) and examples of
  outputs](https://public-environmental-data-partners.github.io/EJAM/articles/testdata.Rmd)
  may have to be updated (every time parameters change & when outputs
  returned change). Those are generated by scripts/functions referred to
  from *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`*

- A default year is used in various functions, such as for the last year
  of the 5-year ACS dataset. These defaults like yr or year should be
  updated via global searches where relevant.

- metadata about vintage/ version is in attributes of most datasets.
  That is updated via scripts/functions used by
  *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`* via for example the
  helpers
  [`metadata_add()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_add.md)
  and
  [`metadata_check()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_check.md)
  and `metadata_mapping.R`

- Version numbering is recorded in the DESCRIPTION file primarily, and
  note use of the `ejamdata_version.txt` file, and tags on releases, and
  the NEWS file.

- [Updating
  documentation](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-documentation.md) -
  updates may be needed for the README, vignettes, and possibly examples
  in some functions in case updates to datasets alter how the examples
  would work.

Again, all of those updates should be done starting from an
understanding of the file called
`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`. That script includes
steps to update metadata and documentation and save new versions of data
in the data folder if appropriate.

The information below focuses on the other type of data objects – the
set of large [arrow](https://github.com/apache/arrow/) files that are
stored outside the package code repository.

### Repository that stores the large arrow files

Several large [data.table](https://r-datatable.com) files are not
installed as part of the R package in the typical /data/ folder that
contains .rda files lazyloaded by the package. Instead, they are kept in
a separate github repository that we refer to here as the data
repository.

*IMPORTANT:* The name of the *data* repository (as distinct from the
*package code* repository) must be recorded/ updated in the EJAM package
DESCRIPTION file, so that the package will know where to look for the
data files if the datasets were moved to a new repository, for example.
The current (either installed or loaded source version) of that
repository is
<https://github.com/Public-Environmental-Data-Partners/ejamdata> (which
can be checked via `url_package(type = "data", get_full_url = TRUE)`)

### arrow package and arrow file format

To store the large files needed by the EJAM package, we use the Apache
arrow file format through the [arrow](https://github.com/apache/arrow/)
R package, with file extension `.arrow`. This allows us to work with
larger-than-memory data and store it outside of the EJAM package itself.

Earlier version of EJAM did not use the actual arrow format, so there
still may be places in the code that simply use the xyz.arrow filename
but not the actual arrow format that is faster, and those would ideally
get updated. For example the object called `frs_arrow` is the faster
format of what had been called the
[`?frs`](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md)
dataset.

The names of these tables should be listed in a file called
`R/arrow_ds_names.R` and the global variable called .arrow_ds_names that
is used by functions like
[`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
and
[`dataload_from_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_from_local.md).

As of EJAM version v2.32.8, there were 11 arrow files used by EJAM:

### Blockgroup and block-level arrow files

- [`?bgid2fips`](https://public-environmental-data-partners.github.io/EJAM/reference/bgid2fips.md).arrow:
  crosswalk of EJAM blockgroup IDs (1-n) with 12-digit blockgroup FIPS
  codes
- [`?blockid2fips`](https://public-environmental-data-partners.github.io/EJAM/reference/blockid2fips.md).arrow:
  crosswalk of EJAM block IDs (1-n) with 15-digit block FIPS codes
- [`?blockpoints`](https://public-environmental-data-partners.github.io/EJAM/reference/blockpoints.md).arrow:
  Census block internal points lat-lon coordinates, EJAM block ID
- [`?blockwts`](https://public-environmental-data-partners.github.io/EJAM/reference/blockwts.md).arrow:
  Census block population weight as share of blockgroup population, EJAM
  block and blockgroup ID
- [`?bgej`](https://public-environmental-data-partners.github.io/EJAM/reference/bgej.md).arrow:
  blockgroup-level statistics of EJ variables
- [`?quaddata`](https://public-environmental-data-partners.github.io/EJAM/reference/quaddata.md).arrow:
  3D spherical coordinates of Census block internal points, with EJAM
  block ID

### FRS/facility-related arrow files

- [`?frs`](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md).arrow:
  data.table of EPA Facility Registry Service (FRS) regulated sites
- [`?frs_by_naics`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_naics.md).arrow:
  data.table of NAICS industry code(s) for each EPA-regulated site in
  Facility Registry Service
- [`?frs_by_sic`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_sic.md).arrow:
  data.table of SIC industry code(s) for each EPA-regulated site in
  Facility Registry Service
- `?frs_by_programid.arrow`: data.table of Program System ID code(s) for
  each EPA-regulated site in the Facility Registry Service
- [`?frs_by_mact`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_mact.md).arrow:
  data.table of [MACT
  NESHAP](https://en.wikipedia.org/wiki/National_Emissions_Standards_for_Hazardous_Air_Pollutants)
  codes for sites, indicating the [subpart(s) that categorize relevant
  EPA-regulated
  sites](https://www.epa.gov/stationary-sources-air-pollution/national-emission-standards-hazardous-air-pollutants-neshap-8)

## Development/Setup

1.  The arrow files are stored in a separate, public, Git-LFS-enabled
    GitHub repo (henceforth ‘ejamdata’). The owner/reponame must be
    recorded/updated in the DESCRIPTION file field called ejam_data_repo
    (which can be checked via
    `url_package(type = "data", get_full_url = TRUE)`) – that info is
    used by the package.

2.  Then, and any time the arrow datasets are updated, we update the
    ejamdata release version via the `.github/push_to_ejam.yaml`
    workflow in the ejamdata repo, thereby saving the arrow files with
    the release, to be downloaded automatically by EJAM

3.  EJAM’s
    [`download_latest_arrow_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_latest_arrow_data.md)
    function does the following:

&nbsp;

1.  Checks ejamdata repo’s latest release/version.
2.  Checks user’s EJAM package’s ejamdata version, which is stored in
    `data/ejamdata_version.txt`.
3.  If the `data/ejamdata_version.txt` file doesn’t exist, e.g. if it’s
    the first time installing EJAM, it will be created at the end of the
    script.
4.  If the versions are different, download the latest arrow from the
    latest ejamdata release with
    [`piggyback::pb_download()`](https://docs.ropensci.org/piggyback/reference/pb_download.html).
    see how this function works for details:

``` r
download_latest_arrow_data()
```

4.  We add a call to this function in the onAttach script (via the
    [`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
    function) so it runs and ensures the latest arrow files are
    downloaded when user loads EJAM.

## How it Works for the User

1.  User installs EJAM

- `devtools::install_github("Public-Environmental-Data-Partners/EJAM")`
  (or as adjusted depending on the actual repository owner and name)

2.  User loads EJAM as usual

- [`library(EJAM)`](https://public-environmental-data-partners.github.io/EJAM).
  This will trigger the new
  [`download_latest_arrow_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_latest_arrow_data.md)
  function.

3.  User runs EJAM as usual

- The
  [`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
  function will work as usual because the data are now stored in the
  `data` directory.

## How new versions of arrow datasets are republished/ released

1.  The key arrow files are updated from within the EJAM code
    repository, as explained above.

2.  Those files were then being copied into a clone of the ejamdata repo
    before being pushed to the actual ejamdata repo on github (at
    <https://github.com/Public-Environmental-Data-Partners/ejamdata>)

3.  This triggers ejamdata’s `push_to_ejam.yaml` workflow that
    increments the latest release tag reflecting the new version and
    creates a new release

## Potential Improvements

### Making Code more Arrow-Friendly

Problem: loading the data as tibbles/dataframes takes a long time

Solution: We may be able to modify our code to be more arrow -friendly.
This essentially keeps the analysis code as a sort of query, and only
actually loads the results into memory when requested (e.g., via
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html))
This dramatically reduces used memory, which would speed up processing
times and avoid potential crashes resulting from not enough memory.
However, this would require a decent lift to update the code in all
places

Pros: processing efficiency, significantly reduced memory usage

Implementation: This has been mostly implemented by the
[`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
function, which contains a `return_data_table` parameter. If `FALSE`,
the arrow file is loaded as an .arrow dataset, rather than a
tibble/dataframe.
