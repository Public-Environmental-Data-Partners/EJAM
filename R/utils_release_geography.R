# Release geography preparation is deliberately separate from data activation.
# These internal helpers write only to a new output directory, never to data/.
release_geography_year <- function(year = acs_endyear()) {
  if (length(year) != 1L || is.na(year) ||
      !grepl("^[0-9]{4}$", as.character(year)) ||
      as.integer(year) < 2020L || as.integer(year) > 2099L) {
    stop("year must be one integer geography vintage from 2020 through 2099", call.=FALSE)
  }
  as.integer(year)
}

shapes_acs_boundary_service <- function(kind = c("blockgroup", "tract", "county"),
                                        year = acs_endyear()) {
  kind <- match.arg(kind)
  year <- release_geography_year(year)
  if (year %in% c(2022L, 2023L)) {
    layer <- c(blockgroup=5L, tract=4L, county=2L)[[kind]]
    return(sprintf(paste0("https://services.arcgis.com/P3ePLMYs2RVChkJx/",
      "ArcGIS/rest/services/USA_Boundaries_%s/FeatureServer/%s/query"), year, layer))
  }
  if (year == 2024L) {
    # Verified against the official service metadata; Esri USA_Boundaries_2024
    # does not exist. Layer numbers must be checked before adding another year.
    layer <- c(blockgroup=10L, tract=8L, county=82L)[[kind]]
    return(sprintf(paste0("https://tigerweb.geo.census.gov/arcgis/rest/services/",
      "TIGERweb/tigerWMS_ACS2024/MapServer/%s/query"), layer))
  }
  stop("No verified default boundary service for ACS ", year,
       "; supply an explicit service URL or a supported tigris source", call.=FALSE)
}

shapes_is_census_service <- function(url) {
  grepl("^https://tigerweb[.]geo[.]census[.]gov/arcgis/", url)
}

release_geography_sources <- function(year = acs_endyear()) {
  year <- release_geography_year(year)
  c(states_shapefile=sprintf(paste0("https://www2.census.gov/geo/tiger/",
      "TIGER%s/STATE/tl_%s_us_state.zip"), year, year),
    counties_shapefile=sprintf(paste0("https://www2.census.gov/geo/tiger/",
      "GENZ%s/shp/cb_%s_us_county_500k.zip"), year, year))
}

release_geography_area_fields <- function() {
  as.vector(outer(c("landarea", "waterarea", "area"), c("sqkm", "sqmi"), paste, sep="."))
}

release_geography_prepare <- function(states, counties, year,
                                       state_lookup = stateinfo,
                                       state_lookup_extended = stateinfo2) {
  year <- release_geography_year(year)
  sources <- release_geography_sources(year)
  bundle <- list(year=year, states_shapefile=states, counties_shapefile=counties)
  for (name in names(sources)) {
    x <- bundle[[name]]
    x <- x[order(x$GEOID), ]
    rownames(x) <- NULL
    # Source geography is not an ACS/package release stamp. Stage outputs must
    # receive matching release stamps only during the coordinated data swap.
    attr(x, "acs_version") <- NULL
    attr(x, "ejam_package_version") <- NULL
    attr(x, "boundary_year") <- year
    attr(x, "source_url") <- unname(sources[[name]])
    bundle[[name]] <- x
  }
  states <- bundle$states_shapefile
  for (name in c("stateinfo", "stateinfo2")) {
    x <- if (name == "stateinfo") state_lookup else state_lookup_extended
    idx <- match(x$FIPS.ST, states$STATEFP)
    ok <- !is.na(idx)
    updated <- c("ST", "statename")
    x$ST[ok] <- states$STUSPS[idx[ok]]
    x$statename[ok] <- states$NAME[idx[ok]]
    if (name == "stateinfo2") {
      x$landarea.sqkm[ok] <- as.numeric(states$ALAND[idx[ok]]) / 1e6
      x$waterarea.sqkm[ok] <- as.numeric(states$AWATER[idx[ok]]) / 1e6
      x$area.sqkm[ok] <- x$landarea.sqkm[ok] + x$waterarea.sqkm[ok]
      for (stem in c("landarea", "waterarea", "area")) {
        x[[paste0(stem, ".sqmi")]][ok] <- x[[paste0(stem, ".sqkm")]][ok] / 2.589988110336
      }
      x$lat[ok] <- as.numeric(states$INTPTLAT[idx[ok]])
      x$lon[ok] <- as.numeric(states$INTPTLON[idx[ok]])
      for (column in release_geography_area_fields()) {
        x[[column]][x$ST == "US"] <- sum(x[[column]][x$is.usa & ok])
      }
      updated <- c(updated, release_geography_area_fields(), "lat", "lon")
    }
    attr(x, "retained_metadata") <- list(
      acs_version=attr(x, "acs_version"), ejam_package_version=attr(x, "ejam_package_version"))
    attr(x, "acs_version") <- NULL
    attr(x, "ejam_package_version") <- NULL
    attr(x, "geography_year") <- year
    attr(x, "source_url") <- unname(sources[["states_shapefile"]])
    attr(x, "updated_geography_fields") <- updated
    attr(x, "retained_fields") <- setdiff(names(x), updated)
    attr(x, "retained_rows") <- as.character(x$ST[!ok])
    bundle[[name]] <- x
  }
  counties <- bundle$counties_shapefile
  bundle$countyinfo <- data.frame(FIPS=counties$GEOID, STATEFP=counties$STATEFP,
    ST=states$STUSPS[match(counties$STATEFP, states$STATEFP)], NAME=counties$NAME,
    landarea.sqkm=as.numeric(counties$ALAND)/1e6,
    waterarea.sqkm=as.numeric(counties$AWATER)/1e6, stringsAsFactors=FALSE)
  release_geography_validate(bundle)
  bundle
}

release_geography_validate <- function(bundle) {
  year <- release_geography_year(bundle$year)
  sources <- release_geography_sources(year)
  expected_states <- c("01","02","04","05","06","08","09","10","11","12","13",
    "15","16","17","18","19","20","21","22","23","24","25","26","27","28",
    "29","30","31","32","33","34","35","36","37","38","39","40","41","42",
    "44","45","46","47","48","49","50","51","53","54","55","56","60","66","69","72","78")
  for (name in names(sources)) {
    x <- bundle[[name]]
    width <- if (name == "states_shapefile") 2L else 5L
    required <- c("GEOID", "STATEFP", "NAME", "ALAND", "AWATER")
    if (!inherits(x, "sf") || !all(required %in% names(x))) stop("Invalid boundary schema: ", name)
    if (!identical(attr(x,"boundary_year"), year) ||
        !identical(attr(x,"source_url"), unname(sources[[name]]))) stop("Mixed boundary vintages: ", name)
    if (!is.character(x$GEOID) || anyNA(x$GEOID) || anyDuplicated(x$GEOID) ||
        any(!grepl(paste0("^[0-9]{",width,"}$"), x$GEOID)) ||
        anyNA(x$STATEFP) || any(substr(x$GEOID,1,2) != x$STATEFP)) stop("Invalid/duplicate FIPS: ", name)
    geometry_types <- as.character(sf::st_geometry_type(x,by_geometry=TRUE))
    if (anyNA(geometry_types) || any(!geometry_types %in% c("POLYGON","MULTIPOLYGON"))) {
      stop("Non-polygon boundary geometry: ",name," (expected POLYGON or MULTIPOLYGON)",call.=FALSE)
    }
    if (is.na(sf::st_crs(x)) || anyNA(sf::st_is_valid(x)) || any(!sf::st_is_valid(x)) ||
        anyNA(sf::st_is_empty(x)) || any(sf::st_is_empty(x)) ||
        any(!is.finite(as.numeric(x$ALAND))) || any(!is.finite(as.numeric(x$AWATER))) ||
        any(x$ALAND < 0 | x$AWATER < 0)) stop("Invalid geometry/area: ", name)
    geometry_area <- as.numeric(sf::st_area(x))
    if (any(!is.finite(geometry_area) | geometry_area <= 0)) stop("Invalid geometry/area: ",name,call.=FALSE)
  }
  states <- bundle$states_shapefile
  counties <- bundle$counties_shapefile
  if (nrow(states) != 56L || !setequal(states$GEOID, expected_states) ||
      !all(c("STUSPS","INTPTLAT","INTPTLON") %in% names(states))) stop("Incomplete state/territory coverage")
  lat <- suppressWarnings(as.numeric(states$INTPTLAT))
  lon <- suppressWarnings(as.numeric(states$INTPTLON))
  if (any(!is.finite(lat) | abs(lat)>90) || any(!is.finite(lon) | abs(lon)>180) ||
      anyNA(states$STUSPS) || anyDuplicated(states$STUSPS)) stop("Invalid state internal points/abbreviations")
  if (nrow(counties) < 3000L || !setequal(unique(counties$STATEFP), expected_states)) stop("Incomplete county coverage")
  if (year >= 2022L && !setequal(counties$GEOID[counties$STATEFP == "09"], sprintf("09%d0",11:19))) {
    stop("Connecticut planning-region FIPS are incomplete")
  }
  if (!all(c("02063","02066","02158") %in% counties$GEOID) ||
      any(c("02261","02270") %in% counties$GEOID)) stop("Stale Alaska county equivalents")
  for (name in c("stateinfo","stateinfo2")) {
    x <- bundle[[name]]
    required <- c("ST","statename","FIPS.ST")
    if (name == "stateinfo2") required <- c(required,release_geography_area_fields(),"lat","lon","is.usa")
    expected <- if (name == "stateinfo") setdiff(expected_states,c("60","66","69","78")) else expected_states
    if (!all(required %in% names(x)) || !is.character(x$FIPS.ST) ||
        !setequal(x$FIPS.ST[!x$ST %in% c("US","UM")],expected) ||
        anyDuplicated(x$FIPS.ST[!is.na(x$FIPS.ST)])) stop("Incomplete state lookup schema/coverage: ",name)
    idx <- match(x$FIPS.ST, states$STATEFP)
    ok <- !is.na(idx)
    if (!identical(attr(x,"geography_year"),year) ||
        !identical(attr(x,"source_url"),unname(sources[["states_shapefile"]])) ||
        anyDuplicated(x$ST) || anyNA(x$ST) || anyNA(x$FIPS.ST[x$ST != "US"]) ||
        !all(x$ST %in% c(states$STUSPS,"US","UM")) ||
        !all(x$ST[ok] == states$STUSPS[idx[ok]]) || !all(x$statename[ok] == states$NAME[idx[ok]])) {
      stop("Stale state lookup/provenance: ",name)
    }
  }
  x <- bundle$stateinfo2
  idx <- match(x$FIPS.ST, states$STATEFP)
  ok <- !is.na(idx)
  reference <- list(landarea.sqkm=as.numeric(states$ALAND[idx[ok]])/1e6,
    waterarea.sqkm=as.numeric(states$AWATER[idx[ok]])/1e6,
    lat=as.numeric(states$INTPTLAT[idx[ok]]), lon=as.numeric(states$INTPTLON[idx[ok]]))
  reference$area.sqkm <- reference$landarea.sqkm + reference$waterarea.sqkm
  for (stem in c("landarea","waterarea","area")) {
    reference[[paste0(stem,".sqmi")]] <- reference[[paste0(stem,".sqkm")]]/2.589988110336
  }
  for (column in names(reference)) {
    if (!isTRUE(all.equal(x[[column]][ok],reference[[column]],check.attributes=FALSE))) stop("Stale state information: ",column)
  }
  for (column in release_geography_area_fields()) {
    if (!isTRUE(all.equal(x[[column]][x$ST=="US"],sum(x[[column]][x$is.usa & ok]),check.attributes=FALSE))) stop("Invalid US area total: ",column)
  }
  info <- bundle$countyinfo
  if (!identical(info$FIPS,counties$GEOID) || !identical(info$NAME,counties$NAME) ||
      !identical(info$STATEFP,counties$STATEFP) ||
      !identical(info$ST,states$STUSPS[match(counties$STATEFP,states$STATEFP)]) ||
      !isTRUE(all.equal(info$landarea.sqkm,as.numeric(counties$ALAND)/1e6)) ||
      !isTRUE(all.equal(info$waterarea.sqkm,as.numeric(counties$AWATER)/1e6))) stop("Stale county information")
  invisible(TRUE)
}

# Full release validation requires every dynamic table. A missing input is a
# visible not_checked result, never an implied pass. No crosswalk is rewritten.
release_geography_check_links <- function(bundle, blockgroup_data, bgid2fips=NULL,
    blockwts=NULL, blockid2fips=NULL, blockpoints=NULL, quaddata=NULL) {
  release_geography_validate(bundle)
  rows <- list()
  add <- function(check, bad=NULL, checked=TRUE, informational=FALSE, review=FALSE) {
    bad <- unique(as.character(bad))
    rows[[length(rows)+1L]] <<- data.frame(check=check,
      status=if (!checked) "not_checked" else if (informational) "info" else if (length(bad)) {if (review) "review" else "fail"} else "pass",
      count=if (checked) length(bad) else NA_integer_, examples=paste(head(bad,10),collapse=", "))
  }
  valid_ids <- function(ids,width) !is.na(ids) & grepl(paste0("^[0-9]{",width,"}$"),as.character(ids))
  if (!"bgfips" %in% names(blockgroup_data) || !nrow(blockgroup_data)) {
    stop("blockgroup_data requires nonempty bgfips",call.=FALSE)
  }
  for (item in list(list(bgid2fips,c("bgid","bgfips")),list(blockwts,c("blockid","bgid","blockwt")),
                   list(blockid2fips,c("blockid","blockfips")),list(blockpoints,c("blockid","lat","lon")),
                   list(quaddata,c("blockid","BLOCK_X","BLOCK_Y","BLOCK_Z")))) {
    if (!is.null(item[[1]]) && (!nrow(item[[1]]) || !all(item[[2]] %in% names(item[[1]])))) {
      stop("Dynamic geography input has missing rows/columns: ",paste(item[[2]],collapse=", "),call.=FALSE)
    }
  }
  ids <- as.character(blockgroup_data$bgfips)
  # Island Area demographics retain source-specific identifiers: seven digits
  # for AS/GU/MP and ten for VI, not Census blockgroup GEOIDs. Do not pad them
  # into fictitious county/blockgroup codes or requiring nonexistent crosswalks.
  island_tract <- grepl("^((60|66|69)[0-9]{5}|78[0-9]{8})$",ids) & !is.na(ids)
  add("retained Island Area identifiers",ids[island_tract],informational=TRUE)
  add("blockgroup FIPS schema",ids[(!valid_ids(ids,12) & !island_tract) | duplicated(ids)])
  add("blockgroup counties",setdiff(substr(ids[!island_tract],1,5),bundle$counties_shapefile$GEOID))
  add("Island Area state coverage",setdiff(substr(ids[island_tract],1,2),bundle$states_shapefile$GEOID))
  acs <- attr(blockgroup_data,"acs_version")
  add("blockgroup ACS vintage",if (length(acs)!=1L || !grepl(paste0(bundle$year,"$"),acs)) "mismatched or missing ACS stamp")
  if (!is.null(bgid2fips)) {
    add("bgid2fips schema",if (!all(c("bgid","bgfips") %in% names(bgid2fips))) "missing bgid/bgfips" else
      as.character(bgid2fips$bgid[duplicated(bgid2fips$bgid) | is.na(bgid2fips$bgid)]))
    add("crosswalk FIPS schema",as.character(bgid2fips$bgfips[!valid_ids(bgid2fips$bgfips,12) | duplicated(bgid2fips$bgfips)]))
    add("crosswalk blockgroups outside ACS",setdiff(as.character(bgid2fips$bgfips),ids),review=TRUE)
    add("ACS blockgroups without crosswalk",setdiff(ids[!island_tract],as.character(bgid2fips$bgfips)),review=TRUE)
  } else add("bgid2fips",checked=FALSE)
  if (!is.null(blockwts) && !is.null(bgid2fips)) {
    add("blockwts bgids",setdiff(blockwts$bgid,bgid2fips$bgid))
    add("blockwts values",as.character(blockwts$blockid[!is.finite(blockwts$blockwt) | blockwts$blockwt<0 | blockwts$blockwt>1]))
  } else add("blockwts",checked=FALSE)
  tables <- list(blockwts=blockwts,blockid2fips=blockid2fips,blockpoints=blockpoints,quaddata=quaddata)
  for (name in names(tables)) {
    x <- tables[[name]]
    if (is.null(x)) {add(paste(name,"blockids"),checked=FALSE); next}
    if (!"blockid" %in% names(x)) {add(paste(name,"blockids"),"missing blockid"); next}
    add(paste(name,"unique blockids"),as.character(x$blockid[is.na(x$blockid) | duplicated(x$blockid)]))
    if (!is.null(blockpoints)) add(paste(name,"block coverage"),
      c(setdiff(x$blockid,blockpoints$blockid),setdiff(blockpoints$blockid,x$blockid)))
  }
  if (!is.null(blockpoints)) add("block internal points",as.character(blockpoints$blockid[
    !is.finite(blockpoints$lat) | !is.finite(blockpoints$lon) | abs(blockpoints$lat)>90 | abs(blockpoints$lon)>180]))
  if (!is.null(quaddata)) add("block spatial-index coordinates",as.character(quaddata$blockid[
    !is.finite(quaddata$BLOCK_X) | !is.finite(quaddata$BLOCK_Y) | !is.finite(quaddata$BLOCK_Z)]))
  if (!is.null(blockid2fips)) {
    add("Census 2020 block FIPS schema",
      as.character(blockid2fips$blockfips[!valid_ids(blockid2fips$blockfips,15)]))
    add("block FIPS repeated across block IDs",
      as.character(blockid2fips$blockfips[duplicated(blockid2fips$blockfips)]),review=TRUE)
  }
  do.call(rbind,rows)
}

# Acknowledge reviewed observations by their exact check names. Invalid data and
# missing inputs remain errors even when named in reviewed_checks.
release_geography_assert_links <- function(report, reviewed_checks=character()) {
  if (!nrow(report) || !all(c("check","status") %in% names(report))) stop("Missing release link report")
  if (!is.character(reviewed_checks) || anyNA(reviewed_checks) ||
      any(!reviewed_checks %in% report$check[!is.na(report$status) & report$status=="review"])) {
    stop("reviewed_checks must name review observations in this report",call.=FALSE)
  }
  accepted <- report$status %in% c("pass","info") |
    (report$status %in% "review" & report$check %in% reviewed_checks)
  if (any(!accepted)) {
    stop("Release geography links require attention (record/review differences; do not change IDs or drop records): ",paste(report$check[!accepted],collapse=", "),call.=FALSE)
  }
  invisible(TRUE)
}

# openssl is already an optional package dependency. New builds and SHA-256
# manifest readback use it to verify source and payload identity.
release_geography_sha256 <- function(paths) {
  if (!requireNamespace("openssl",quietly=TRUE)) stop("Install openssl to record release-input SHA-256 checksums")
  vapply(paths,function(path) {
    con <- file(path,"rb")
    on.exit(close(con),add=TRUE)
    as.character(openssl::sha256(con))
  },character(1),USE.NAMES=FALSE)
}

release_geography_build <- function(output_dir, year=acs_endyear(),
                                    state_lookup=stateinfo, state_lookup_extended=stateinfo2) {
  year <- release_geography_year(year)
  if (length(output_dir)!=1L || is.na(output_dir) || !nzchar(output_dir) || file.exists(output_dir)) {
    stop("Choose a new, non-existing output directory",call.=FALSE)
  }
  sources <- release_geography_sources(year)
  scratch <- tempfile("release-geography-")
  dir.create(scratch)
  on.exit(unlink(scratch,recursive=TRUE),add=TRUE)
  shapes <- list()
  checksums <- character()
  for (name in names(sources)) {
    folder <- file.path(scratch,name)
    dir.create(folder)
    archive <- file.path(folder,basename(sources[[name]]))
    curl::curl_download(sources[[name]],archive,quiet=TRUE)
    checksums[[name]] <- release_geography_sha256(archive)[[1L]]
    paths <- unzip(archive,exdir=folder)
    shp <- paths[grepl("[.]shp$",paths)]
    if (length(shp)!=1L) stop("Expected one shapefile in ",name)
    shapes[[name]] <- sf::st_read(shp,quiet=TRUE,stringsAsFactors=FALSE)
  }
  bundle <- release_geography_prepare(shapes$states_shapefile,shapes$counties_shapefile,
    year,state_lookup,state_lookup_extended)
  # Finish and validate in scratch first. Publish a new directory only after all
  # outputs are complete; clean a partial new directory if copying fails.
  staged <- file.path(scratch,"outputs")
  dir.create(staged)
  for (name in c(names(sources),"stateinfo","stateinfo2")) {
    save(list=name,envir=list2env(setNames(list(bundle[[name]]),name)),
      file=file.path(staged,paste0(name,".rda")),compress="xz",version=2)
  }
  utils::write.csv(bundle$countyinfo,file.path(staged,"countyinfo.csv"),row.names=FALSE)
  files <- list.files(staged,full.names=TRUE)
  manifest <- list(schema_version=2L,boundary_year=year,sources=as.list(sources),
    source_archive_sha256=as.list(checksums),rows=lapply(bundle[-1L],nrow),
    stateinfo2_updated_fields=attr(bundle$stateinfo2,"updated_geography_fields"),
    stateinfo2_retained_fields=attr(bundle$stateinfo2,"retained_fields"),
    retained_rows=attr(bundle$stateinfo2,"retained_rows"),
    notes=c("Stage only. No ACS/package version is claimed for these geography outputs.",
      "US area totals sum 50 states + DC; US coordinates and UM retain previous values.",
      "Water subcategories, EPA regions, classifications and ftp names retain their previous provenance.",
      "countyinfo.csv is an audit table, not a new public dataset.",
      "Run the complete link check against accepted matching-vintage ACS and Census 2020 block/crosswalk inputs before promotion."),
    files_sha256=as.list(setNames(release_geography_sha256(files),basename(files))))
  jsonlite::write_json(manifest,file.path(staged,"manifest.json"),auto_unbox=TRUE,pretty=TRUE)
  if (!dir.create(output_dir,recursive=TRUE)) stop("Cannot reserve a new output directory")
  completed <- FALSE
  on.exit(if (!completed) unlink(output_dir,recursive=TRUE),add=TRUE)
  if (!all(file.copy(list.files(staged,full.names=TRUE),output_dir))) stop("Cannot copy geography outputs")
  completed <- TRUE
  invisible(bundle)
}

release_geography_read <- function(bundle_dir) {
  manifest <- jsonlite::read_json(file.path(bundle_dir,"manifest.json"),simplifyVector=TRUE)
  expected_files <- c("states_shapefile.rda","counties_shapefile.rda","stateinfo.rda","stateinfo2.rda","countyinfo.csv")
  # Older geography artifacts used schema 1/MD5. Reading them preserves
  # historical identity only, not acceptance of a release build. New builds
  # always emit schema 2/SHA-256.
  if (!isTRUE(manifest$schema_version %in% c(1L,2L))) stop("Invalid geography manifest")
  hashes <- if (manifest$schema_version==2L) manifest$files_sha256 else manifest$files_md5
  if (!setequal(names(hashes),expected_files)) stop("Invalid geography manifest")
  files <- file.path(bundle_dir,expected_files)
  if (any(!file.exists(files))) stop("Geography checksum mismatch")
  actual <- if (manifest$schema_version==2L) release_geography_sha256(files) else unname(tools::md5sum(files))
  if (!identical(unname(actual),unname(unlist(hashes[expected_files])))) stop("Geography checksum mismatch")
  bundle <- list(year=release_geography_year(manifest$boundary_year))
  for (name in sub("[.]rda$","",expected_files[1:4])) {
    env <- new.env(parent=emptyenv())
    load(file.path(bundle_dir,paste0(name,".rda")),envir=env)
    if (!identical(ls(env),name)) stop("Unexpected geography payload: ",name)
    bundle[[name]] <- env[[name]]
  }
  bundle$countyinfo <- utils::read.csv(file.path(bundle_dir,"countyinfo.csv"),
    colClasses=c("character","character","character","character","numeric","numeric"))
  release_geography_validate(bundle)
  bundle
}

# Determine physical boundary vintage independently of potentially stale ACS stamps.
release_geography_boundary_year <- function(x) {
  url <- attr(x,"source_url")
  from_url <- if (length(url)==1L && grepl("/(TIGER|GENZ)[0-9]{4}/",url)) {
    as.integer(sub(".*/(?:TIGER|GENZ)([0-9]{4})/.*","\\1",url,perl=TRUE))
  } else NA_integer_
  declared <- attr(x,"boundary_year")
  if (!is.null(declared)) {
    declared <- release_geography_year(declared)
    if (!is.na(from_url) && declared != from_url) stop("Boundary metadata disagrees with source URL")
    return(declared)
  }
  from_url
}
