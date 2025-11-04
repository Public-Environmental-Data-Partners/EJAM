

#' find all blockgroups at least partly in bounds of city/cities specified
#' @details
#' used by [fips_bgs_in_fips()], and uses fips_bgs_intersect_city_approx() and
#' fips_bgs_intersect_city_exact() helpers
#'
#' @param fips vector of city/CDP/town fips as from among censusplaces$fips
#' @param approx optional, set to FALSE if you need exactly which blockgroups overlap at all with city/cities,
#'  but that method is much slower as it downloads all blockgroup boundaries for all relevant counties
#'  containing specified cities. The approx method finds all blockgroups
#'  for which at least one block centroid is inside the city polygon.
#'  It is MUCH faster, but can sometimes leave out a blockgroup that only slightly overlaps the city.
#'
#' @returns vector of blockgroup fips codes
#'
#' @keywords internal
#'
fips_bgs_in_city = function(fips = testinput_fips_cities[1:2], approx = TRUE) {

  if (approx) {
    fips_bgs_intersect_city_approx(fips)
  } else {
    fips_bgs_intersect_city_exact(fips)
  }
}
#################################################### #

fips_bgs_intersect_city_approx = function(fips = testinput_fips_cities) {
  ## find all blockgroups for which at least one block centroid is inside the city polygon
  ## but note it can sometimes leave out a blockgroup that only slightly overlaps the city
  s2b = getblocksnearby_from_fips(fips)
  bgfips = unique(blockgroupstats[s2b, .(bgfips, fips), on = 'bgid'])$bgfips
  if (length(bgfips) == 0) {
    return(NULL)
    } else {
    return(bgfips)
  }
}
#################################################### #

fips_bgs_intersect_city_exact = function(fips = testinput_fips_cities) {
  ## find all that intersect, but SLOW since it downloads all blockgroup bounds in relevant counties
  countyfips <- fips2countyfips(fips)
  all_bgs_in_these_counties <- fips_bgs_in_fips(countyfips)
  bgshps = shapes_from_fips(all_bgs_in_these_counties)

  cityshps <- shapes_from_fips(fips)
  cityshps <- sf::st_transform(cityshps, crs = sf::st_crs(bgshps))

  overlap <- sf::st_intersects(bgshps, cityshps)
  bgfips <- unique(bgshps$FIPS[which(overlap %in% 1)])

  if (length(bgfips) == 0) {
    return(NULL)
  } else {
    return(bgfips)
  }
}
#################################################### #
