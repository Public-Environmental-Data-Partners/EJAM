####################################################### #
# Local experimental endpoints only.  ejamapi_local() mounts this router at
# /draft; do not move these routes into the EJAM-API production mirror.
####################################################### #
library(EJAM)
library(jsonlite)
library(sf)
library(geojsonsf)

#* @apiTitle EJAM draft API endpoints
#* @apiDescription Experimental local endpoints mounted below /draft. They are not hosted at api.ejanalysis.com.

# Errors return the response object with its body already set, so they bypass
# the route's @serializer. That keeps a JSON error intact on the xlsx and
# octet-stream routes, where a serializer would otherwise mangle it.
api_error <- function(res, message, status = 400L) {
  res$status <- status
  res$setHeader("Content-Type", "application/json")
  res$body <- as.character(jsonlite::toJSON(list(error = list(code = paste0("http_", status), message = message)), auto_unbox = TRUE))
  res
}
html_error <- function(res, message, status = 400L) {
  res$status <- status
  res$setHeader("Content-Type", "text/html")
  res$body <- paste0("<html><body><h3>Error</h3><p>", htmltools::htmlEscape(message), "</p></body></html>")
  res
}
api_one <- function(x) if (length(x)) x[[1]] else NULL
api_empty <- function(x) is.null(x) || !length(x) || identical(api_one(x), "")
api_bool <- function(x, name) {
  if (is.logical(x) && length(x) == 1 && !is.na(x)) return(x)
  y <- tolower(as.character(api_one(x)))
  if (y %in% c("true", "false")) return(identical(y, "true"))
  stop(name, " must be true or false")
}
api_num <- function(x, name, positive = FALSE) {
  y <- suppressWarnings(as.numeric(api_one(x)))
  if (length(y) != 1 || is.na(y) || !is.finite(y) || (positive && y <= 0)) stop(name, if (positive) " must be a finite positive number" else " must be a finite number")
  y
}
api_values <- function(x, name, numeric = FALSE) {
  if (api_empty(x)) return(NULL)
  if (is.list(x) && !is.data.frame(x)) x <- unlist(x, use.names = FALSE)
  y <- trimws(unlist(strsplit(paste(as.character(x), collapse = ","), ",", fixed = TRUE), use.names = FALSE))
  if (!length(y) || any(!nzchar(y))) stop(name, " must not contain empty values")
  if (!numeric) return(y)
  z <- suppressWarnings(as.numeric(y)); if (anyNA(z) || any(!is.finite(z))) stop(name, " must contain only finite numbers")
  z
}
api_shape <- function(x) {
  if (api_empty(x)) return(NULL)
  if (is.list(x) && !is.character(x)) x <- jsonlite::toJSON(x, auto_unbox = TRUE)
  y <- tryCatch(geojsonsf::geojson_sf(api_one(x)), error = function(e) e)
  if (inherits(y, "error")) stop("shape must be valid GeoJSON")
  y
}

# Flat request adapter. Exactly one location mode is accepted.
normalize_request <- function(sites = NULL, lat = NULL, lon = NULL, fips = NULL,
                              shape = NULL, radius = NULL, buffer = NULL,
                              radius_donut_lower_edge = 0, subgroups_type = "nh",
                              include_ejindexes = TRUE, calculate_ratios = TRUE,
                              extra_demog = TRUE, need_proximityscore = FALSE,
                              showdrinkingwater = TRUE, showpctowned = TRUE) {
  # buffer is an alias for radius. Compare numerically, so 1 and 1.0 agree.
  if (!api_empty(buffer) && !api_empty(radius) && api_num(buffer, "buffer") != api_num(radius, "radius")) stop("radius and buffer conflict; use radius")
  if (api_empty(radius)) radius <- buffer
  if (!api_empty(sites) && (!api_empty(lat) || !api_empty(lon))) stop("supply sites or lat/lon, not both")
  modes <- c(!api_empty(sites) || !api_empty(lat) || !api_empty(lon), !api_empty(fips), !api_empty(shape))
  if (sum(modes) != 1) stop("supply exactly one of sites/lat-lon, fips, or shape")
  # Like ejamit(): points default to 3 miles and need a positive radius; FIPS
  # and shapes default to 0 (the areas themselves) and accept 0.
  radius <- if (api_empty(radius)) { if (modes[[1]]) 3 else 0 } else api_num(radius, "radius")
  if (modes[[1]] && radius <= 0) stop("radius must be a finite positive number for sites/lat-lon")
  if (radius < 0) stop("radius must not be negative")
  args <- list(radius = radius, radius_donut_lower_edge = api_num(radius_donut_lower_edge, "radius_donut_lower_edge"), subgroups_type = as.character(api_one(subgroups_type)), include_ejindexes = api_bool(include_ejindexes, "include_ejindexes"), calculate_ratios = api_bool(calculate_ratios, "calculate_ratios"), extra_demog = api_bool(extra_demog, "extra_demog"), need_proximityscore = api_bool(need_proximityscore, "need_proximityscore"), showdrinkingwater = api_bool(showdrinkingwater, "showdrinkingwater"), showpctowned = api_bool(showpctowned, "showpctowned"))
  if (modes[[1]]) {
    if (!api_empty(sites)) { sites <- as.data.frame(sites); if (!all(c("lat", "lon") %in% names(sites))) stop("sites must contain lat and lon"); latv <- suppressWarnings(as.numeric(sites$lat)); lonv <- suppressWarnings(as.numeric(sites$lon))
    } else { if (api_empty(lat) || api_empty(lon)) stop("lat and lon must be supplied together"); latv <- api_values(lat, "lat", TRUE); lonv <- api_values(lon, "lon", TRUE) }
    if (!length(latv) || length(latv) != length(lonv) || anyNA(latv) || anyNA(lonv) || any(abs(latv) > 90) || any(abs(lonv) > 180)) stop("lat and lon must be equal-length valid coordinates")
    args$sitepoints <- data.frame(lat = latv, lon = lonv); method <- "latlon"
  } else if (modes[[2]]) { args$fips <- api_values(fips, "fips"); method <- "fips"
  } else { args$shapefile <- api_shape(shape); method <- "shape" }
  list(args = args, location_method = method)
}

to_json_safe <- function(x) { if (inherits(x, "data.frame")) return(as.data.frame(x, stringsAsFactors = FALSE)); if (is.list(x)) return(lapply(x, to_json_safe)); x }
analysis_keys <- c("radius", "radius_donut_lower_edge", "subgroups_type", "include_ejindexes", "calculate_ratios", "extra_demog", "need_proximityscore", "showdrinkingwater", "showpctowned")
bundle_from_result <- function(result, request) {
  list(schema_version = "ejam-analysis-v1", producer = list(ejam_version = as.character(utils::packageVersion("EJAM")), data_vintage = NA_character_), input = list(location_method = request$location_method, site_count = if (!is.null(request$args$sitepoints)) nrow(request$args$sitepoints) else if (!is.null(request$args$fips)) length(request$args$fips) else if (!is.null(request$args$shapefile)) nrow(request$args$shapefile) else NA_integer_), parameters = request$args[intersect(names(request$args), analysis_keys)], results = to_json_safe(result), metadata = list())
}
bundle_to_result <- function(bundle) {
  if (!is.list(bundle) || !identical(bundle$schema_version, "ejam-analysis-v1") || !is.list(bundle$results)) stop("analysis_bundle must be a supported ejam-analysis-v1 document")
  out <- bundle$results
  for (nm in intersect(names(out), c("results_overall", "results_bysite", "results_bybg_people", "formatted", "longnames"))) if (is.list(out[[nm]])) out[[nm]] <- data.table::as.data.table(out[[nm]])
  out
}
run_analysis <- function(request) do.call(EJAM::ejamit, request$args)

render_report <- function(result, fileextension = "html", sitenumber = NULL, report_title = NULL, analysis_title = NULL, show_ratios_in_report = TRUE, extratable_show_ratios_in_report = TRUE, extratable_title = "") {
  ext <- tolower(as.character(api_one(fileextension))); if (!ext %in% c("html", "pdf")) stop("fileextension must be html or pdf")
  site <- if (api_empty(sitenumber) || identical(as.character(api_one(sitenumber)), "overall")) NULL else api_num(sitenumber, "sitenumber")
  args <- list(ejamitout = result, sitenumber = site, fileextension = ext, report_title = report_title, analysis_title = analysis_title, show_ratios_in_report = api_bool(show_ratios_in_report, "show_ratios_in_report"), extratable_show_ratios_in_report = api_bool(extratable_show_ratios_in_report, "extratable_show_ratios_in_report"), extratable_title = extratable_title, launch_browser = FALSE)
  if (identical(ext, "html")) return(do.call(EJAM::ejam2report, c(args, list(return_html = TRUE))))
  path <- do.call(EJAM::ejam2report, args); if (!is.character(path) || !file.exists(path)) stop("EJAM did not create a readable PDF")
  readBin(path, "raw", n = file.info(path)$size)
}
report_ext <- function(fileextension) { ext <- tolower(as.character(api_one(fileextension))); if (length(ext) != 1 || !ext %in% c("html", "pdf")) stop("fileextension must be html or pdf"); ext }
render_excel <- function(result, analysis_title = "EJAM analysis") { wb <- EJAM::ejam2excel(result, save_now = FALSE, launchexcel = FALSE, interactive_console = FALSE, analysis_title = analysis_title); path <- tempfile(fileext = ".xlsx"); on.exit(unlink(path), add = TRUE); openxlsx::saveWorkbook(wb, path, overwrite = TRUE); readBin(path, "raw", n = file.info(path)$size) }
# Set the body on the response object and return it, so plumber sends the bytes
# as-is instead of passing them through the route's @serializer.
send_binary <- function(res, value, type, filename, disposition = "attachment") { res$setHeader("Content-Type", type); res$setHeader("Content-Disposition", paste0(disposition, '; filename="', filename, '"')); res$body <- value; res }
send_report <- function(res, value, fileextension) { if (identical(tolower(as.character(api_one(fileextension))), "pdf")) send_binary(res, value, "application/pdf", "EJAM_results.pdf", "inline") else send_binary(res, value, "text/html", "EJAM_results.html", "inline") }

# Return one requested artifact or a manifest-bearing ZIP. `run_analysis()` is
# deliberately called once here; all wrappers share this implementation.
render_outputs <- function(request, outputs, res, sitenumber = NULL, analysis_title = "EJAM analysis") {
  outputs <- unique(tolower(api_values(outputs, "outputs"))); if (!length(outputs) || any(!outputs %in% c("html", "pdf", "xlsx", "json"))) stop("outputs must contain html, pdf, xlsx, and/or json")
  result <- run_analysis(request); bundle <- bundle_from_result(result, request); artifacts <- list()
  if ("json" %in% outputs) artifacts[["EJAM_analysis.json"]] <- charToRaw(jsonlite::toJSON(bundle, auto_unbox = TRUE, null = "null", dataframe = "rows"))
  if ("html" %in% outputs) artifacts[["EJAM_results.html"]] <- charToRaw(render_report(result, "html", sitenumber, analysis_title = analysis_title))
  if ("pdf" %in% outputs) artifacts[["EJAM_results.pdf"]] <- render_report(result, "pdf", sitenumber, analysis_title = analysis_title)
  if ("xlsx" %in% outputs) artifacts[["EJAM_results.xlsx"]] <- render_excel(result, analysis_title)
  if (length(artifacts) == 1) { name <- names(artifacts)[[1]]; type <- if (grepl("json$", name)) "application/json" else if (grepl("html$", name)) "text/html" else if (grepl("pdf$", name)) "application/pdf" else "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"; return(send_binary(res, artifacts[[1]], type, name, if (type %in% c("text/html", "application/pdf")) "inline" else "attachment")) }
  dir <- tempfile("ejam-api-"); dir.create(dir); on.exit(unlink(dir, recursive = TRUE), add = TRUE); files <- file.path(dir, names(artifacts)); for (i in seq_along(files)) writeBin(artifacts[[i]], files[[i]])
  manifest <- list(schema_version = bundle$schema_version, producer = bundle$producer, parameters = bundle$parameters, files = lapply(files, function(x) list(filename = basename(x), bytes = file.size(x), md5 = unname(tools::md5sum(x)))))
  manifest_file <- file.path(dir, "manifest.json"); writeLines(jsonlite::toJSON(manifest, auto_unbox = TRUE, pretty = TRUE), manifest_file)
  archive <- tempfile(fileext = ".zip"); on.exit(unlink(archive), add = TRUE); oldwd <- setwd(dir); on.exit(setwd(oldwd), add = TRUE); utils::zip(archive, files = basename(c(files, manifest_file)))
  send_binary(res, readBin(archive, "raw", n = file.info(archive)$size), "application/zip", "EJAM_artifacts.zip")
}

#* @filter logger
function(req, res) plumber::forward()

#* @get /ejamit
#* @serializer json
#* @tag Draft API Endpoints
function(lat = NULL, lon = NULL, fips = NULL, radius = NULL, buffer = NULL, test = NULL, res) tryCatch({ if (!api_empty(test)) stop("test mode is no longer supported; supply lat/lon or fips"); x <- normalize_request(lat = lat, lon = lon, fips = fips, radius = radius, buffer = buffer); bundle_from_result(run_analysis(x), x) }, error = function(e) api_error(res, conditionMessage(e)))

#* @post /ejamit
#* @serializer json
#* @tag Draft API Endpoints
function(sites = NULL, fips = NULL, shape = NULL, radius = NULL, buffer = NULL, radius_donut_lower_edge = 0, subgroups_type = "nh", include_ejindexes = TRUE, calculate_ratios = TRUE, extra_demog = TRUE, need_proximityscore = FALSE, showdrinkingwater = TRUE, showpctowned = TRUE, res) tryCatch({ x <- normalize_request(sites = sites, fips = fips, shape = shape, radius = radius, buffer = buffer, radius_donut_lower_edge = radius_donut_lower_edge, subgroups_type = subgroups_type, include_ejindexes = include_ejindexes, calculate_ratios = calculate_ratios, extra_demog = extra_demog, need_proximityscore = need_proximityscore, showdrinkingwater = showdrinkingwater, showpctowned = showpctowned); bundle_from_result(run_analysis(x), x) }, error = function(e) api_error(res, conditionMessage(e)))

#* @post /ejam2report
#* @serializer contentType list(type = "application/octet-stream")
#* @tag Draft API Endpoints
function(analysis_bundle, sitenumber = NULL, fileextension = "html", report_title = NULL, analysis_title = NULL, show_ratios_in_report = TRUE, extratable_show_ratios_in_report = TRUE, extratable_title = "", res) tryCatch(send_report(res, render_report(bundle_to_result(analysis_bundle), fileextension, sitenumber, report_title, analysis_title, show_ratios_in_report, extratable_show_ratios_in_report, extratable_title), fileextension), error = function(e) html_error(res, conditionMessage(e), 422L))

#* @post /ejam2excel
#* @serializer contentType list(type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @tag Draft API Endpoints
function(analysis_bundle, analysis_title = "EJAM analysis", res) tryCatch(send_binary(res, render_excel(bundle_to_result(analysis_bundle), analysis_title), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "EJAM_results.xlsx"), error = function(e) api_error(res, conditionMessage(e), 422L))

#* @get /reportnew
#* @serializer contentType list(type = "application/octet-stream")
#* @tag Draft API Endpoints
function(lat = NULL, lon = NULL, fips = NULL, radius = NULL, buffer = NULL, fileextension = "html", sitenumber = NULL, res) tryCatch(render_outputs(normalize_request(lat = lat, lon = lon, fips = fips, radius = radius, buffer = buffer), report_ext(fileextension), res, sitenumber), error = function(e) html_error(res, conditionMessage(e)))

#* @post /reportnew
#* @serializer contentType list(type = "application/octet-stream")
#* @tag Draft API Endpoints
function(sites = NULL, fips = NULL, shape = NULL, radius = NULL, buffer = NULL, fileextension = "html", sitenumber = NULL, analysis_title = "EJAM analysis", res) tryCatch(render_outputs(normalize_request(sites = sites, fips = fips, shape = shape, radius = radius, buffer = buffer), report_ext(fileextension), res, sitenumber, analysis_title), error = function(e) html_error(res, conditionMessage(e)))

#* @get /excel
#* @serializer contentType list(type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @tag Draft API Endpoints
function(lat = NULL, lon = NULL, fips = NULL, radius = NULL, buffer = NULL, analysis_title = "EJAM analysis", res) tryCatch(render_outputs(normalize_request(lat = lat, lon = lon, fips = fips, radius = radius, buffer = buffer), "xlsx", res, analysis_title = analysis_title), error = function(e) api_error(res, conditionMessage(e)))

#* @post /excel
#* @serializer contentType list(type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @tag Draft API Endpoints
function(sites = NULL, fips = NULL, shape = NULL, radius = NULL, buffer = NULL, analysis_title = "EJAM analysis", res) tryCatch(render_outputs(normalize_request(sites = sites, fips = fips, shape = shape, radius = radius, buffer = buffer), "xlsx", res, analysis_title = analysis_title), error = function(e) api_error(res, conditionMessage(e)))

#* @get /all
#* @serializer contentType list(type = "application/octet-stream")
#* @tag Draft API Endpoints
function(lat = NULL, lon = NULL, fips = NULL, radius = NULL, buffer = NULL, outputs, sitenumber = NULL, res) tryCatch(render_outputs(normalize_request(lat = lat, lon = lon, fips = fips, radius = radius, buffer = buffer), outputs, res, sitenumber), error = function(e) api_error(res, conditionMessage(e)))

#* @post /all
#* @serializer contentType list(type = "application/octet-stream")
#* @tag Draft API Endpoints
function(sites = NULL, fips = NULL, shape = NULL, radius = NULL, buffer = NULL, outputs, sitenumber = NULL, analysis_title = "EJAM analysis", res) tryCatch(render_outputs(normalize_request(sites = sites, fips = fips, shape = shape, radius = radius, buffer = buffer), outputs, res, sitenumber, analysis_title), error = function(e) api_error(res, conditionMessage(e)))

#* @get /getblocksnearby
#* @serializer json
#* @tag Draft API Endpoints
function(lat, lon, radius, attachment = FALSE, res) tryCatch({ latv <- api_values(lat, "lat", TRUE); lonv <- api_values(lon, "lon", TRUE); if (length(latv) != length(lonv) || any(abs(latv) > 90) || any(abs(lonv) > 180)) stop("lat and lon must be equal-length valid coordinates"); out <- EJAM::getblocksnearby(data.frame(lat = latv, lon = lonv), radius = api_num(radius, "radius", TRUE)); if (api_bool(attachment, "attachment")) plumber::as_attachment(out, "getblocksnearby.json") else out }, error = function(e) api_error(res, conditionMessage(e)))

#* @post /get_blockpoints_in_shape
#* @serializer json
#* @tag Draft API Endpoints
function(polys, addedbuffermiles = 0, dissolved = FALSE, safety_margin_ratio = 1.1, attachment = FALSE, res) tryCatch({ out <- EJAM::get_blockpoints_in_shape(polys = api_shape(polys), addedbuffermiles = api_num(addedbuffermiles, "addedbuffermiles"), dissolved = api_bool(dissolved, "dissolved"), safety_margin_ratio = api_num(safety_margin_ratio, "safety_margin_ratio", TRUE)); if (api_bool(attachment, "attachment")) plumber::as_attachment(out, "blockpoints_in_shape.json") else out }, error = function(e) api_error(res, conditionMessage(e)))

#* @get /echo
#* @serializer json
#* @tag Draft API Endpoints
function(msg = "") list(msg = paste0("The message is: '", msg, "'"))
