

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
#

# do tests of MODULES? ####
#
# if (!exists("mod_ejscreenapi_server")) {
#   cat("mod_ejscreenapi_server() is an unexported function -- cannot be tested without devtools::load_all() to test the local source version,
#       or using ::: to test the installed version")
# }
# # # attempting to be able to test a module... not working yet... need session, etc.
#
# test_that("mod_ejscreenapi_server  receives its input", {
#   skip_if_not(exists("mod_ejscreenapi_server"), message = "mod_ejscreenapi_server() not found, skipping test")
#    # unexported function, so would require using ::: or devtools::load_all()
#
#   shiny::testServer(mod_ejscreenapi_server, {
#     session$setInputs(pointsfile = list(datapath= system.file("testdata/latlon/"testpoints_5.xlsx")     )
#     expect_equal( output$count, 3)
#   })
# })
################################################# #

# > CLEANUP: rm() each global default value from this envt ####
#   DELETE EACH VARIABLE THAT WAS PUT IN GLOBAL ENVIRONMENT

rm(list = names(global_defaults_or_user_options))
rm(global_defaults_or_user_options)


################################################# #
