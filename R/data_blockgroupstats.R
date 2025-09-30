#' @name blockgroupstats
#' @docType data
#' @title blockgroupstats (DATA) residential population and environmental indicators for Census blockgroups
#'
#' @description
#'   The dataset of residential population data and environmental indicators originally from EJSCREEN.
#'
#'   For Summary Indexes, see [bgej]
#'
#' @details
#'   - Version `r as.vector(EJAM:::global_or_param("app_version"))` of EJAM
#'   uses EPA environmental indicators and population indicators derived from
#'   ACS data from `r as.vector(desc::desc_get("VersionACS"))`.
#'
#'   Each year this should be re-created as for the latest version.
#'   See `attributes(blockgroupstats)`
#'
#'   It is a data.table of US Census blockgroups (not blocks).
#'   With PR, and Island Areas
#'
#'   Column names include `bgfips`, `bgid` (for join to [blockwts] by/on `bgid`),
#'    `pop`, `pctlowinc`, etc.
#'
#'   To see definitions of the columns (indicators) and some basic info on each:
#'   ```
#'   x = data.frame(
#'    colname = names(blockgroupstats),
#'    definition = fixcolnames(names(blockgroupstats), 'r', 'long'),
#'    varinfo(names(blockgroupstats), info = c("varlist", "varcategory",
#'    "vartype", "calculation_type", "denominator", "sigfigs", "decimals")))
#'  ```
#'
#'  The columns called arealand and areawater are in square meters,
#'  not square miles - to convert units:
#'  `convert_units(sum( blockgroupstats$arealand) , "sqm", "sqmi")`
#'  The column called "area" is not used and not documented.
NULL
