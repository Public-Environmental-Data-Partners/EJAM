.arrow_ds_names <- c(
  "blockwts",
  "blockpoints",
  "quaddata",
  "bgej",
  "bgid2fips",
  "blockid2fips",
  "frs",
  "frs_by_programid",
  "frs_by_naics",
  "frs_by_sic",
  "frs_by_mact"    
)

.dynamic_data_groups <- c(
  blockwts = "blockgroup_geography_update",
  blockpoints = "block_geography_update",
  quaddata = "block_geography_update",
  bgej = "ejscreen_annual_update",
  bgid2fips = "blockgroup_geography_update",
  blockid2fips = "block_geography_update",
  frs = "facility_data_update",
  frs_by_programid = "facility_data_update",
  frs_by_naics = "facility_data_update",
  frs_by_sic = "facility_data_update",
  frs_by_mact = "facility_data_update"
)

# Dynamic Arrow files follow different update cadences. Keep this categorization
# close to .arrow_ds_names so download and validation helpers use the same source.
dynamic_data_group <- function(varnames = .arrow_ds_names) {
  out <- .dynamic_data_groups[varnames]
  missing_group <- is.na(out)
  if (any(missing_group)) {
    out[missing_group] <- "unknown"
  }
  out
}

dynamic_data_release_tag <- function(varnames = .arrow_ds_names,
                                     piggybacktag = "latest") {
  out <- stats::setNames(rep(piggybacktag, length(varnames)), varnames)
  ejscreen_annual <- dynamic_data_group(varnames) == "ejscreen_annual_update"
  out[ejscreen_annual] <- paste0("v", as.character(utils::packageVersion("EJAM")))
  out
}
