geography_fixture <- function() {
  # Synthetic simple polygons keep corruption tests fast; source-vintage proof
  # comes from the separate live Census build and its archive checksums.
  square <- sf::st_polygon(list(matrix(c(-76,39,-75,39,-75,40,-76,40,-76,39),ncol=2,byrow=TRUE)))
  states <- states_shapefile
  counties <- counties_shapefile
  sf::st_geometry(states) <- sf::st_sfc(rep(list(square),nrow(states)),crs=4269)
  sf::st_geometry(counties) <- sf::st_sfc(rep(list(square),nrow(counties)),crs=4269)
  release_geography_prepare(states,counties,2024)
}

test_that("release years and verified runtime services follow ACS geography", {
  for (year in list(NULL,NA,2024.5,"2024x",c(2022,2024),Inf,1999)) {
    expect_error(release_geography_year(year),"year")
  }
  expect_identical(release_geography_year("2024"),2024L)
  expect_match(release_geography_sources(2024)[["counties_shapefile"]],"GENZ2024/shp/cb_2024_us_county_500k.zip",fixed=TRUE)
  for (kind in c("tract","blockgroup","county")) {
    expect_match(shapes_acs_boundary_service(kind,2022),"USA_Boundaries_2022",fixed=TRUE)
    expect_match(shapes_acs_boundary_service(kind,2024),"tigerWMS_ACS2024",fixed=TRUE)
  }
  expect_error(shapes_acs_boundary_service("tract",2025),"No verified")
  local_mocked_bindings(acs_endyear=function(...) "2024",.package="EJAM")
  expect_match(shapes_acs_boundary_service("blockgroup"),"/10/query",fixed=TRUE)
  expect_match(shapes_acs_boundary_service("tract"),"/8/query",fixed=TRUE)
  expect_match(shapes_acs_boundary_service("county"),"/82/query",fixed=TRUE)
  expect_null(shapes_counties_from_countyfips_local("10001")) # bundled data are 2022
})

test_that("Census requests use GEOID and normalize output through both dispatch paths", {
  id <- "100010401001"
  square <- sf::st_polygon(list(matrix(c(-76,39,-75,39,-75,40,-76,40,-76,39),ncol=2,byrow=TRUE)))
  calls <- character()
  local_mocked_bindings(acs_endyear=function(...) "2024",offline_cat=function(...) FALSE,
    fips_valid=function(x,...) rep(TRUE,length(x)),.package="EJAM")
  local_mocked_bindings(st_read=function(dsn,...) {
    calls <<- c(calls,dsn)
    is_bg <- grepl("/10/query",dsn,fixed=TRUE)
    sf::st_sf(GEOID=if(is_bg) id else substr(id,1,11),NAME="test",
      geometry=sf::st_sfc(square,crs=4269))
  },.package="sf")
  for (dispatch in c(TRUE,FALSE)) {
    bg <- shapes_from_fips(id,allow_multiple_fips_types=dispatch)
    tract <- shapes_from_fips(substr(id,1,11),allow_multiple_fips_types=dispatch)
    expect_false(any(sf::st_is_empty(bg)))
    expect_false(any(sf::st_is_empty(tract)))
    expect_identical(bg$FIPS,id)
    expect_identical(tract$FIPS,substr(id,1,11))
  }
  for (request in calls) {
    query <- httr2::url_parse(request)$query
    expect_match(query$where,"GEOID=",fixed=TRUE)
    expect_identical(query$outFields,"*")
  }
})

test_that("geography validation detects physical vintage, coverage and stale lookup fields", {
  bundle <- geography_fixture()
  expect_true(release_geography_validate(bundle))
  expect_identical(names(bundle$stateinfo2),names(stateinfo2))
  expect_identical(names(bundle$stateinfo),names(stateinfo))
  expect_null(attr(bundle$stateinfo2,"ejam_package_version"))
  bad <- bundle; bad$stateinfo$ST <- NULL
  expect_error(release_geography_validate(bad),"schema/coverage")
  bad <- bundle; bad$stateinfo2 <- bad$stateinfo2[-1,]
  expect_error(release_geography_validate(bad),"schema/coverage")
  bad <- bundle; bad$states_shapefile$INTPTLAT[1] <- "99"
  expect_error(release_geography_validate(bad),"internal points")
  expect_true("inland.sqmi" %in% attr(bundle$stateinfo2,"retained_fields"))
  expect_identical(bundle$stateinfo2$inland.sqmi,stateinfo2$inland.sqmi)
  for (column in c(release_geography_area_fields(),"lat","lon")) {
    bad <- bundle
    bad$stateinfo2[[column]][1] <- bad$stateinfo2[[column]][1]+100
    expect_error(release_geography_validate(bad),"Stale state information")
  }
  bad <- bundle; bad$stateinfo2$area.sqmi[bad$stateinfo2$ST=="US"] <- 0
  expect_error(release_geography_validate(bad),"US area")
  bad <- bundle; bad$countyinfo$waterarea.sqkm[1] <- -1
  expect_error(release_geography_validate(bad),"county information")
  bad <- bundle; attr(bad$counties_shapefile,"boundary_year") <- 2022L
  expect_error(release_geography_validate(bad),"Mixed boundary")
  bad <- bundle; bad$counties_shapefile$GEOID[1] <- bad$counties_shapefile$GEOID[2]
  expect_error(release_geography_validate(bad),"FIPS")
  bad <- bundle; bad$counties_shapefile <- bad$counties_shapefile[bad$counties_shapefile$GEOID!="09110",]
  bad$countyinfo <- bad$countyinfo[bad$countyinfo$FIPS!="09110",]
  expect_error(release_geography_validate(bad),"Connecticut")
  bad <- bundle; bad$counties_shapefile <- bad$counties_shapefile[bad$counties_shapefile$STATEFP!="72",]
  expect_error(release_geography_validate(bad),"coverage")
  bad <- bundle; bad$states_shapefile$AWATER[1] <- NA_real_
  expect_error(release_geography_validate(bad),"geometry/area")
  expect_identical(release_geography_boundary_year(counties_shapefile),2022L)
  bad <- counties_shapefile; attr(bad,"boundary_year") <- 2024L
  expect_error(release_geography_boundary_year(bad),"disagrees")
})

test_that("release boundaries require polygon geometries in every row", {
  bundle <- geography_fixture()
  expect_true(release_geography_validate(bundle))
  point <- sf::st_point(c(-75,40))
  line <- sf::st_linestring(matrix(c(-76,39,-75,40),ncol=2,byrow=TRUE))
  invalid <- list(point=point, line=line,
    multipoint=sf::st_multipoint(matrix(c(-76,39,-75,40),ncol=2,byrow=TRUE)),
    multiline=sf::st_multilinestring(list(unclass(line))),
    collection=sf::st_geometrycollection(list(point)))
  for (name in c("states_shapefile","counties_shapefile")) {
    for (geometry in invalid) {
      bad <- bundle
      geometries <- as.list(sf::st_geometry(bad[[name]]))
      # Corrupt a later row so checking only the first geometry cannot pass.
      geometries[[length(geometries)]] <- geometry
      sf::st_geometry(bad[[name]]) <- sf::st_sfc(geometries,crs=4269)
      expect_true(all(sf::st_is_valid(bad[[name]])))
      expect_false(any(sf::st_is_empty(bad[[name]])))
      expect_error(release_geography_validate(bad),
        paste0("Non-polygon boundary geometry: ",name),fixed=TRUE)
    }
    valid <- bundle
    polygons <- sf::st_geometry(valid[[name]])
    sf::st_geometry(valid[[name]]) <- sf::st_cast(polygons,"MULTIPOLYGON")
    expect_true(release_geography_validate(valid))
    mixed <- as.list(polygons)
    mixed[[length(mixed)]] <- sf::st_geometry(valid[[name]])[[length(mixed)]]
    sf::st_geometry(valid[[name]]) <- sf::st_sfc(mixed,crs=4269)
    expect_true(release_geography_validate(valid))
  }
})

test_that("release boundaries require finite positive geometry area", {
  bundle <- geography_fixture()
  for (area in c(0,NA_real_,Inf)) {
    with_mocked_bindings(
      expect_error(release_geography_validate(bundle),"Invalid geometry/area",fixed=TRUE),
      st_area=function(x,...) rep(area,nrow(x)), .package="sf")
  }
})

test_that("manifest readback rejects non-polygon boundary payloads", {
  skip_if_not_installed("openssl")
  bundle <- geography_fixture()
  folder <- withr::local_tempdir()
  payloads <- c("states_shapefile","counties_shapefile","stateinfo","stateinfo2")
  write_fixture <- function(candidate) {
    for (name in payloads) {
      save(list=name,envir=list2env(setNames(list(candidate[[name]]),name)),
        file=file.path(folder,paste0(name,".rda")),version=2)
    }
    utils::write.csv(candidate$countyinfo,file.path(folder,"countyinfo.csv"),row.names=FALSE)
    files <- file.path(folder,c(paste0(payloads,".rda"),"countyinfo.csv"))
    manifest <- list(schema_version=2L,boundary_year=2024L,
      files_sha256=as.list(setNames(release_geography_sha256(files),basename(files))))
    jsonlite::write_json(manifest,file.path(folder,"manifest.json"),auto_unbox=TRUE)
  }
  write_fixture(bundle)
  expect_true(release_geography_validate(release_geography_read(folder)))
  invalid <- list(sf::st_point(c(-75,40)),
    sf::st_linestring(matrix(c(-76,39,-75,40),ncol=2,byrow=TRUE)))
  for (name in c("states_shapefile","counties_shapefile")) {
    for (geometry in invalid) {
      bad <- bundle
      sf::st_geometry(bad[[name]]) <- sf::st_sfc(rep(list(geometry),nrow(bad[[name]])),crs=4269)
      write_fixture(bad)
      expect_error(release_geography_read(folder),
        paste0("Non-polygon boundary geometry: ",name),fixed=TRUE)
    }
  }
})

test_that("release link checks require complete inputs and expose mismatched crosswalks", {
  bundle <- geography_fixture()
  bg <- data.frame(bgfips="100010401001")
  attr(bg,"acs_version") <- "2020-2024"
  refs <- list(bundle=bundle,blockgroup_data=bg,
    bgid2fips=data.frame(bgid=1,bgfips=bg$bgfips),
    blockwts=data.frame(blockid=1,bgid=1,blockwt=1),
    blockid2fips=data.frame(blockid=1,blockfips="100010401001001"),
    blockpoints=data.frame(blockid=1,lat=39,lon=-75),
    quaddata=data.frame(blockid=1,BLOCK_X=1,BLOCK_Y=1,BLOCK_Z=1))
  expect_true(release_geography_assert_links(do.call(release_geography_check_links,refs)))
  islands <- refs
  islands$blockgroup_data <- rbind(bg,data.frame(bgfips=c("6000100","7801000620")))
  attr(islands$blockgroup_data,"acs_version") <- "2020-2024"
  ir <- do.call(release_geography_check_links,islands)
  expect_true(release_geography_assert_links(ir))
  expect_identical(ir$count[ir$check=="retained Island Area identifiers"],2L)
  bad <- refs; bad$blockgroup_data$bgfips <- "1000100"
  expect_error(release_geography_assert_links(do.call(release_geography_check_links,bad)),"FIPS schema")
  incomplete <- release_geography_check_links(bundle,bg)
  expect_true(any(incomplete$status=="not_checked"))
  expect_error(release_geography_assert_links(incomplete),"require attention")
  bad <- refs; bad$bgid2fips$bgfips <- "090010001001"
  expect_error(release_geography_assert_links(do.call(release_geography_check_links,bad)),"crosswalk")
  bad <- refs; bad$blockwts$bgid <- 2
  expect_error(release_geography_assert_links(do.call(release_geography_check_links,bad)),"blockwts bgids")
  bad <- refs; bad$blockpoints$blockid <- 2
  expect_error(release_geography_assert_links(do.call(release_geography_check_links,bad)),"block coverage")
  bad <- refs; bad$blockid2fips$blockfips <- "bad"
  expect_error(release_geography_assert_links(do.call(release_geography_check_links,bad)),"block FIPS")
  bad <- refs; attr(bad$blockgroup_data,"acs_version") <- "2018-2022"
  expect_error(release_geography_assert_links(do.call(release_geography_check_links,bad)),"ACS vintage")
  bad <- refs; bad$blockwts$blockwt <- Inf
  expect_error(release_geography_assert_links(do.call(release_geography_check_links,bad)),"blockwts values")
  bad <- refs; bad$blockwts$blockwt <- NULL
  expect_error(do.call(release_geography_check_links,bad),"missing rows/columns")
})

test_that("staging refuses overwrite before fetching any source", {
  existing <- tempfile(); dir.create(existing)
  on.exit(unlink(existing,recursive=TRUE),add=TRUE)
  writeLines("keep",file.path(existing,"keep.txt"))
  expect_error(release_geography_build(existing,2024),"non-existing")
  expect_identical(readLines(file.path(existing,"keep.txt")),"keep")
})


test_that("the release-input hold blocks downloads and output creation", {
  target <- tempfile("held-release-geography-")
  local_mocked_bindings(curl_download=function(...) stop("Unexpected download"),.package="curl")
  for (approval in list(FALSE,NA,NULL,"true",1)) {
    expect_error(release_geography_build(target,2024,approved=approval),"on hold")
    expect_false(file.exists(target))
  }
  expect_error(release_geography_build(target,2024),"on hold")
  expect_false(file.exists(target))
})

test_that("crosswalk observations are reported for review without altering IDs", {
  bundle <- geography_fixture()
  bg <- data.frame(bgfips="100010401001")
  attr(bg,"acs_version") <- "2020-2024"
  crosswalk <- data.frame(bgid=c(1,2),bgfips=c(bg$bgfips,"091104101022"))
  blocks <- data.frame(blockid=c(1,2),blockfips=rep("100010401001001",2))
  before_crosswalk <- crosswalk
  before_blocks <- blocks
  report <- release_geography_check_links(bundle,bg,bgid2fips=crosswalk,blockid2fips=blocks)
  expect_identical(report$status[report$check=="crosswalk blockgroups outside ACS"],"review")
  expect_identical(report$status[report$check=="block FIPS repeated across block IDs"],"review")
  expect_identical(report$status[report$check=="Census 2020 block FIPS schema"],"pass")
  expect_identical(report$status[report$check=="blockid2fips unique blockids"],"pass")
  expect_identical(crosswalk,before_crosswalk)
  expect_identical(blocks,before_blocks)
  expect_error(release_geography_assert_links(report),"do not change IDs or drop records")
})


test_that("release manifest hashing uses SHA-256", {
  skip_if_not_installed("openssl")
  path <- tempfile()
  on.exit(unlink(path),add=TRUE)
  writeChar("abc",path,eos=NULL)
  expect_identical(release_geography_sha256(path),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
})
