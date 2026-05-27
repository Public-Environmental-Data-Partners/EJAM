#' @name blockgroupstats
#' @docType data
#' @title blockgroupstats (DATA) residential population and environmental indicators for Census blockgroups
#'
#' @description
#' This is the dataset of residential population data and environmental indicators used by EJSCREEN.
#' It is a data.table with one row for every US Census blockgroup.
#'
#' @details
#'
#'   - SOURCES OF DATA:
#'
#'     - Environmental indicators were obtained from a variety of sources, and their development in 2026 onward will be documented at https://github.com/Public-Environmental-Data-Partners/EJSCREEN-Data-Processing.
#'
#'     - Demographics such as percentages are calculated using EJAM scripts and
#'     functions, starting with Census Bureau data from the American Community
#'     Survey 5-year summary file. ACS calculations are based primarily on
#'     [formulas_ejscreen_acs], [formulas_ejscreen_acs_disability], and
#'     [formulas_ejscreen_demog_index].
#'
#'     - The EJ Indexes (aka Summary Indexes) are calculated by EJAM based on blockgroupstats data, and are stored in a separate table, [bgej]
#'
#'     - The [definition of and source of data for every indicator was originally documented by EPA for EJSCREEN](`r paste0(EJAM::url_package(type = "docs", get_full_url = TRUE), "/articles/ejscreen.html")`). Originally, the environmental, demographic, and EJ indicators/indexes and extra indicators all were provided by EPA for EJAM versions through v2.32.8 (early 2026).
#'
#'     - Metadata on each indicator, such as its glossary definition or long name, are stored in the EJAM package, and can be accessed with the function [varinfo()] and the dataset [map_headernames].
#'
#'
#'   - VINTAGE:
#'
#'     - Each year this should be re-created as for the latest version.
#'
#'     - See `attributes(blockgroupstats)` to confirm vintage of each dataset
#'
#'     - EJAM v2.5.0 used indicators derived from 2020-2024 ACS data.
#'
#'     - EJAM v2.32.x starting in August 2024 and through 2025 to early 2026, used demographic indicators derived from 2018-2022 ACS data.
#'
#'     - Also see [ejanalysis.com/status](https://ejanalysis.com/status)
#'
#'
#'   - GEOGRAPHIC SCOPE:
#'
#'     - Data here includes States, DC, Puerto Rico (PR), and, for EJAM
#'     v2.5.0, the Island Areas AS/GU/MP/VI at the blockgroup dataset,
#'     EJSCREEN export, and map-data visibility level.
#'
#'     - Puerto Rico is included in both Census 2020 and ACS survey data, so it
#'     has ACS-derived demographics in the `blockgroupstats` dataset.
#'
#'     - The American Community Survey (ACS) does not include AS/GU/MP/VI. For
#'     EJAM v2.5.0, the default EJSCREEN-compatible pipeline appends AS/GU/MP/VI
#'     rows with demographic fields, population, and demographic indexes kept as
#'     `NA`, while preserving partial EPA environmental fields where available.
#'     The annual pipeline can also save 2020 Island Areas Census DHC
#'     demographics as a separate `bg_islandareas_demographics` checkpoint for
#'     review. Those DHC demographics are not used in the default
#'     EJSCREEN-compatible `blockgroupstats` output unless the maintainer
#'     explicitly opts into a mixed-source supplemental dataset. See
#'     https://www.census.gov/programs-surveys/decennial-census/decade/2020/planning-management/release/2020-island-areas-data-products.html
#'     and also see `stateinfo2[stateinfo2$is.island.areas, ]` and
#'     [islandareas]. The Island Areas include American Samoa (AS), U.S. Virgin
#'     Islands (VI), Guam (GU), and Northern Mariana Islands (MP). The U.S.
#'     Minor Outlying Islands (UM) are also Island Areas but are not included in
#'     EJScreen.
#'
#'     - Island Areas are not supported by the block helper datasets used for
#'     point-buffer/radius and block-weighted polygon analysis, such as
#'     [blockwts], [blockpoints], [bgid2fips], [blockid2fips], [quaddata], and
#'     [bgpts]. Radius/buffer analysis for AS/GU/MP/VI should return no-data
#'     results rather than block-weighted estimates.
#'
#'   - COLUMNS / INDICATORS:
#'
#'     - Column names include `bgfips`, `bgid` (for join to [blockwts] by/on `bgid`), `pop`, `pctlowinc`, etc.
#'
#'     - For metadata on each column, see [map_headernames] and [varinfo()]
#'
#'     - To see definitions of the columns (indicators) and some basic info on each:
#'   ```
#'   x <- data.frame(
#'    colname = names(blockgroupstats),
#'    definition = fixcolnames(names(blockgroupstats), 'r', 'long'),
#'    varinfo(names(blockgroupstats), info = c("varlist", "varcategory",
#'    "vartype", "calculation_type", "denominator", "sigfigs", "decimals")))
#'  rownames(x) <- NULL
#'  x[1:20, ]
#'  ```
#'
#'     - The compatibility-only column called `area` is retained from older
#'     EJScreen/EJAM tables but should not be used for calculations. The columns
#'     `arealand` and `areawater` are in square meters, not square miles. To
#'     convert units:
#'   ```
#'  convert_units(sum( blockgroupstats$arealand) , "sqm", "sqmi")
#'   ```
#'
#'
#'   - OTHER KEY DATASETS:
#'
#'     - List of key datasets used by EJAM and details about annual updates: [technical article on updating datasets](`r paste0(EJAM::url_package(get_full_url = TRUE, type = "docs"), "/articles/dev-update-datasets.html")`)
#'
#'     - Datasets stored within the EJAM package (.rda files): [Documentation](`r paste0(EJAM::url_package(get_full_url = TRUE, type = "docs"), "/reference/index.html#datasets-with-indicators-raw-data-means-percentiles-")`) and [access to installed data files](`r paste0(EJAM::url_package(get_full_url = TRUE, type = "code"), "/tree/main/data")`)
#'
#'     - Datasets used by EJAM but stored separately (large .arrow files): [Documentation](`r paste0(EJAM::url_package(get_full_url = TRUE, type = "docs"), "/articles/dev-update-datasets.html#blockgroup-and-block-level-arrow-files")`) and [release assets with downloadable data files](`r paste0(EJAM::url_package(get_full_url = TRUE, type = "data"), "/releases")`)
#'
#'
NULL
