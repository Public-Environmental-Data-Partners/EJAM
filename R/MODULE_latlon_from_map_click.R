################################################ ################################################# #

# This file is a shiny Module
# for selecting sites by user clicking on a map to get lat,lon values, and
# adjusting the radius of the circle shown on the map around each point.

# The module lets the user click the map to add ONE OR MORE points. It accumulates
# those clicks into a data.frame of lat,lon values (stored in the reactive `reactdat`)
# that an "outer" app can read and use (e.g., as the list of sites to analyze in EJAM).

# It also has notes on and is a demo of how to use reactives as inputs/outputs of a module,
# and how to call a module from an outer overall app.

################################################ ################################################# #

# *How to use reactives as inputs/outputs of a module  ####
#
# If a module needs to use a reactive expression, the outer function should take the reactive expression as a parameter.
# If a module wants to return reactive expressions to the calling app, then return a list of reactive expressions from the function.
# If a module needs to access an input that isn’t part of the module, the
#   containing app should pass the input value wrapped in a reactive expression (i.e. reactive(...)):
#   myModule("myModule1", reactive(input$checkbox1))

################################################ ################################################# #

# *How to call a module from outer overall app ####
#
## (A) STANDALONE mode - the module draws its own map (good for testing on its own)
## copied to the UI
# MODULE_UI_latlon_from_map_click("pts_entry_table2")
## copied to the server
# testpoints_template <-  testpoints_5[1:2, ]
# reactive_data1 <-  reactiveVal(testpoints_template)
# MODULE_SERVER_latlon_from_map_click(id = "pts_entry_table2", reactdat = reactive_data1)
#
## (B) EMBEDDED mode - the OUTER app already owns the map (e.g. EJAM's an_leaf_map).
##     The module is used only as a point accumulator: no UI is added, and the
##     outer app passes its own map events in as reactives. render_map = FALSE.
## copied to the server (no module UI needed - the app's existing map is reused):
# mapclick_points <- reactiveVal(data.frame(lat = numeric(0), lon = numeric(0)))
# MODULE_SERVER_latlon_from_map_click(
#   id           = "mapclick",
#   reactdat     = mapclick_points,
#   add_click    = reactive(input$an_leaf_map_click),         # add a point where the user clicks the map
#   remove_click = reactive(input$an_leaf_map_marker_click),  # remove the point the user clicks on
#   clear        = reactive(input$mapclick_clear),            # a "Clear all points" button in the app
#   render_map   = FALSE
# )
## then feed mapclick_points() into the app's data_uploaded() the same way uploaded lat/lon are handled.

################################################ ################################################# #

# THE MODULE ####

##################################################### #

# MODULE UI

#' MODULE_UI_latlon_from_map_click- latlon_from_map_click UI code
#'
#' @description A shiny Module.
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#'
MODULE_UI_latlon_from_map_click <- function(id) {

  radiusdefault = 3

  ns <- shiny::NS(id)
  shiny::tagList(

    # show SLIDER & MAP

    shiny::sliderInput(inputId = ns('pointradius_input'),
      'Point Radius (miles)', min = 1, max = 10, value = radiusdefault),

    shiny::helpText("Click on the map to add points. Click a point again to remove it. ",
                    "Move the slider to change the radius drawn around each point."),

    leaflet::leafletOutput(
      ns("mymap")
    ),

    shiny::br(),

    # let the user remove the most recent point or start over
    shiny::actionButton(inputId = ns("undo_point"),  label = "Undo last point",
                        class = 'usa-button usa-button--outline'),
    shiny::actionButton(inputId = ns("clear_points"), label = "Clear all points",
                        class = 'usa-button usa-button--outline'),

    shiny::br()
  )
}
##################################################### #

# MODULE SERVER code

#' MODULE_SERVER_latlon_from_map_click - latlon_from_map_click Server code
#'
#' @description
#' Accumulates one or more lat,lon points the user selects, and returns them as a
#' reactive data.frame (columns lat, lon). It runs in either of two modes:
#'
#' * **Standalone** (default, `render_map = TRUE`): the module renders its own
#'   leaflet map (via `MODULE_UI_latlon_from_map_click()`) and uses its own map
#'   click, marker click, "Undo last point" and "Clear all points" controls.
#'   Good for testing the module by itself.
#'
#' * **Embedded in a larger app** (`render_map = FALSE`): the outer app already
#'   owns a leaflet map, a radius slider, and the circle drawing. The module is
#'   used only as a reusable *point accumulator* - the outer app passes its map
#'   events in as reactives (`add_click`, `remove_click`, `clear`) and the module
#'   just maintains `reactdat` (append on add, drop one on remove, empty on
#'   clear). This is how the EJAM app can bind clicks on its existing
#'   `an_leaf_map` to a points table without the module drawing a second map.
#'
#' @param id module id
#' @param reactdat a reactiveVal holding the data.frame of points; the module
#'   appends/removes rows. The output is always normalized to columns lat, lon.
#' @param add_click optional reactive returning the latest "add a point" click as
#'   a list with `$lat` and `$lng` (e.g. `reactive(input$an_leaf_map_click)`).
#'   If NULL and `render_map = TRUE`, the module's own `input$mymap_click` is used.
#' @param remove_click optional reactive returning the latest "remove this point"
#'   click as a list carrying a layer `$id` (e.g.
#'   `reactive(input$an_leaf_map_marker_click)`); `$id` is the 1-based row index
#'   of the point to drop. If `$id` is absent but `$lat`/`$lng` are present, the
#'   nearest point is removed. If NULL and `render_map = TRUE`, the module's own
#'   `input$mymap_marker_click` is used.
#' @param clear optional reactive/event that, when it fires, empties all points
#'   (e.g. `reactive(input$mapclick_clear)`). If NULL and `render_map = TRUE`, the
#'   module's own "Clear all points" button is used.
#' @param render_map if TRUE (default) the module renders its own demo map, slider
#'   and Undo/Clear buttons. Set FALSE when the outer app owns the map.
#' @param enabled optional reactive returning TRUE only while this module should act.
#'   When an outer app shares one map across several site-selection modes, pass e.g.
#'   `reactive(current_upload_method() == "mapclick")` so map clicks accumulate/remove
#'   points only while the map-click mode is selected. NULL (default) = always on.
#'
#' @noRd
#'
MODULE_SERVER_latlon_from_map_click <- function(id,
                                                reactdat,     # reactiveVal holding the data.frame of lat,lon points
                                                add_click    = NULL, # reactive() of the outer app's map click (list with $lat,$lng)
                                                remove_click = NULL, # reactive() of the outer app's marker/shape click (list with $id)
                                                clear        = NULL, # reactive()/event that empties all points
                                                render_map   = TRUE, # FALSE when the outer app owns the map
                                                enabled      = NULL, # reactive() returning TRUE only while this module should act; NULL = always on
                                                ...) {

  # if instead of this being a param passed here, you were to initialize the reactive data.frame of lat,lon points that will be output of this function:
  # reactdat <- shiny::reactiveVal(data.frame(lat = numeric(0), lon = numeric(0)))

  #################################### #
  shiny::moduleServer(
    id = id,
    function(input, output, session) {
      ns <- session$ns

      # Helper: coerce whatever is in reactdat() down to a clean data.frame of just lat,lon (dropping rows without valid lat/lon).
      # This lets the module accept an initial/seed table that may have extra columns (e.g. testpoints_10 has sitenumber, sitename),
      # while the module's own output is always a simple lat,lon table.
      latlon_only <- function(x) {
        if (is.data.frame(x) && all(c("lat", "lon") %in% names(x)) && NROW(x) > 0) {
          out <- data.frame(lat = as.numeric(x$lat), lon = as.numeric(x$lon))
          out <- out[!is.na(out$lat) & !is.na(out$lon), , drop = FALSE]
          rownames(out) <- NULL
          out
        } else {
          data.frame(lat = numeric(0), lon = numeric(0))
        }
      }

      # ---- accumulator operations (the reusable core, shared by both modes) ----
      add_point <- function(lat, lon) {
        if (length(lat) != 1 || length(lon) != 1) {return(invisible())}
        if (is.na(suppressWarnings(as.numeric(lat))) || is.na(suppressWarnings(as.numeric(lon)))) {return(invisible())}
        reactdat(rbind(latlon_only(reactdat()),
                       data.frame(lat = as.numeric(lat), lon = as.numeric(lon))))
      }
      remove_point_by_index <- function(i) {        # i is a 1-based row index (e.g. a leaflet layerId)
        cur <- latlon_only(reactdat())
        i <- suppressWarnings(as.integer(i))
        if (length(i) == 1 && !is.na(i) && i >= 1 && i <= NROW(cur)) {
          reactdat(cur[-i, , drop = FALSE])
        }
      }
      remove_last <- function() {
        cur <- latlon_only(reactdat())
        if (NROW(cur) > 0) {reactdat(cur[-NROW(cur), , drop = FALSE])}
      }
      clear_all <- function() {reactdat(data.frame(lat = numeric(0), lon = numeric(0)))}

      # When `enabled` is supplied (a reactive), the module only acts while it returns TRUE.
      # This matters when an outer app shares ONE map across several modes: map clicks must not
      # accumulate/remove points unless this module's mode is the active one. NULL = always on.
      # Read inside the (isolated) observeEvent handlers below, so toggling `enabled` does NOT
      # re-fire the observers (no replay of the last click when switching INTO the active mode).
      is_enabled <- function() {
        if (is.null(enabled)) {return(TRUE)}
        isTRUE(tryCatch(enabled(), error = function(e) FALSE))
      }

      # Guard so the map click that may coincide with a delete (marker) click does not re-add a point.
      # Most leaflet vector-layer clicks do not bubble to the map's click event, but this is a defensive,
      # order-independent, auto-expiring guard. Non-reactive on purpose - mutated with <<-.
      last_remove_time <- NULL

      # ---- choose event sources for the two modes ----
      add_source    <- if (!is.null(add_click))    {add_click}    else if (render_map) {shiny::reactive(input$mymap_click)}        else {NULL}
      remove_source <- if (!is.null(remove_click)) {remove_click} else if (render_map) {shiny::reactive(input$mymap_marker_click)} else {NULL}

      # REMOVE one point. Defined BEFORE the ADD observer so it runs first within a reactive flush.
      if (!is.null(remove_source)) {
        shiny::observeEvent(remove_source(), {
          if (!is_enabled()) {return()}   # ignore marker clicks unless this module's mode is active
          mc <- remove_source()
          if (is.null(mc)) {return()}
          last_remove_time <<- Sys.time()
          if (!is.null(mc$id)) {
            remove_point_by_index(mc$id)                 # leaflet layerId == 1-based row index
          } else if (!is.null(mc$lat) && !is.null(mc$lng)) {
            cur <- latlon_only(reactdat())               # no layerId: remove the nearest existing point
            if (NROW(cur) > 0) {
              d <- (cur$lat - mc$lat)^2 + (cur$lon - mc$lng)^2
              remove_point_by_index(which.min(d))
            }
          }
        # ignoreInit not set: the startup NULL is skipped by ignoreNULL (default TRUE);
        # do NOT use ignoreInit = TRUE here - with a reactive() event source it would also swallow the first real click.
        })
      }

      # ADD one point
      if (!is.null(add_source)) {
        shiny::observeEvent(add_source(), {
          if (!is_enabled()) {return()}   # ignore map clicks unless this module's mode is active
          click <- add_source()
          if (is.null(click)) {return()}
          # Skip ONLY the map click that coincides with a just-performed delete (marker) click,
          # i.e. the same interaction, so we don't delete-then-re-add a point. Two safeguards keep
          # this from ever dropping a deliberate add:
          #  - clear the guard on EVERY add evaluation (so it cannot persist to a later click - important
          #    because leaflet vector-layer clicks often do NOT bubble to the map click, meaning no
          #    coincident add ever arrives to consume the guard); and
          #  - use a very tight window: a coincident click lands in the same reactive flush (~0 ms),
          #    whereas any deliberate follow-up click is far slower than this.
          coincident_with_delete <- !is.null(last_remove_time) &&
            as.numeric(difftime(Sys.time(), last_remove_time, units = "secs")) < 0.1
          last_remove_time <<- NULL
          if (coincident_with_delete) {return()}
          add_point(click$lat, click$lng)                # leaflet sends clicked location as $lat and $lng
        }) # ignoreInit deliberately not set (see remove observer note above)
      }

      # CLEAR all points (outer app's clear event, if provided).
      # An actionButton clear source starts at 0 (not NULL), so this may fire once at startup,
      # which is harmless (clearing an already-empty set).
      if (!is.null(clear)) {
        shiny::observeEvent(clear(), {if (is_enabled()) {clear_all()}})
      }
      # the module's own Undo/Clear buttons (standalone mode only)
      if (render_map) {
        shiny::observeEvent(input$clear_points, {clear_all()})
        shiny::observeEvent(input$undo_point,  {remove_last()})
      }

      # ---- standalone demo map (only when the module owns the map) ----
      if (render_map) {

        output$mymap <- leaflet::renderLeaflet({  # DRAW BASIC MAP
          # Use leaflet() here, and only include aspects of map that won't need to change dynamically
          # (at least, not unless the entire map is being torn down and recreated).
          leaflet::leaflet() %>%
            leaflet::setView(-99, 40, zoom = 4)  %>%
            leaflet::addProviderTiles(
              leaflet::providers$CartoDB.Positron,
              options = leaflet::providerTileOptions(noWrap = TRUE)
            )
        })

        shiny::observe({   # REDRAW ALL POINTS WHENEVER THE POINTS OR THE RADIUS SLIDER CHANGE
          df <- latlon_only(reactdat())
          radius_miles <- input$pointradius_input
          if (is.null(radius_miles)) {radius_miles <- 3}

          # clear everything previously drawn, then redraw all current points.
          # Note: circles are "shapes", center dots are "markers" - clear both (the old code only cleared markers, which never removed the circles).
          proxy <- leaflet::leafletProxy("mymap", session) %>%
            leaflet::clearShapes() %>%
            leaflet::clearMarkers() %>%
            leaflet::clearPopups()

          if (NROW(df) > 0) {
            ids <- as.character(seq_len(NROW(df)))       # layerId == row index, so clicking a dot removes that point
            labels <- paste0("Point ", seq_len(NROW(df)), ": ",
                             # Note slight changes can occur in lat,lon values if using paste() instead of format() as per ?as.character()
                             round(df$lat, 5), ", ", round(df$lon, 5))
            proxy %>%
              leaflet::addCircles(lng = df$lon, lat = df$lat,
                                  radius = radius_miles * meters_per_mile,   # radius in meters; changes when slider is used
                                  fillOpacity = 0.1, color = "#3388ff",
                                  highlightOptions = leaflet::highlightOptions(fillOpacity = 0.5, bringToFront = TRUE), # shaded when mouse hovers over the circle
                                  popup = labels, label = labels) %>%
              leaflet::addCircleMarkers(lng = df$lon, lat = df$lat,    # a small visible dot at each clicked point's center
                                  layerId = ids,        # clicking a dot fires input$mymap_marker_click with $id = this index
                                  radius = 4, color = "red", fillColor = "red",
                                  fillOpacity = 1, stroke = FALSE,
                                  popup = labels, label = labels)
          }
        })
      }

      # return the reactive data.frame of lat,lon values (one row per clicked point)
      return( reactdat ) # no parentheses here - return the reactive object not just its current value
    })
}
################################################ ################################################# #


################################################ ################################################# #
# . ####
# Try it out (from a simplified app, a test version of outer overall app) ####

try_this_module_here <- FALSE # so that installation will not source this and launch the module as a mini app

#   try_this_module_here <- TRUE
if (try_this_module_here) {
  ## Set up so it works here (if the packages were not attached, etc.) ####
  ## This test only would work after sourcing this whole file first, or after installing and loading EJAM to have the module and the sourcing this simplified outer overall app

  # cat('also see   module latlontypedin \n')

  ## to start from a clean slate:

  # rm(list = ls())
  # golem::detach_all_attached()
  # pkgs <- 'EJAM'
  ### pkgs <- c('shiny', 'leaflet', 'magrittr')
  # for (pkg in pkgs) {require(pkg, character.only = TRUE)}
  ### must attach all of those for this to work when testing the app separate from EJAM package
  #
  ################################################# #

  # SIMPLIFIED OVERALL APP ####
  ################################################# #

  #  UI of an overall outer app

  APP_UI_TEST <- function(request) {

    shiny::fluidPage(
      shiny::h2('module for EJAM'),

      ################################# #
      ##  THE MODULE'S UI SHOULD APPEAR HERE, NAMELY THE MAP YOU CAN CLICK ON AND THE SLIDER
      MODULE_UI_latlon_from_map_click("TESTID_latlon_from_map_click_module"),
      ################################# #

      # shiny::actionButton(inputId =  "latlon_from_map_click_submit_button_TEST",
      # label = "Done picking point (may not want this button - just a way to close any modal)"),

      # h3("Example of a live map of results of module, drawn in the parent app"),
      # leaflet::leafletOutput( ('map_click_module'), height = '600px', width = '100%'),

      shiny::h3("Example of a live view of the points (data) updated by the module, as seen in the parent app as a data.table"),
      shiny::verbatimTextOutput(outputId = "latlon_from_map_click_count_TEST"),
      DT::DTOutput(outputId =  "latlon_from_map_click_TEST" ),
      shiny::br()
    )}
  ################################################# #

  #  SERVER of an overall app

  APP_SERVER_TEST <- function(input, output, session) {

    # Start with an empty lat,lon table so the table clearly fills in as the user clicks the map.
    # (You could instead seed it with e.g. testpoints_10[1:2, ] - the module keeps only the lat,lon columns and appends to them.)
    init_data <- data.frame(lat = numeric(0), lon = numeric(0))
    # The module updates that reactive_data1 as the user clicks points on the map
    reactive_data1 <-  shiny::reactiveVal(init_data)

    ################################# #
    ##  THE MODULE'S SERVER CODE SHOULD GET RUN HERE
    MODULE_SERVER_latlon_from_map_click( id = "TESTID_latlon_from_map_click_module"  ,  reactdat = reactive_data1 )
    # if you had to pass a points table that is the reactive reactive_data1() ,  must pass it with with NO parens
    # and it should get changed by the module as the user clicks on the map in the module
    ################################# #

    # to view actual table in rendered form to be ready to display it in app UI
    shiny::observe({
      tmp <- reactive_data1() # reactiveVal(out())  # WHEN THIS VALUE CHANGES, THE OUTER APP SHOULD UPDATE THE RENDERED TABLE
      output$latlon_from_map_click_count_TEST <- shiny::renderText(paste0(NROW(tmp), " point(s) selected by clicking the map"))
      output$latlon_from_map_click_TEST <- DT::renderDT(DT::datatable(  tmp  ))
    })  # %>%  bindEvent(input$latlontypedin_submit_button_TEST)   # (when the "Done entering points" button is pressed? but that is inside the module)


    # ## to map those points here also ?
    # output$map_click_module <- leaflet::renderLeaflet({
    #   mypoints <- reactive_data1()
    #   names(mypoints) <- gsub('lon','longitude', names(mypoints)); names(mypoints) <- gsub('lat','latitude', names(mypoints))
    #   if (length(mypoints) != 0) {
    #     isolate({ # do not redraw entire map and zoom out and reset location viewed unless...?
    #       mymap <- leaflet(mypoints) %>% addTiles()  %>%
    #         addCircles(lat = ~latitude, lng = ~longitude,
    #                    radius = 10000 ,  # radius_miles() * meters_per_mile,
    #                    color = "red", fillColor = "red", fill = TRUE,
    #                    # color = base_color(), fillColor = base_color(), fill = TRUE, weight = circleweight,
    #                    popup = popup_from_any(mypoints)   )
    #       mymap
    #     })
    #   } else {  # length(mypoints) == 0
    #     mymap <- leaflet() %>% addTiles() %>% setView(-110, 46, zoom = 3)
    #     mymap
    #   }
    # }) # end map


  } # end of test server

  ## Run the simplified app ####

  shiny::shinyApp(ui = APP_UI_TEST, server = APP_SERVER_TEST)


}
################################################ ################################################# #

# *How to run automated tests on a module: ####
# (does not need a browser - simulates clicks via session$setInputs)

## (A) STANDALONE mode - the module owns the map; clicks arrive on input$mymap_*
if (1 == 0) {
  shiny::testServer(
    app = MODULE_SERVER_latlon_from_map_click,
    args = list(reactdat = shiny::reactiveVal(data.frame(lat = numeric(0), lon = numeric(0)))),
    {
      # no points yet
      stopifnot(NROW(reactdat()) == 0)

      # simulate a first map click -> one row appended
      session$setInputs(mymap_click = list(lat = 40, lng = -99))
      stopifnot(NROW(reactdat()) == 1)
      stopifnot(reactdat()$lat == 40 && reactdat()$lon == -99)

      # simulate a second map click -> two rows
      session$setInputs(mymap_click = list(lat = 34.05, lng = -118.25))
      stopifnot(NROW(reactdat()) == 2)

      # undo removes the most recent point (does not engage the delete-click guard)
      session$setInputs(undo_point = 1)
      stopifnot(NROW(reactdat()) == 1)
      stopifnot(reactdat()$lat == 40)

      # add it back, then click an existing point (marker) to remove just that one (layerId == row index)
      session$setInputs(mymap_click = list(lat = 34.05, lng = -118.25))
      stopifnot(NROW(reactdat()) == 2)
      session$setInputs(mymap_marker_click = list(id = "1", lat = 40, lng = -99))
      stopifnot(NROW(reactdat()) == 1)
      stopifnot(reactdat()$lat == 34.05)

      # clear removes all points
      session$setInputs(clear_points = 1)
      stopifnot(NROW(reactdat()) == 0)
    }
  )
}

## (B) EMBEDDED mode - the outer app owns the map; events arrive via reactives.
##     render_map = FALSE, and add_click / remove_click / clear are reactiveVals we drive.
if (1 == 0) {
  rd <- shiny::reactiveVal(data.frame(lat = numeric(0), lon = numeric(0)))
  ac <- shiny::reactiveVal(NULL) # stands in for reactive(input$an_leaf_map_click)
  rc <- shiny::reactiveVal(NULL) # stands in for reactive(input$an_leaf_map_marker_click)
  cl <- shiny::reactiveVal(NULL) # stands in for reactive(input$mapclick_clear)
  shiny::testServer(
    app = MODULE_SERVER_latlon_from_map_click,
    args = list(reactdat = rd, add_click = ac, remove_click = rc, clear = cl, render_map = FALSE),
    {
      stopifnot(NROW(reactdat()) == 0)

      ac(list(lat = 40,    lng = -99));     session$flushReact()
      ac(list(lat = 34.05, lng = -118.25)); session$flushReact()
      stopifnot(NROW(reactdat()) == 2)

      rc(list(id = "1", lat = 40, lng = -99)); session$flushReact() # remove the first point
      stopifnot(NROW(reactdat()) == 1 && reactdat()$lat == 34.05)

      cl(1); session$flushReact()  # clear all
      stopifnot(NROW(reactdat()) == 0)
    }
  )
}
################################################ ################################################# #


################################################ ################################################# #

## example of Module code to re-add to app_server.R when using this module
## *Latitude Longitude* click on LOCATION  (conditional panel)  ------------------------------------- - ####

# conditionalPanel(
#   condition = "input.ss_choose_method == 'upload' && input.ss_choose_method_upload == 'latlon_from_map_click'",
#   ### input: latlon_from_map_click
#   ## _+++ MODULE_UI_latlon_from_map_click  ####
#   tags$p("Click on a map to specify the latitude and longitude of one or more points to analyze"),
#   column(
#     6,
#     ## on button click, show modal with the map and the accumulating lat lon values
#     actionButton(inputId = 'show_latlon_from_map_click_module_button', label = "Click on a map to specify lat lon values", class = 'usa-button usa-button--outline'),
#     shinyBS::bsModal(
#       trigger = 'show_latlon_from_map_click_module_button',
#       id = 'view_latlon_from_map_click',
#       size = 'large',
#       title = 'Location data',
#       br(),
#
#       MODULE_UI_latlon_from_map_click(id = "pts_entry_table2"),  # this shows the thing here
#
#       # actionButton(inputId = 'latlon_from_map_click_submit_button', label = 'Done selecting point', class = 'usa-button usa-button--outline'),
#       ## use download buttons for speed and handling larger data
#       # downloadButton('download_sites_before_analysis_csv', label = 'CSV',   class = 'usa-button'),
#       # downloadButton('download_sites_before_analysis_xl',  label = 'Excel', class = 'usa-button'),
#
#       # verbatimTextOutput("test_textout"),
#       br()
#     ),
#   ),
#   # tags$span(
#   #   tags$ul(
#   #     tags$li('Required Columns: lat, lon'),
#   #     tags$li('Optional Columns: siteid')
#   #   )
#   # ),
#   # actionButton(inputId = 'latlon_help', label='More Info', class = 'usa-button usa-button--outline'),
#   # HTML(latlon_help_msg)
#   br()
# ),     # end   latlon_from_map_click   conditionalPanel
################################################################# #
