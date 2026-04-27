

datacreate_names_pct_as_fraction <- function(map_headernames)   {

  # datacreate_names_pct_as_fraction.R

  ## this should happen after map_headernames is recreated if necessary

  # map_headernames$pct_as_fraction_blockgroupstats is TRUE when  map_headernames$rname %in% names_pct_as_fraction_blockgroupstats
  # map_headernames$pct_as_fraction_ejamit          is TRUE when  map_headernames$rname %in% names_pct_as_fraction_ejamit

  names_pct_as_fraction_ejamit          <- unique(map_headernames$rname[map_headernames$pct_as_fraction_ejamit])
  names_pct_as_fraction_blockgroupstats <- unique(map_headernames$rname[map_headernames$pct_as_fraction_blockgroupstats])
  names_pct_as_fraction_blockgroupstats <- unique(names_pct_as_fraction_blockgroupstats[names_pct_as_fraction_blockgroupstats %in% names(blockgroupstats)])

  # names_pct_as_fraction_blockgroupstats <- metadata_add(names_pct_as_fraction_blockgroupstats)
  # names_pct_as_fraction_ejamit          <- metadata_add(names_pct_as_fraction_ejamit)
  #
  # usethis::use_data(names_pct_as_fraction_blockgroupstats, overwrite = T)
  # usethis::use_data(names_pct_as_fraction_ejamit,          overwrite = T)
#
  EJAM:::metadata_add_and_use_this("names_pct_as_fraction_blockgroupstats")
  EJAM:::metadata_add_and_use_this("names_pct_as_fraction_ejamit")

  ## Documentation ####

  dataset_documenter("names_pct_as_fraction_blockgroupstats",
                     title = "which indicators are percentages stored as 0-1 not 0-100, in blockgroupstats\n#' @keywords internal")
  dataset_documenter("names_pct_as_fraction_ejamit",
                     title = "which indicators are percentages stored as 0-1 not 0-100, in blockgroupstats\n#' @keywords internal")

  # return them just in case that is useful, but this is really to save them as datasets and document them
  return(list(
    names_pct_as_fraction_blockgroupstats = names_pct_as_fraction_blockgroupstats,
    names_pct_as_fraction_ejamit = names_pct_as_fraction_ejamit
  ))
}
################################################## #


# USE THE FUNCTION ####

datacreate_names_pct_as_fraction(map_headernames = map_headernames)   # Does metadata_add and use_data
print("remember to use document() to use the updated .R files to make new .Rd files")
rm("datacreate_names_pct_as_fraction")

################################################## #
