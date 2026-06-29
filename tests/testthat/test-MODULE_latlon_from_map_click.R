

# Tests for the click-on-map point-accumulator module (R/MODULE_latlon_from_map_click.R).
# These run without a browser (shiny::testServer), covering the two modes the app relies on:
# standalone (the module owns the map) and embedded (the EJAM app owns an_leaf_map and passes
# its click/remove/clear events in as reactives - this is how the 'mapclick' ss_choose_method works).

test_that("MODULE_SERVER_latlon_from_map_click accumulates/removes/clears points (standalone mode)", {
  rd <- shiny::reactiveVal(data.frame(lat = numeric(0), lon = numeric(0)))

  shiny::testServer(
    EJAM:::MODULE_SERVER_latlon_from_map_click,
    args = list(id = "TESTID", reactdat = rd),
    {
      expect_s3_class(reactdat, "reactiveVal")
      expect_equal(NROW(reactdat()), 0)

      # click the map -> append a point (leaflet sends $lat and $lng)
      session$setInputs(mymap_click = list(lat = 40, lng = -99))
      expect_equal(NROW(reactdat()), 1)
      expect_equal(reactdat()$lat, 40)
      expect_equal(reactdat()$lon, -99)

      # a second click -> two points
      session$setInputs(mymap_click = list(lat = 34.05, lng = -118.25))
      expect_equal(NROW(reactdat()), 2)

      # clicking an existing point's marker (layerId == row index) removes just that one
      session$setInputs(mymap_marker_click = list(id = "1", lat = 40, lng = -99))
      expect_equal(NROW(reactdat()), 1)
      expect_equal(reactdat()$lat, 34.05)

      # clear -> empty
      session$setInputs(clear_points = 1)
      expect_equal(NROW(reactdat()), 0)
    }
  )
})

test_that("MODULE_SERVER_latlon_from_map_click works embedded (render_map = FALSE) via external reactives", {
  rd <- shiny::reactiveVal(data.frame(lat = numeric(0), lon = numeric(0)))
  ac <- shiny::reactiveVal(NULL)  # stands in for reactive(input$an_leaf_map_click)
  rc <- shiny::reactiveVal(NULL)  # stands in for reactive(input$an_leaf_map_marker_click)
  cl <- shiny::reactiveVal(NULL)  # stands in for reactive(input$mapclick_clear)

  shiny::testServer(
    EJAM:::MODULE_SERVER_latlon_from_map_click,
    args = list(id = "TESTID", reactdat = rd,
                add_click = ac, remove_click = rc, clear = cl, render_map = FALSE),
    {
      expect_equal(NROW(reactdat()), 0)

      ac(list(lat = 40,    lng = -99));     session$flushReact()
      ac(list(lat = 34.05, lng = -118.25)); session$flushReact()
      expect_equal(NROW(reactdat()), 2)

      # remove the first point by its layer id
      rc(list(id = "1", lat = 40, lng = -99)); session$flushReact()
      expect_equal(NROW(reactdat()), 1)
      expect_equal(reactdat()$lat, 34.05)

      # clear all
      cl(1); session$flushReact()
      expect_equal(NROW(reactdat()), 0)
    }
  )
})

test_that("MODULE_UI_latlon_from_map_click builds a tagList and keeps the id formal", {
  ui <- EJAM:::MODULE_UI_latlon_from_map_click(id = "TESTID")
  golem::expect_shinytaglist(ui)
  fmls <- formals(EJAM:::MODULE_UI_latlon_from_map_click)
  expect_true("id" %in% names(fmls))
})
