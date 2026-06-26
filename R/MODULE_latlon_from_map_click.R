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
## copied to the UI
# MODULE_UI_latlon_from_map_click("pts_entry_table2")

## copied to the server
# testpoints_template <-  testpoints_5[1:2, ]
# reactive_data1 <-  reactiveVal(testpoints_template)
# MODULE_SERVER_latlon_from_map_click(id = "pts_entry_table2", reactdat = reactive_data1)

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

    shiny::helpText("Click on the map to add one or more points. ",
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
#' @noRd
#'
MODULE_SERVER_latlon_from_map_click <- function(id,
                                                reactdat,  # reactiveVal holding the data.frame of lat,lon points; the module appends a row to it for each map click
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

      shiny::observeEvent(input$mymap_click, {   # WHEN MAP IS CLICKED, APPEND THAT LAT,LON AS A NEW POINT
        click <- input$mymap_click
        if (is.null(click)) {return()}
        # APPEND the clicked point to the accumulated table of points
        # (leaflet sends the clicked location as $lat and $lng)
        newpt <- data.frame(lat = click$lat, lon = click$lng)
        reactdat(rbind(latlon_only(reactdat()), newpt))
      })

      shiny::observeEvent(input$undo_point, {    # REMOVE THE MOST RECENTLY ADDED POINT
        cur <- latlon_only(reactdat())
        if (NROW(cur) > 0) {
          reactdat(cur[-NROW(cur), , drop = FALSE])
        }
      })

      shiny::observeEvent(input$clear_points, {  # REMOVE ALL POINTS
        reactdat(data.frame(lat = numeric(0), lon = numeric(0)))
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
                                radius = 4, color = "red", fillColor = "red",
                                fillOpacity = 1, stroke = FALSE,
                                popup = labels, label = labels)
        }
      })

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

      # undo removes the most recent point
      session$setInputs(undo_point = 1)
      stopifnot(NROW(reactdat()) == 1)

      # clear removes all points
      session$setInputs(clear_points = 1)
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
