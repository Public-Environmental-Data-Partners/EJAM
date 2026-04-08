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
#'   - Environmental indicators were provided by EPA.
#'
#'   - Demographics such as percentages are calculated from Census Bureau data from the American Community Survey
#'   5-year summary file, as documented by EJSCREEN.
#'
#'   - The EJ Indexes (Summary Indexes) are stored in a separate table, [bgej]
#'
#'  The [source of data for each indicator was documented by EJSCREEN](`r paste0(EJAM::url_package(type = "docs", get_full_url = T), "/articles/ejscreen.html")`)
#'
#'  More about blockgroupstats
#'
#'   - During 2025, EJAM used EPA environmental indicators along with population indicators derived
#'   from 2018-2022 ACS data. Each year this should be re-created as for the latest version.
#'
#'   - See `attributes(blockgroupstats)` to confirm vintage of each dataset
#'
#'   - Geographic scope includes States, DC, and Puerto Rico (PR), but not any Island Areas (VI, GU, AS, etc.)
#'
#'   - Column names include `bgfips`, `bgid` (for join to [blockwts] by/on `bgid`),
#'    `pop`, `pctlowinc`, etc.
#'
#'   - For metadata on each column, see [map_headernames] and [varinfo()]
#'
#'   - To see definitions of the columns (indicators) and some basic info on each:
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
#'  The columns called arealand and areawater are in square meters,
#'  not square miles - to convert units:
#'
#'   ```
#'  convert_units(sum( blockgroupstats$arealand) , "sqm", "sqmi")
#'   ```
#'
#'  The column called "area" is not used and not documented.
#'
#'
#'   Other key datasets:
#'
#'   - List of key datasets used by EJAM and details about annual updates: [technical article on updating datasets](`r paste0(EJAM::url_package(get_full_url = T, type = "docs"), "/articles/dev-update-datasets.html")`)
#'
#'   - Datasets stored within the EJAM package (.rda files): [Documentation](`r paste0(EJAM::url_package(get_full_url = T, type = "docs"), "/reference/index.html#datasets-with-indicators-raw-data-means-percentiles-")`) and [access to installed data files](`r paste0(EJAM::url_package(get_full_url = T, type = "code"), "/tree/main/data")`)
#'
#'   - Datasets used by EJAM but stored separately (large .arrow files): [Documentation](`r paste0(EJAM::url_package(get_full_url = T, type = "docs"), "/articles/dev-update-datasets.html#blockgroup-and-block-level-arrow-files")`) and [access to downloaded data files](`r paste0(EJAM::url_package(get_full_url = T, type = "data"), "/tree/main/data")`)
#'
#'   - Also see [ejanalysis.com/status](https://ejanalysis.com/status)
#'
NULL
