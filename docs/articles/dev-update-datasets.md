# Updating and Managing the Datasets Used by EJAM

The EJAM package and [Shiny](https://shiny.posit.co) app use many data
objects, including numerous datasets stored in the package’s `/data/`
folder and several large tables stored in a separate data repository.
Those large tables contain information on Census block groups, Census
block internal points, Census block population weights, and EPA FRS
facilities.

## How to Update Datasets in EJAM

The process begins from within the EJAM code repo. Historically, most
data updates were coordinated from the overarching notes and script file
`data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`. That file is still useful
as an index of older maintainer workflows, but it is no longer the
primary path for the annual EJScreen-style blockgroup update. For
`blockgroupstats`, `usastats`, `statestats`, `bgej`, and related annual
pipeline checkpoints, use the staged pipeline documented in [Updating
EJScreen Datasets Annually (via the
Pipeline)](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-ejscreen-datasets-yearly.md).
For other datasets, the focused `datacreate_*` scripts in `data-raw/`
remain the usual starting point. Documentation of datasets via
`/R/data_*.R` files is generally handled by those same scripts while
creating/updating the datasets.

That file covers not only the large Arrow datasets that are stored in a
separate repository, but also many smaller data objects that are
installed along with the package in the `/data/` folder. Updating all
the package’s data objects can be complicated because there are many
different data objects of various types and formats and locations.

The various data objects need to be updated at various frequencies –
some only yearly, some as part of the broader EJSCREEN Annual Data
Update of demographic, environmental, and other indicators, and others
when facility IDs and locations change (as often as possible, as when
[EPA’s FRS](https://www.epa.gov/frs) is updated). Some need to be
updated only when the package features/code changes, such as the
important data object called `map_headernames` (which in turn is used to
update objects such as `names_e`).

See the draft utility `EJAM:::pkg_data()` for a dataset inventory:

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
    ## [11] "ejscreen_arcgis_service_field"    "ejscreen_schema_extra"           
    ## [13] "epa_programs"                     "epa_programs_defined"            
    ## [15] "formulas_ejscreen_acs"            "formulas_ejscreen_acs_disability"
    ## [17] "formulas_ejscreen_demog_index"    "frsprogramcodes"                 
    ## [19] "high_pctiles_tied_with_min"       "islandareas"                     
    ## [21] "lat_alias"                        "lon_alias"                       
    ## [23] "mact_table"                       "map_headernames"                 
    ## [25] "meters_per_mile"                  "modelDoaggregate"                
    ## [27] "modelEjamit"                      "modelEjamitByAnalysisType"       
    ## [29] "naics_counts"                     "naicstable"                      
    ## [31] "namez"                            "sictable"                        
    ## [33] "stateinfo"                        "stateinfo2"                      
    ## [35] "states_shapefile"                 "statestats"                      
    ## [37] "tables_ejscreen_acs"              "usastats"                        
    ## [39] "x_anyother"

### Where the datasets are stored

EJAM relies on datasets mostly stored in the package itself or in a
separate, data-related repository:

- Datasets stored within the EJAM package (`.rda` files):
  [Documentation](https://public-environmental-data-partners.github.io/EJAM/reference/index.html#datasets-with-indicators-raw-data-means-percentiles-)
  and [access to package data
  files](https://github.com/Public-Environmental-Data-Partners/EJAM/tree/main/data)

- Datasets used by EJAM but stored separately (large `.arrow` files):
  [Documentation](https://public-environmental-data-partners.github.io/EJAM/reference/index.html#datasets-with-indicators-raw-data-means-percentiles-)
  and [access to the large data files as GitHub release
  assets](https://github.com/Public-Environmental-Data-Partners/ejamdata/releases)

### Why the large datasets are put into the data repository using piggyback instead of committed using Git

As explained in the documentation for the [piggyback R
package](https://docs.ropensci.org/piggyback/):

“Because larger (\> 50 MB) data files cannot easily be committed to git,
a different approach is required to manage data associated with an
analysis in a GitHub repository. This package provides a simple
work-around by allowing larger (up to 2 GB) data files to piggyback on a
repository as assets attached to individual GitHub releases. These files
are not handled by git in any way, but instead are uploaded, downloaded,
or edited directly by calls through the GitHub API. These data files can
be versioned manually by creating different releases. This approach
works equally well with public or private repositories. Data can be
uploaded and downloaded programmatically from scripts. No authentication
is required to download data from public repositories.”

### Key datasets

Some notable data files, code details, and other objects that may need
to be changed ANNUALLY or more often:

- ***Blockgroup Datasets (Demographic and Environmental Data)***: These
  include datasets included with the package
  [`?blockgroupstats`](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md),
  [usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md),
  [`?statestats`](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md),
  and
  [`?bgej`](https://public-environmental-data-partners.github.io/EJAM/reference/bgej.md).
  The annual staged workflow for updating these ACS/EJScreen-style
  blockgroup datasets is now documented separately in [Updating EJScreen
  Datasets Annually (via the
  Pipeline)](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-ejscreen-datasets-yearly.md).
  That pipeline covers `bg_acs_raw`, `bg_acsdata`, optional Island Areas
  checkpoints, `bg_envirodata`, `bg_extra_indicators`, `bg_geodata`,
  `blockgroupstats`, `bgej`, `usastats`, `statestats`,
  `ejscreen_export`, and the optional `ejscreen_dataset_creator_input`
  stage. This more general vignette focuses on the other datasets and
  storage/release mechanics used by EJAM.

- ***Block Datasets***: The *block* (not blockgroup) tables might be
  updated less often, but Census FIPS codes do change yearly so the
  [`?blockwts`](https://public-environmental-data-partners.github.io/EJAM/reference/blockwts.md),
  [`?blockpoints`](https://public-environmental-data-partners.github.io/EJAM/reference/blockpoints.md),
  [`?quaddata`](https://public-environmental-data-partners.github.io/EJAM/reference/quaddata.md),
  [`?blockid2fips`](https://public-environmental-data-partners.github.io/EJAM/reference/blockid2fips.md),
  and related additional data tables should be updated as needed. This
  is also done from within
  *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`*. See the
  `census2020download` package on GitHub for the function
  `census2020_get_data()` that may be useful.

- ***Facilities Datasets for creating updated proximity scores each
  year***: Facility (and roadway) locations for key types of sites were
  used once a year to update several [environmental indicators that are
  proximity scores in
  EJSCREEN](https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen-map-descriptions.html#environmental-burden-indicators).
  The resulting environmental indicators are stored with EJAM, but these
  facility location datasets are not stored in EJAM. EJSCREEN obtains
  their locations for mapping purposes, via an API accessing [hosted
  datasets with facility
  locations](https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer).
  In general, scripts for updating environmental indicators (including
  documentation of sources of facility location data, etc.) [were stored
  by
  EPA](https://github.com/Public-Environmental-Data-Partners/EJSCREEN-Data-Processing).
  After 2025, new code for updating indicators may be found in this
  package’s `data-raw/` folder or in related non-EPA source
  repositories. Proximity scores in EJSCREEN as of 2024-2026 were
  calculated based on the locations of these types of sites:

- [Major roadways
  (traffic)](https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen-map-descriptions.html#traffic-proximity-and-volume)

- [Superfund NPL
  sites](https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen-map-descriptions.html#environmental-burden-indicators)

- [Facilities with hazardous waste
  (TSDF)](https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen-map-descriptions.html#hazardous-waste-proximity)

- [Water bodies downstream of wastewater
  discharges](https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen-map-descriptions.html#wastewater-discharge-stream-proximity-and-toxic-concentration)

- [Risk management plan (RMP)
  facilities](https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen-map-descriptions.html#risk-management-program-rmp-facility-proximity)

- [Underground storage tanks
  (UST)](https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen-map-descriptions.html#underground-storage-tanks-ust)
  (for a facility density indicator, similar to a proximity indicator)

- ***Facilities Datasets for a user to specify places to analyze/report
  on***:

Facility locations and categories are used in EJAM to help a user
specify sets of EPA-regulated facilities or other types of sites to
analyze and report on in EJSCREEN reports, using their
*NAICS/SIC/MACT/program* information and coordinates. All of that
information may need frequent updates because facilities open, close,
relocate, or have their information corrected or otherwise updated.
EPA’s FRS is the source for much of this information and the FRS is
updated by EPA frequently and is available via an API. Through at least
v2.32.8, EJAM (and therefore the community reports in EJSCREEN) used a
snapshot of the EPA FRS data rather than using an API to obtain the
latest info on demand – that is something that could be changed in a
future version. Facility-related info is stored in tables EJAM uses,
such as these:
[`?frs`](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md),
[`?frs_by_programid`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_programid.md),
[`?frs_by_naics`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_naics.md),
[`?frs_by_sic`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_sic.md),
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
etc. These FRS, MACT, and Program info tables of EPA-relevant data have
been updated in the EJAM package from scripts within
*`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`*. The
[`?NAICS`](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md),
[`?naicstable`](https://public-environmental-data-partners.github.io/EJAM/reference/naicstable.md),
and
[`?sictable`](https://public-environmental-data-partners.github.io/EJAM/reference/sictable.md)
objects (viewable using
[`naics_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_categories.md)
and
[`sic_categories()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_categories.md)
utilities) have no EPA-specific data so they do not need frequent
updates. The NAICS data object stores just the name of each NAICS code
number, and new codes/names are published every five years, such as in
2017 and 2022, so a new version would typically be expected in 2027. The
tables called
[`?SIC`](https://public-environmental-data-partners.github.io/EJAM/reference/SIC.md)
(unlike the NAICS table) and
[`?naics_counts`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_counts.md)
(which has no analogous sic version), however, contain counts of EPA FRS
facilities, so they need updates when FRS data are updated. The
inconsistency in how NAICS vs SIC tables and the naics_counts table were
named and defined was by historical accident, not intentional, so it
would be OK if refactoring later made them consistent or even switched
entirely to more frequent automated updates or even reliance on the FRS
API.

- [`?map_headernames`](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
  stores critical metadata. This needs to be updated especially if
  indicator names change or are added.
  [`?map_headernames`](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md)
  holds most of the useful metadata about each variable (each indicator,
  like % low income) – e.g., how many digits to use in rounding, units,
  long and short indicator names, EJAM and EJScreen field names, the
  type or category of indicator, sort order to use in reports, and the
  method of calculating aggregations of the indicator over blockgroups.
  The editable source is now `data-raw/map_headernames.csv`. If metadata
  rows or values need to change, edit that CSV directly, then source
  `data-raw/datacreate_map_headernames.R` to validate the CSV and save
  `data/map_headernames.rda`. Older `.xlsx` workflows are obsolete and
  should not be used to regenerate this object.

- [Test data (inputs) and examples of
  outputs](https://public-environmental-data-partners.github.io/EJAM/articles/testdata.Rmd)
  may have to be updated (every time parameters change & when outputs
  returned change). Those are generated by scripts/functions referred to
  from *`/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`*

- A default year is used in various functions, such as for the last year
  of the 5-year ACS dataset. These defaults like yr or year should be
  updated via global searches where relevant.

- Metadata about vintage/version is stored in attributes of many
  datasets. That metadata is updated via scripts/functions that call
  helpers such as
  [`metadata_add()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_add.md),
  [`metadata_add_and_use_this()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_add_and_use_this.md),
  [`metadata_check()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_check.md),
  and `metadata_mapping.R`. For staged EJScreen annual outputs, the
  pipeline save helpers add the relevant metadata based on the requested
  pipeline year. After package data are replaced, run
  `EJAM:::metadata_check()` and `EJAM:::metadata_check_print()` to find
  stale attributes. Atomic name-vector objects such as many `names_*`
  datasets do not need metadata attributes.

- Version numbering is recorded primarily in the DESCRIPTION file,
  release tags, and the NEWS file. The `ejamdata_required_tag` field in
  DESCRIPTION records which `ejamdata` release EJAM should use. The
  `ejamdata_version.txt` marker records which `ejamdata` release tag is
  actually saved in the local data folder.

- [Updating
  documentation](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-documentation.md) -
  updates may be needed for the README, vignettes, and possibly examples
  in some functions in case updates to datasets alter how the examples
  would work.

Again, for non-pipeline datasets it is useful to understand
`data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`, because that script still
points to many older focused data-creation scripts. For annual
EJScreen-style blockgroup outputs, use the pipeline vignette and runner
script as the current maintainer workflow.

The information below focuses on the other type of data objects – the
set of large [arrow](https://github.com/apache/arrow/) files that are
stored outside the package code repository.

### Repository that stores the large arrow file release assets

Several large [data.table](https://r-datatable.com) files are not
installed as part of the R package in the typical `/data/` folder that
contains `.rda` files lazy-loaded by the package. Instead, they are kept
as release assets in a separate GitHub repository that we refer to here
as the data repository. The release assets are the authoritative copies
used by installed EJAM packages; committed files in a repository `data/`
folder should not be treated as the source used by EJAM installs.

*IMPORTANT:* The name of the *data* repository (as distinct from the
*package code* repository) must be recorded/updated in the EJAM package
`DESCRIPTION` file, so that the package knows where to look for the data
files if the datasets are moved to a new repository. The current data
repository for the installed or loaded source version is
<https://github.com/Public-Environmental-Data-Partners/ejamdata>, which
can be checked with `url_package(type = "data", get_full_url = TRUE)`.

### Arrow Package and Arrow File Format

To store the large files needed by the EJAM package, we use the Apache
arrow file format through the [arrow](https://github.com/apache/arrow/)
R package, with file extension `.arrow`. This allows us to work with
larger-than-memory data and store it outside of the EJAM package itself.

Earlier versions of EJAM used the `.arrow` filename more loosely.
Current dynamic datasets should be real Arrow IPC files. For example,
the object called `frs_arrow` is the Arrow-backed version of what had
been called the
[`?frs`](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md)
dataset.

The names of these tables should be listed in `R/arrow_ds_names.R` and
in the global variable called `.arrow_ds_names`, which is used by
functions like
[`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
and
[`dataload_from_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_from_local.md).

These are the Arrow files used by EJAM:

### Arrow file update groups

Arrow files do not all change on the same schedule. Use these groups
when planning updates:

1.  **Facility Data Updates** include `frs`, `frs_by_programid`,
    `frs_by_naics`, `frs_by_sic`, and `frs_by_mact`. These may be
    refreshed when EPA FRS/facility data are updated.

2.  **EJSCREEN Annual Data Update** currently includes `bgej.arrow`. It
    is calculated from the annual EJScreen/EJAM demographic and
    environmental pipeline and must match the installed package’s
    `blockgroupstats`, `usastats`, and `statestats`.

3.  **Blockgroup Geography Updates** include `bgid2fips` and `blockwts`,
    and related `.rda` objects such as `bgpts` and `bg_cenpop2020`.
    These need review during each annual update and regeneration when
    blockgroup FIPS, EJAM `bgid`, internal points, or
    blockgroup-to-block relationships change.

4.  **Block Geography Updates** include `blockpoints`, `quaddata`, and
    `blockid2fips`. These need regeneration only when block-level FIPS
    or block internal-point geography changes.

Use `EJAM:::dynamic_geography_arrow_report()` to check whether the
current blockgroup and block geography Arrow files are compatible with
the installed `blockgroupstats` blockgroup universe.

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
  blockgroup-level statistics of EJ variables. This is part of the
  EJSCREEN Annual Data Update group and must match the package’s
  `blockgroupstats`
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
- [`?frs_by_programid`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_programid.md).arrow:
  data.table of Program System ID code(s) for each EPA-regulated site in
  the Facility Registry Service
- [`?frs_by_mact`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_mact.md).arrow:
  data.table of [MACT
  NESHAP](https://en.wikipedia.org/wiki/National_Emissions_Standards_for_Hazardous_Air_Pollutants)
  codes for sites, indicating the [subpart(s) that categorize relevant
  EPA-regulated
  sites](https://www.epa.gov/stationary-sources-air-pollution/national-emission-standards-hazardous-air-pollutants-neshap-8)

## Development/Setup

1.  The Arrow files are stored as release assets in a separate public
    GitHub repository (referred to here as `ejamdata`). The
    owner/repository name must be recorded/updated in the `DESCRIPTION`
    field called `ejam_data_repo`, which can be checked with
    `url_package(type = "data", get_full_url = TRUE)`. EJAM uses that
    information to find the dynamic data files.

2.  Any time the Arrow datasets are updated, create or update an
    `ejamdata` release and upload the `.arrow` files as release assets.
    Use the maintainer helper described below rather than relying on an
    automatic GitHub Actions workflow.

3.  EJAM’s
    [`download_latest_arrow_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/download_latest_arrow_data.md)
    function does the following:

&nbsp;

1.  Resolves the package-compatible `ejamdata` release tag from the
    `DESCRIPTION` field `ejamdata_required_tag`, unless a maintainer
    explicitly passes a different `piggybacktag`. This lets a patch
    release of EJAM keep using an earlier compatible `ejamdata` release
    if the Arrow files have not changed.
2.  Checks the user’s locally installed Arrow data release tag, which is
    stored in `data/ejamdata_version.txt`.
3.  If the `data/ejamdata_version.txt` file doesn’t exist, for example
    on the first EJAM install, it will be created at the end of the
    script.
4.  If the versions are different, downloads Arrow files from the
    matching `ejamdata` release with
    [`piggyback::pb_download()`](https://docs.ropensci.org/piggyback/reference/pb_download.html).
5.  When `dataload_dynamic("bgej")` loads `bgej`, the local `bgej.arrow`
    must also match the installed package’s `blockgroupstats`; if it
    does not, EJAM tries to replace it from the package-compatible
    `ejamdata` release tag. See how this function works for details:

``` r

download_latest_arrow_data()
```

4.  EJAM calls this logic from the attach/startup path through
    [`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
    so the needed Arrow files are available when a user loads EJAM or
    starts the app.

## How it Works for the User

1.  User installs EJAM

- `pak::pkg_install("Public-Environmental-Data-Partners/EJAM")` (or as
  adjusted depending on the actual repository owner and name)

2.  User loads EJAM as usual

- [`library(EJAM)`](https://public-environmental-data-partners.github.io/EJAM).
  This triggers the dynamic-data checks needed for startup.

3.  User runs EJAM as usual

- The
  [`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
  function will work as usual because the needed `.arrow` files are
  cached locally after they are downloaded.

## How New Versions of Arrow Datasets Are Republished / Released

First, create the key Arrow files locally or from the relevant pipeline
output, as explained above.

For future updates, the package may be modified to publish these files
via the update pipeline or related script such as
`run_arrow_publish_v2.5.0.R` but the information below is to describe
the functions if an update is done manually.

As mentioned above, we use [the piggyback
package](https://docs.ropensci.org/piggyback/index.html) to place large
datasets in the assets of a new release on the
<https://github.com/Public-Environmental-Data-Partners/ejamdata>
repository, rather than committing them with Git. The current maintainer
path is to call
[`datasets_arrow_publish()`](https://public-environmental-data-partners.github.io/EJAM/reference/datasets_arrow_publish.md)
with explicit local `.arrow` file paths.

The helper is intentionally conservative. It defaults to
`dry_run = TRUE`, `overwrite = FALSE`, and `mark_latest = FALSE`. The
default release note is
`"Updated datasets for EJScreen/EJAM updated as of "` plus the
`release_date` parameter.

Make sure the intended new data objects are available as `.arrow` files.
For an annual EJSCREEN data release, `bgej.arrow` is the critical
package-coupled asset and must match the package version/release tag.
Facility and geography Arrow files may be carried forward unchanged if
they are still compatible. If block or blockgroup helper Arrow files
such as `blockwts.arrow`, `blockpoints.arrow`, `blockid2fips.arrow`,
`bgid2fips.arrow`, or `quaddata.arrow` are intentionally regenerated in
a future geography update, publish those files with the same helper
after a dry-run review.

Example dry-run for a manual publish: (also see
run_arrow_publish_v2.5.0.R to publish all .arrow files in 1 step)

``` r

release_number <- EJAM:::ejamdata_required_tag()
new_datasets_folder <- "~/Downloads"
filepaths_arrow <- file.path(new_datasets_folder, "bgej.arrow")

EJAM:::datasets_arrow_publish(
  files = filepaths_arrow,
  tag = release_number,
  release_date = Sys.Date(),
  dry_run = TRUE,
  overwrite = FALSE,
  mark_latest = FALSE
)
```

After reviewing the dry-run output and the intended release tag, rerun
with `dry_run = FALSE` only when ready to create/update the release
assets. Use `overwrite = TRUE` only after confirming existing assets
with the same names should be replaced. Use `mark_latest = TRUE` only
when this release should be shown by GitHub as the latest release.

Open a browser to confirm they are there.

``` r

browseURL(paste0(EJAM:::url_package("data", get_full_url = T), "/releases"))
```

Reload EJAM so it can get the updates. It should detect that new
versions are available and cache them for the installed package.

``` r

rm(list=ls())
require(EJAM)

# Confirm they all can be opened as Arrow-backed objects
# as arrow files:
dataload_dynamic("all", return_data_table = FALSE)
# or read into memory as data.table/data.frame objects:
dataload_dynamic("all", return_data_table = TRUE)
```

This previously had been handled with a GitHub Actions workflow that
tried to use Git LFS. That automatic workflow is no longer used and
should not be restored.

## Potential Improvements

### Making More of the Code More Arrow-Friendly

Problem: loading the data as tibbles/data frames takes a long time.

Solution: We may be able to modify more of our code to be more
Arrow-friendly. This essentially keeps the analysis code as a sort of
query, and only actually loads the results into memory when requested
(e.g., via
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)).
This dramatically reduces memory usage, which would speed up processing
times and avoid potential crashes resulting from insufficient memory.
However, this would require a decent lift to update the code in all
places.

Pros: processing efficiency and significantly reduced memory usage.

Implementation: This has been enabled by the
[`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
function, which contains a `return_data_table` parameter. If `FALSE`,
the Arrow file is opened as an Arrow-backed object rather than read
fully into a data.table/data.frame.
