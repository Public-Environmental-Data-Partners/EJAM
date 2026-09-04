####################################################### #
# TO TRY THE EJAM plumber API ON A LOCAL SERVER ####
####################################################### #
#
# The local API is a composite of two routers (see plumber.R in this folder):
#
#  ROOT   = verbatim mirror of the deployed EJAM-API (ejam-api/rest_controller.r;
#           see ejam-api/SYNC.md), so /report, /data, /query, /handoff and the
#           Swagger docs at /__docs__/ behave like https://api.ejanalysis.com
#  /draft = draft endpoints that exist only in this package (draft/plumber.R):
#           /draft/echo, /draft/ejamit, /draft/ejamit_csv, /draft/report2,
#           /draft/reportpost, /draft/ejam2report, /draft/ejam2excel,
#           /draft/getblocksnearby, /draft/get_blockpoints_in_shape,
#           /draft/doaggregate
#
# START IT (in a background R process; returns a handle you can $kill()):

apiproc <- EJAM:::ejamapi_local()
# or serve only the deployed-API mirror, without drafts:
# apiproc <- EJAM:::ejamapi_local(drafts = FALSE)

## to use the CURRENT CHECKED-OUT LOCAL SOURCE version of EJAM & these files:
# library(EJAM); devtools::load_all(".")   # then ejamapi_local() as above
## NOTE: rendering PDF reports locally requires pandoc
##  (e.g., Sys.setenv(RSTUDIO_PANDOC = ...) if running outside RStudio).

####################################################### #
# TRY IT ####

test_host <- "127.0.0.1"
test_port <- 3035
test_url <- paste0("http://", test_host, ":", test_port)

if (FALSE) {

  ############## #
  # interactive docs (Swagger UI); the root path redirects here too
  browseURL(paste0(test_url, "/__docs__/"))

  ############## #
  # deployed-API endpoints, served locally at the same paths as production

  # single-site report (defaults to pdf, like production)
  browseURL(paste0(test_url, "/report?lat=34.05&lon=-118.24&radius=3"))
  # ... as html
  browseURL(paste0(test_url, "/report?lat=34.05&lon=-118.24&radius=3&fileextension=html"))
  # multisite (comma-separated), aggregate report
  browseURL(paste0(test_url, "/report?lat=34,35&lon=-118,-117&sitenumber=0"))
  # per-site report labeled "Site 3" (EJAM#470 / EJAM-API#51)
  browseURL(paste0(test_url, "/report?lat=34.05&lon=-118.24&sitenumber=3"))
  # FIPS report; buffer defaults to 0 for fips/shape (EJAM-API#49)
  browseURL(paste0(test_url, "/report?fips=10001"))

  # data endpoint (POST)
  df <- EJAM::ejamapi(fips = "10001", scale = "blockgroup", endpoint = "data",
                      baseurl = paste0(test_url, "/"))

  # query endpoint (POST; paginated as of EJAM-API#32)
  req <- httr2::request(paste0(test_url, "/query")) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(attribute = "pctlowinc", value = 0.9, page = 1, limit = 100)
  out <- httr2::resp_body_json(httr2::req_perform(req))
  str(out$pagination)

  # handoff round trip (POST a payload, get a token, GET it back)
  tok <- httr2::request(paste0(test_url, "/handoff")) |>
    httr2::req_body_json(list(fips = list("10001"))) |>
    httr2::req_perform() |> httr2::resp_body_json()
  httr2::request(paste0(test_url, "/handoff/", tok$token)) |>
    httr2::req_perform() |> httr2::resp_body_json()

  ############## #
  # draft-only endpoints, at /draft

  browseURL(paste0(test_url, "/draft/echo?msg=asdf"))

  urlx <- paste0(test_url, "/draft/getblocksnearby?lat=33&lon=-99&radius=2")
  outx <- httr2::req_perform(httr2::request(urlx))
  s2b <- data.table::rbindlist(httr2::resp_body_json(outx))

  # precalculated sample result, as json or csv
  browseURL(paste0(test_url, "/draft/ejamit?test=true"))
  browseURL(paste0(test_url, "/draft/ejamit_csv?lon=-101&lat=36&radius=1"))

  ############## #
  # stop the background server when done
  apiproc$kill()
}

####################################################### #
# PREVIEWING A PROPOSED EJAM-API CHANGE ####
#
# 1. Edit inst/plumber/ejam-api/rest_controller.r locally (normally verbatim --
#    edits are ONLY for previewing a change you intend to propose upstream).
# 2. ejamapi_local() (after devtools::load_all() or reinstall) and test it here.
# 3. Submit the identical diff as a PR to
#    https://github.com/Public-Environmental-Data-Partners/EJAM-API
#    then re-sync the mirror after it merges (see ejam-api/SYNC.md).
#
####################################################### #
# Help/notes on plumber APIs:
#
# browseURL("https://www.rplumber.io/articles/quickstart.html")
# browseURL("https://www.rplumber.io/articles/routing-and-input.html")
#
# input parsers: parser_csv(), parser_json(), parser_multi(), parser_read_file(), ...
# output serializers: serializer_json(), serializer_csv(), serializer_html(),
#   as_attachment(), and @serializer contentType for full control of the response
#   (used by the /report endpoints and /draft/ejam2excel).
# static files: @assets (the mirror serves ./assets at /assets; mounting static
#   files at root "/" would shadow the /__docs__/ Swagger UI).
# plumber.maxRequestSize option limits request body size (default unlimited).
####################################################### #
