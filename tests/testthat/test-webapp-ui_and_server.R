

# devtools::load_all()  # need this if not yet done by testing setup

## source app-related scripts ?
# source('R/app_config.R')
# source('R/app_ui.R')
# source('R/app_server.R')
cat("NOTE: global_defaults_*.R are required - be aware of whether installed or local source version will be used by tests in test-ui_and_server.R \n")
# and  update_global_defaults_or_user_options() # is used by get_global_defaults_or_user_options()
global_defaults_or_user_options <- EJAM:::get_global_defaults_or_user_options(
  user_specified_options = list()
)
# app_ui() cannot be executed while global_defaults_package, global_defaults_shiny, etc have not yet been defined
# because EJAM:::global_or_param("fipspicker_fips_type2pick_default") is NULL but it tries to use that to define choices or other params of radioButtons() for example.
## try this approach (from the testthat.R file) of assigning to global envt those defaults so that they are available to app_ui and app_server:

################################# #
## this also needs to load global_defaults_ info
## that is normally saved in golem_opts during app_run() like...
global_defaults_or_user_options <- EJAM:::get_global_defaults_or_user_options(
  user_specified_options = list(), # list(...),
  bookmarking_allowed = "disable" # enableBookmarking
)
old_golem_options <- shiny::getShinyOption("golem_options")
shiny::shinyOptions(golem_options = global_defaults_or_user_options)
# app$appOptions$golem_options <- global_defaults_or_user_options
## but shinytest2 does not use app_run() so we need to do it here somehow...
## Try  saving the objects in the global envt ....
## but global_or_param() would find them but get_golem_options() would not?
## some had been done via get_golem_options() like these:
## could switch to use global_or_param() for those places in ui and server.
##  found  golem::get_golem_options("   replaced with EJAM:::global_or_param("
# use_shapefile_from_any
# default_shp_oktypes_1
# default_extratable_list_of_sections
# ejam_app_version
# default_extratable_hide_missing_rows_for

# > SETUP: assign each global default value to this envt ####
# but it won't be seen by app_ui() where it relies on fipspicker module during testing?
for (i in seq_along(global_defaults_or_user_options)) {
  assign(names(global_defaults_or_user_options)[i], (global_defaults_or_user_options[[i]]))
}
# rm(global_defaults_or_user_options)

# but now there are lots of default variables in the GLOBAL environment !
# yet trying to assign these to envt within the test_that({ }) did not get the test to work
################################# #
# do tests of ui, server ####

cat("\n NEED MORE UNIT TESTS OF SHINY APP IN test-ui_and_server.R \n\n")

# Configure   to fit your need.
# testServer() function makes it possible to test code in server functions and modules, without needing to run the full Shiny application

################################# # ################################# #
test_that("app ui", {

  if (!exists("app_ui")) {
    cat("app_ui() is an unexported function -- cannot be tested without devtools::load_all() to test the local source version,
      or using ::: to test the installed version")
  }
  skip_if_not(exists("app_ui"), message = "unexported function app_ui() not found, skipping test")


  ui <- app_ui() # unexported function, so would require using ::: or devtools::load_all()
  golem::expect_shinytaglist(ui)
  # Check that formals have not been removed
  fmls <- formals(app_ui)
  for (i in c("request")) {
    expect_true(i %in% names(fmls))
  }
})
################################# # ################################# #

test_that("app server is a function", {

  if (!exists("app_server")) {
    cat("app_server() is an unexported function -- cannot be tested without devtools::load_all() to test the local source version,
      or using ::: to test the installed version")
  }
  skip_if_not(exists("app_server"), message = "unexported function app_server() not found, skipping test")
  server <- app_server # unexported function, so would require using ::: or devtools::load_all()
  expect_type(server, "closure")
  # Check that formals have not been removed
  fmls <- formals( app_server) # unexported function, so would require using ::: or devtools::load_all()
  for (i in c("input", "output", "session")) {
    expect_true(i %in% names(fmls))
  }
})
################################# # ################################# #
test_that(
  "app_sys works and finds golem-config.yml", {

    if (!exists("app_sys")) {
      cat("app_sys() is an unexported function -- cannot be tested without devtools::load_all() to test the local source version,
      or using ::: to test the installed version")
    }
    skip_if_not(exists("app_sys"), message = "unexported function app_sys() not found, skipping test")
    expect_true(
      file.exists(
        app_sys("golem-config.yml") # this gets path to source version of .yml ## unexported function, so would require using ::: or devtools::load_all()
      )
      # != ""   #  source/EJAM/inst/golem-config.yml = installed/EJAM/golem-config.yml
    )
  }
)
################################# # ################################# #
test_that(
  "golem-config works and app is set as 'production' not  'dev' ", {
    if (!exists("get_golem_config")) {
      cat("get_golem_config() is an unexported function -- cannot be tested without devtools::load_all() to test the local source version,
      or using ::: to test the installed version")
    }
    skip_if_not(exists("app_sys"), message = "unexported function app_sys() not found, skipping test")
    config_file <- app_sys("golem-config.yml") # this gets path to source version of .yml # unexported function, so would require using ::: or devtools::load_all()
    #  source/EJAM/inst/golem-config.yml = installed/EJAM/golem-config.yml
    skip_if(config_file == "", message = "golem-config.yml file not found, skipping test")

    skip_if_not(exists("get_golem_config"), message = "get_golem_config not found, skipping test")
    expect_true(
      get_golem_config( # unexported function, so would require using ::: or devtools::load_all()
        "app_prod",
        config = "production",
        file = config_file
      )
    )
    expect_false(
      get_golem_config( # unexported function, so would require using ::: or devtools::load_all()
        "app_prod",
        config = "dev",
        file = config_file
      )
    )
  }
)
################################# # ################################# #

## TEST SERVER

################################################# #
### Configure these server test to work...

### testServer() function makes it possible to test code in server functions and modules, without needing to run the full Shiny application

### This works interactively or when running this test file via  test_active_file()

# ## this is not finished yet ***
#
# see # https://shiny.posit.co/r/reference/shiny/1.7.2/testserver
################################################# #

test_that(
  "app_server starts and input$radius_now can be set",
  {
    skip("Direct app_server test needs full shiny/golem session options; app launch is covered by shinytest2 tests.")

    testServer(app = app_server, expr = {

      # note app_server() is an unexported function

      ## Set and test an input  - but server code cannot run unless most inputs are defined (since inputs are often used in if () stmts) which happens in app_ui() in many cases.
      session$setInputs(radius_now = 1, max_miles = 10, radius_default = 3.14,
                        shiny.testmode = FALSE, testing = FALSE,
                        ss_choose_method = "upload", ss_choose_method_upload = "latlon")

      stopifnot(input$radius_now == 1)
      expect_equal(input$radius_now, 1)

      expect_equal(input$ss_choose_method, "upload")

      ### types of tests you can do on the server:

      ### - Checking reactiveValues

      ##  FAILS - this reactive does not get defined until app_ui() happens, which does not happen in this simple test.
      # expect_equal( sanitized_standard_analysis_title(), 'Summary of Analysis')

      ## FAILS
      # print(current_upload_method())


      ## - Checking outputs - not so relevant here since outputs happen after analysis, like map, table, download, etc.
      ## if map were already drawn...
      # expect_true("leaflet" %in% class(output$an_leaf_map) )

    })
  }
)
################################################# #

test_that("app_server clears stale lat/lon upload cap error before reading new file", {
  skip_if_not(exists("app_server"), message = "unexported function app_server() not found, skipping test")

  orig_global_or_param <- EJAM:::global_or_param
  local_mocked_bindings(
    global_or_param = function(vname) {
      if (vname %in% c(
        "default_hide_about_tab",
        "default_hide_written_report",
        "default_hide_plot_barplot_tab",
        "default_hide_plot_histo_tab"
      )) {
        return(FALSE)
      }
      orig_global_or_param(vname)
    },
    read_csv_or_xl = function(fname, ...) {
      if (identical(fname, "too-many-points.csv")) {
        return(data.frame(lat = c(38, 39), lon = c(-77, -78)))
      }
      if (identical(fname, "unreadable.csv")) {
        stop("cannot read uploaded file", call. = FALSE)
      }
      data.frame(lat = numeric(), lon = numeric())
    },
    .package = "EJAM"
  )

  testServer(app = app_server, expr = {
    session$setInputs(
      max_pts_upload = 1,
      testing = FALSE,
      ss_choose_method = "upload",
      ss_choose_method_upload = "latlon",
      ss_upload_latlon = data.frame(datapath = "too-many-points.csv")
    )

    expect_error(data_up_latlon(), "Too many points")
    expect_match(latlon_upload_error(), "Too many points")

    session$setInputs(
      ss_upload_latlon = data.frame(datapath = "unreadable.csv")
    )

    expect_error(data_up_latlon(), "cannot read uploaded file")
    expect_null(latlon_upload_error())
  })
})
################################################# #

test_that("app_server validates invalid FRS uploads without falling through to sitepoints", {
  skip_if_not(exists("app_server"), message = "unexported function app_server() not found, skipping test")

  orig_global_or_param <- EJAM:::global_or_param
  local_mocked_bindings(
    global_or_param = function(vname) {
      if (vname %in% c(
        "default_hide_about_tab",
        "default_hide_written_report",
        "default_hide_plot_barplot_tab",
        "default_hide_plot_histo_tab"
      )) {
        return(FALSE)
      }
      orig_global_or_param(vname)
    },
    read_csv_or_xl = function(fname, ...) {
      data.frame(id = "not-a-registry-id")
    },
    frs_is_valid = function(frs_upload) {
      FALSE
    },
    .package = "EJAM"
  )

  testServer(app = app_server, expr = {
    session$setInputs(
      testing = FALSE,
      ss_choose_method = "upload",
      ss_choose_method_upload = "FRS",
      ss_upload_frs = data.frame(datapath = "bad-frs.xlsx")
    )

    expect_error(data_up_frs(), "Records with invalid Registry IDs")
    expect_true(isTRUE(disable_buttons[["FRS"]]))
    expect_identical(invalid_alert[["FRS"]], 0)
    expect_null(an_map_text_pts[["FRS"]])
  })
})
################################################# #

test_that("app_server override latch: a programmatic set_site_method() write does not latch, but a real user change of the main radio does", {
  skip_if_not(exists("app_server"), message = "unexported function app_server() not found, skipping test")
  ## Item 2 regression (PR #420): set_site_method() records its own writes in site_method_last_set so the
  ## ss_choose_method observer can tell a programmatic update apart from a real user click. Only a user
  ## click latches site_method_user_override, which then protects the pick from the layer-2
  ## belt-and-suspenders ejamapp writes (each guarded by if (!site_method_user_override())).
  ## Mock global_or_param for the hide-tab flags so app_server init runs in testServer (same
  ## workaround the other testServer tests in this file use; golem_options isn't visible here).
  orig_global_or_param <- EJAM:::global_or_param
  local_mocked_bindings(
    global_or_param = function(vname) {
      if (vname %in% c("default_hide_about_tab", "default_hide_written_report",
                       "default_hide_plot_barplot_tab", "default_hide_plot_histo_tab")) {
        return(FALSE)
      }
      orig_global_or_param(vname)
    },
    .package = "EJAM"
  )
  testServer(app = app_server, expr = {
    session$setInputs(testing = FALSE)
    expect_false(site_method_user_override())                # no override at start

    set_site_method("upload", source = "test-programmatic")  # our own write -> records site_method_last_set("upload")
    session$setInputs(ss_choose_method = "upload")           # simulated radio round-trip to that same value
    expect_false(site_method_user_override())                # value == last_set -> NOT treated as a user change

    session$setInputs(ss_choose_method = "dropdown")         # user changes the MAIN radio to a different value
    expect_true(site_method_user_override())                 # latched -> now protected from layer-2 clobber
  })
})
################################################# #

test_that("app_server override latch: an advanced-tab Site Selection Method pick latches the override", {
  skip_if_not(exists("app_server"), message = "unexported function app_server() not found, skipping test")
  orig_global_or_param <- EJAM:::global_or_param
  local_mocked_bindings(
    global_or_param = function(vname) {
      if (vname %in% c("default_hide_about_tab", "default_hide_written_report",
                       "default_hide_plot_barplot_tab", "default_hide_plot_histo_tab")) {
        return(FALSE)
      }
      orig_global_or_param(vname)
    },
    .package = "EJAM"
  )
  testServer(app = app_server, expr = {
    session$setInputs(testing = FALSE)
    expect_false(site_method_user_override())
    session$setInputs(default_ss_choose_method = "upload")   # advanced-tab radio = explicit runtime choice (layer 3)
    expect_true(site_method_user_override())
  })
})
################################################# #

## Launch-URL / EJScreen "Send to EJAM" handoff regressions (PR #466, issue #465).
##
## The EJAM API serializes absent handoff-payload fields (sites/fips/shape/radius are
## R NULLs) as JSON {}, which jsonlite::fromJSON() parses back as a ZERO-LENGTH LIST,
## not NULL. Before the #466 fix, a radius-less handoff (every FIPS/polygon basket,
## and any point basket with no buffer) carried radius:{} into the launch observer's
## radius block, where as.numeric() of the empty list yielded numeric(0) and the if()
## evaluated a zero-length condition -- an unhandled error in the priority-1000 init
## observer that killed the whole Shiny session ("This app has stopped because of an
## error or a timeout"). These tests run the REAL launch observer via testServer()
## against the exact JSON text the API returns (served through a mocked httr2 fetch),
## so reintroducing the bug crashes the observer and fails the test. Verified: the
## three radius-less cases below fail on the pre-fix app_server with the production
## error signature; the with-radius / error-payload / direct-deep-link cases pass on
## both, locking in unchanged behavior for the already-working paths.
##
## Mock plumbing (all mocks must be in place BEFORE testServer() -- the launch
## observer reads session$clientData once at init and MockShinySession's clientData
## is static and non-reactive, always "?mocksearch=1"):
##  - shiny::parseQueryString  maps the mock search string to the launch query we want
##    (any other string passes through to the real parser);
##  - EJAM:::global_or_param   returns a fake ejamapi_baseurl so the ?handoff= fetch
##    has a resolvable API base, plus the usual hide-tab flags workaround the other
##    testServer tests above use;
##  - httr2::req_perform / resp_body_string  serve the canned handoff JSON for that
##    fake base's /handoff/ URL only (anything else passes through to real httr2).

## Bind the unexported app_server from the namespace so the handoff regression tests
## below run in BOTH contexts: devtools::test()/load_all() (where app_server is already
## a visible symbol) AND installed-package testing via test_check()/R CMD check (where
## it is not, and an exists()-based skip would silently drop this regression coverage --
## flagged by Copilot/Codex review on PR #466). Under load_all(), EJAM:::app_server is
## the same dev-source object, so binding unconditionally is safe in either context.
app_server <- EJAM:::app_server

testserver_with_launch_query <- function(query, handoff_json = NULL, expr) {
  orig_global_or_param <- EJAM:::global_or_param
  orig_parseQueryString <- shiny::parseQueryString
  orig_req_perform <- httr2::req_perform
  orig_resp_body_string <- httr2::resp_body_string
  testthat::with_mocked_bindings(
    global_or_param = function(vname) {
      if (vname %in% c("default_hide_about_tab", "default_hide_written_report",
                       "default_hide_plot_barplot_tab", "default_hide_plot_histo_tab")) {
        return(FALSE)
      }
      if (identical(vname, "ejamapi_baseurl")) return("http://ejam-api.invalid")
      orig_global_or_param(vname)
    },
    .package = "EJAM",
    testthat::with_mocked_bindings(
      parseQueryString = function(str, nested = FALSE) {
        if (identical(str, "?mocksearch=1")) return(query)
        orig_parseQueryString(str, nested = nested)
      },
      .package = "shiny",
      testthat::with_mocked_bindings(
        req_perform = function(req, ...) {
          if (grepl("^http://ejam-api\\.invalid/handoff/", req$url)) {
            return(structure(list(url = req$url), class = "ejam_test_handoff_response"))
          }
          orig_req_perform(req, ...)
        },
        resp_body_string = function(resp, ...) {
          if (inherits(resp, "ejam_test_handoff_response")) return(handoff_json)
          orig_resp_body_string(resp, ...)
        },
        .package = "httr2",
        expr
      )
    )
  )
}
################################################# #

test_that("handoff: FIPS basket (radius {}) loads FIPS and does not crash the session", {
  ## THE #465 crash case: a County/Tract selection sent via EJScreen "Send to EJAM".
  ## Payload is verbatim what the API returns for a FIPS basket (radius/sites/shape = {}).
  testserver_with_launch_query(
    query = list(handoff = "TESTTOKEN"),
    handoff_json = '{"method":["FIPS"],"sites":{},"fips":["10001","10003"],"shape":{},"radius":{}}',
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_identical(url_fips(), c("10001", "10003"))
      expect_null(url_radius())      # radius:{} means absent, not 0 and not an error
      expect_null(url_sitepoints())  # one place-type per launch
      expect_null(url_shapefile())
      expect_identical(site_method_last_set(), "upload")  # method was switched for the handoff
    })
  )
})
################################################# #

test_that("handoff: point basket with no buffer (radius {}) loads points and does not crash", {
  ## Same #465 crash for lat/lon selections made without a buffer: EJScreen's
  ## multisite.js only includes radius when a buffer is set, so the API returns radius:{}.
  testserver_with_launch_query(
    query = list(handoff = "TESTTOKEN"),
    handoff_json = '{"method":["latlon"],"sites":[{"lat":38.9072,"lon":-77.0369},{"lat":39.29,"lon":-76.61}],"fips":{},"shape":{},"radius":{}}',
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_identical(url_sitepoints(), data.frame(lat = c(38.9072, 39.29), lon = c(-77.0369, -76.61)))
      expect_null(url_radius())
      expect_null(url_fips())
      expect_identical(site_method_last_set(), "upload")
    })
  )
})
################################################# #

test_that("handoff: polygon basket (GeoJSON, radius {}) loads the shape and does not crash", {
  skip_if_not_installed("sf")
  ## Third #465 crash case: a drawn-polygon selection. shape arrives as GeoJSON text
  ## (a JSON string field), radius is absent ({}).
  geojson_txt <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[-77.05,38.90],[-77.00,38.90],[-77.00,38.95],[-77.05,38.95],[-77.05,38.90]]]}}]}'
  testserver_with_launch_query(
    query = list(handoff = "TESTTOKEN"),
    handoff_json = sprintf('{"method":["shape"],"sites":{},"fips":{},"shape":%s,"radius":{}}',
                           jsonlite::toJSON(geojson_txt, auto_unbox = TRUE)),
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_s3_class(url_shapefile(), "sf")  # stored parsed, so data_up_shp() reuses it
      expect_null(url_radius())
      expect_null(url_fips())
      expect_identical(site_method_last_set(), "upload")
    })
  )
})
################################################# #

test_that("handoff: point basket WITH a buffer still applies the radius (working path preserved)", {
  testserver_with_launch_query(
    query = list(handoff = "TESTTOKEN"),
    handoff_json = '{"method":["latlon"],"sites":[{"lat":38.9072,"lon":-77.0369}],"fips":{},"shape":{},"radius":[3]}',
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_identical(url_sitepoints(), data.frame(lat = 38.9072, lon = -77.0369))
      expect_identical(url_radius(), 3)
    })
  )
})
################################################# #

test_that("handoff: explicit radius 0 is accepted (valid no-buffer value for FIPS/polygon)", {
  ## Public-Environmental-Data-Partners/EJScreen#73 and
  ## Public-Environmental-Data-Partners/EJAM-API#49 make FIPS/shape handoffs carry an explicit radius 0;
  ## 0 must pass the >= 0 guard (minradius_shapefile is 0 = analyze inside the boundary).
  testserver_with_launch_query(
    query = list(handoff = "TESTTOKEN"),
    handoff_json = '{"method":["FIPS"],"sites":{},"fips":["10001"],"shape":{},"radius":[0]}',
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_identical(url_fips(), "10001")
      expect_identical(url_radius(), 0)
    })
  )
})
################################################# #

test_that("handoff: API error payload loads nothing and does not crash", {
  testserver_with_launch_query(
    query = list(handoff = "TESTTOKEN"),
    handoff_json = '{"error":["handoff token not found or expired"]}',
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_null(url_sitepoints())
      expect_null(url_fips())
      expect_null(url_shapefile())
      expect_null(url_radius())
      expect_null(site_method_last_set())  # method untouched when nothing loads
    })
  )
})
################################################# #

test_that("direct deep-link ?fips=&radius= still loads both (radius-guard refactor unchanged)", {
  testserver_with_launch_query(
    query = list(fips = "10001,10003", radius = "5"),
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_identical(url_fips(), c("10001", "10003"))
      expect_identical(url_radius(), 5)
    })
  )
})
################################################# #

test_that("direct deep-link ?fips= with no radius leaves url_radius NULL and does not crash", {
  ## as.numeric(NULL) is numeric(0); the length()==1 guard must skip it silently.
  testserver_with_launch_query(
    query = list(fips = "10001"),
    expr = testServer(app = app_server, expr = {
      session$setInputs(testing = FALSE)
      expect_identical(url_fips(), "10001")
      expect_null(url_radius())
    })
  )
})
################################################# #

test_that("shinytest category selection waits for input values and saves failure logs", {
  setup_file <- testthat::test_path("setup-shinytest2.R")
  setup_lines <- readLines(setup_file, warn = FALSE)
  setup_text <- paste(setup_lines, collapse = "\n")

  expect_match(
    setup_text,
    "wait_for_input_value <- function\\(input_id, expected = NULL",
    perl = TRUE
  )
  expect_match(
    setup_text,
    "wait_for_input_value(input_id, expected = expected)",
    fixed = TRUE ##
  )
  expect_match(
    setup_text,
    "select_upload_method <- function\\(upload_method\\)",
    perl = TRUE
  )
  expect_match(
    setup_text,
    "wait_for_upload_input_ready <- function\\(input_id",
    perl = TRUE
  )
  expect_match(
    setup_text,
    "upload_test_file <- function\\(input_id, paths",
    perl = TRUE
  )
  expect_match(
    setup_text,
    "upload_log_has_files <- function\\(input_id, expected_names\\)",
    perl = TRUE
  )
  upload_helper_match <- regexpr(
    paste0(
      "(?s)expect_uploaded_file <- function\\(input_id, expected_names\\).*?",
      "wait_for_upload_input_ready <- function"
    ),
    setup_text,
    perl = TRUE
  )
  expect_gt(upload_helper_match[1], 0)
  upload_helper_text <- regmatches(setup_text, upload_helper_match)
  expect_match(
    upload_helper_text,
    "upload_log_has_files(input_id, expected_names)",
    fixed = TRUE
  )
  expect_match(
    upload_helper_text,
    "wait_for_start_analysis_enabled()",
    fixed = TRUE
  )
  expect_false(grepl(
    "app\\$wait_for_value\\(",
    upload_helper_text,
    perl = TRUE
  ))
  expect_false(grepl(
    "shinyapp\\.\\$inputValues\\[id\\]",
    upload_helper_text,
    perl = TRUE
  ))
  expect_match(
    setup_text,
    "ejam_shinytest2_make_app_dir <- function\\(sourcefolder",
    perl = TRUE
  )
  expect_match(
    setup_text,
    "# Use installed EJAM by default; set EJAM_SHINYTEST2_USE_SOURCE=true to use source-tree loading.",
    fixed = TRUE
  )
  expect_match(
    setup_text,
    "use_source <- ejam_shinytest2_truthy_env\\(\"EJAM_SHINYTEST2_USE_SOURCE\"\\)",
    perl = TRUE
  )
  expect_match(
    setup_text,
    "select_upload_method\\(\"FRS\"\\)\\s*\\n\\s*upload_test_file\\(\"ss_upload_frs\"",
    perl = TRUE
  )
  expect_match(
    setup_text,
    "save_log\\(paste0\\(test_category, \"-category-selection-log\\.txt\"\\)\\)",
    fixed = FALSE
  )
  expect_match(
    setup_text,
    "test_log_dir <- file.path(tempdir(), \"ejam-shinytest2-logs\")",
    fixed = TRUE
  )
  expect_false(grepl(
    "test_log_dir <- testthat::test_path(\"_logs\")",
    setup_text,
    fixed = TRUE
  ))
  expect_false(grepl(
    paste0(
      "ss_upload_frs = EJAM:::app_sys\\(\"testdata/registryid/frs_testpoints_10\\.xlsx\"\\)\\)",
      "\\s*\\n\\s*app\\$wait_for_idle\\(timeout = 60 \\* 1000\\)"
    ),
    setup_text,
    perl = TRUE
  ))
})
################################################# #

test_that("shinytest upload log detection accepts AppDriver upload messages", {
  expect_true(exists("shinytest2_upload_log_has_files"))

  logs <- data.frame(
    message = c(
      "{shinytest2} R info Uploading file(s) for id: /tmp/counties_in_Delaware.xlsx",
      "{shinytest2} R info Finished uploading file"
    ),
    stringsAsFactors = FALSE
  )

  expect_true(
    shinytest2_upload_log_has_files(
      logs,
      input_id = "ss_upload_fips",
      expected_names = "counties_in_Delaware.xlsx"
    )
  )
})
################################################# #
#

# do tests of MODULES? ####

# # #   to be able to test a module... not working yet... need session, etc.

################################################# #

# > CLEANUP: rm() each global default value from this envt ####
#   DELETE EACH VARIABLE THAT WAS PUT IN GLOBAL ENVIRONMENT

rm(list = names(global_defaults_or_user_options))
shiny::shinyOptions(golem_options = old_golem_options)
rm(old_golem_options)
rm(global_defaults_or_user_options)


################################################# #
# Item 4: default_site_method back-compat alias (param renamed from default_upload_dropdown) #

test_that("global_or_param() resolves default_upload_dropdown as a back-compat alias for default_site_method", {
  prev <- shiny::getShinyOption("golem_options")
  on.exit(shiny::shinyOptions(golem_options = prev), add = TRUE)

  # only the OLD key is set -> the new name still resolves (alias fallback)
  shiny::shinyOptions(golem_options = list(default_upload_dropdown = "dropdown"))
  expect_equal(EJAM:::global_or_param("default_site_method"), "dropdown")

  # the NEW key is set -> resolves directly
  shiny::shinyOptions(golem_options = list(default_site_method = "upload"))
  expect_equal(EJAM:::global_or_param("default_site_method"), "upload")

  # both set -> the new (canonical) key wins over the old alias
  shiny::shinyOptions(golem_options = list(default_site_method = "mapclick", default_upload_dropdown = "dropdown"))
  expect_equal(EJAM:::global_or_param("default_site_method"), "mapclick")

  # a name with no alias is unaffected (no spurious fallback) -> NULL when unset
  shiny::shinyOptions(golem_options = list())
  expect_null(EJAM:::global_or_param("a_param_with_no_such_name_xyz"))
})

################################################# #

test_that("upload-type choices include FIPS in public and non-public configs", {
  # ?fips= deep links (and the EJScreen "Send to EJAM" handoff of FIPS place
  # selections) programmatically select the FIPS upload type via
  # updateSelectInput(), which silently keeps the old selection when the
  # requested value is not among the configured choices. So FIPS must be
  # present in default_choices_for_type_of_site_upload even when isPublic =
  # TRUE (regression test: the public config used to omit it, which made
  # ?fips= deep links a silent no-op on the hosted app).
  old_golem <- shiny::getShinyOption("golem_options")
  on.exit(shiny::shinyOptions(golem_options = old_golem), add = TRUE)
  g_public <- EJAM:::get_global_defaults_or_user_options(
    user_specified_options = list(isPublic = TRUE), bookmarking_allowed = "disable")
  expect_true("FIPS" %in% g_public$default_choices_for_type_of_site_upload)
  g_private <- EJAM:::get_global_defaults_or_user_options(
    user_specified_options = list(isPublic = FALSE), bookmarking_allowed = "disable")
  expect_true("FIPS" %in% g_private$default_choices_for_type_of_site_upload)
})
