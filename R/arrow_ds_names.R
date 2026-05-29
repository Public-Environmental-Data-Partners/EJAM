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

# Arrow files follow different update cadences. Keep this categorization close
# to .arrow_ds_names so validation and maintainer helpers use the same source.
dynamic_data_group <- function(varnames = .arrow_ds_names) {
  out <- .dynamic_data_groups[varnames]
  missing_group <- is.na(out)
  if (any(missing_group)) {
    out[missing_group] <- "unknown"
  }
  out
}

ejamdata_required_tag <- function(package = "EJAM", default = NULL) {
  if (is.null(default)) {
    default <- tryCatch(
      paste0("v", as.character(utils::packageVersion(package))),
      error = function(e) NA_character_
    )
  }

  tag <- tryCatch(
    desc::desc(package = package)$get("ejamdata_required_tag"),
    error = function(e) NA_character_
  )
  tag <- as.character(tag)[1]

  if (is.na(tag) || !nzchar(tag)) {
    if (is.na(default) || !nzchar(default)) {
      stop(
        "Could not determine required ejamdata release tag. ",
        "Add ejamdata_required_tag to DESCRIPTION or pass an explicit default.",
        call. = FALSE
      )
    }
    return(default)
  }
  if (!startsWith(tag, "v")) {
    tag <- paste0("v", tag)
  }
  ejamdata_tag_canonical(tag)
}

ejamdata_tag_canonical <- function(tag) {
  tag <- as.character(tag)
  tag[!is.na(tag) & tag == "v2.32.8.1"] <- "v2.32.8.001"
  tag
}

dynamic_data_release_tag <- function(varnames = .arrow_ds_names,
                                     piggybacktag = "latest",
                                     required_tag = ejamdata_required_tag()) {
  release_tag <- piggybacktag
  if (identical(piggybacktag, "latest")) {
    release_tag <- required_tag
  }
  release_tag <- ejamdata_tag_canonical(release_tag)
  stats::setNames(rep(release_tag, length(varnames)), varnames)
}
