
###################################################################### #
if (1 == 0) {

  # to simplify calling this function from a NON-shiny context, to avoid saying shapefix(shp)[['shp']]
  # Check shiny::!is_running()  and if so, set attributes to shp returned
  # so the attributes provide these values like num_valid_pts_uploaded_SHP
  # or it could be a module


  ## added this to  shapefile_from_any() (but not each of the helper functions it uses for each file type)

  shp <- shapefix(shp)


  ##  add this to shiny app_server.R, replacing similar code that was being used there:
  ## or if server uses shapefile_from_any() then this has already been done

  shp <- shapefix(shp)
  if (!is.null(attr(shp, "disable_buttons_SHP"))) {disable_buttons[['SHP']] <- attr(shp, "disable_buttons_SHP")}
  if (!is.null(attr(shp, "num_valid_pts_uploaded_SHP"))) {num_valid_pts_uploaded[['SHP']] <- attr(shp, "num_valid_pts_uploaded_SHP")}
  if (!is.null(attr(shp, "invalid_alert_SHP"))) {invalid_alert[['SHP']] <- attr(shp, "invalid_alert_SHP")}
  if (!is.null(attr(shp, "an_map_text_shp")))  {an_map_text[['SHP']] <- attr(shp, "an_map_text_shp")}
  # do we need to remove those attributes now, or just leave them there?
}
###################################################################### #


#' shapefix cleans a spatial data.frame, flags invalid rows, add id if missing, etc.
#' @description a way for app_server, and ejamit() via shapefile_from_any(),
#'  to both use this one function to do the same thing
#'  whether or not in a reactive context
#'
#' @details This function only *reports* problems - it never decides what to do about them.
#'   Findings come back as attributes on the returned object, and each caller reacts as suits it:
#'
#'   - the **web app** (app_server.R) reads the attributes, shows `validate_errmsg` via
#'     [shiny::validate()], and disables the Start button.
#'   - **[ejamit()]**, via [shapefile_from_any()], ignores the attributes entirely.
#'
#'   That asymmetry is deliberate. Uploading points to the app's "Shapefile of polygons"
#'   option is blocked, because that option's radius slider starts at `minradius_shapefile = 0`
#'   and points buffered by 0 miles would find no blocks - the app has a separate
#'   "Latitude/Longitude file upload" option for points-with-buffers. But an R user calling
#'   `ejamit(shapefile = <points>, radius = 3)` supplies a real radius, so that works and is
#'   not blocked here. See issue #550.
#'
#'   Because the decision belongs to the caller, this function deliberately does NOT test
#'   [shiny::isRunning()]. An earlier version did, which meant the point-geometry check
#'   silently did nothing in a locally launched app (where `interactive()` is TRUE).
#'
#' @param shp simple feature data.frame
#' @param crs coordinate reference system, default is 4269
#'
#' @return returns all rows of shp, but adds columns "valid" and "invalid_msg"
#'   and adds attributes shiny can use to update some reactives,
#'   and standardizes "geometry" as the sfc column name.
#'   Attributes set: `validate_errmsg`, `disable_buttons_SHP`,
#'   `num_valid_pts_uploaded_SHP`, `invalid_alert_SHP`, `an_map_text_shp`.
#'
#' @keywords internal
#'
shapefix = function(shp,
                    # disable_buttons_SHP = NULL, # probably dont need to know its prior state in shiny
                    # num_valid_pts_uploaded_SHP = NULL,
                    # invalid_alert_SHP = NULL,
                    # an_map_text_shp = NULL,
                    crs = 4269) {

  ## THIS IS A WAY FOR app_server, and ejamit() via shapefile_from_any(),
  ##  to both use this one function
  ##  to do the same thing whether or not in a reactive context.

  ## initialize every value that gets returned as an attribute, so that each branch below
  ## only has to set what it actually changes, and no branch can leave one undefined.
  validate_errmsg            <- NULL
  disable_buttons_SHP        <- FALSE
  num_valid_pts_uploaded_SHP <- 0
  invalid_alert_SHP          <- 0
  an_map_text_shp            <- NA

  if (is.null(shp)) {
    warning("Uploaded file should have valid file extension(s)")
    return(NULL)
  }
  ## points are reported, not rejected, here - the caller decides. see @details and issue #550
  if (any(sf::st_geometry_type(shp) %in% c("POINT", "MULTIPOINT"))) {
    disable_buttons_SHP <- TRUE
    validate_errmsg <- "This is a shapefile of points, not polygons. To analyze points with a buffer distance, choose 'Latitude/Longitude file upload' instead."
  }
  # Drop Z and/or M dimensions from feature geometries, resetting classes appropriately
  shp <- sf::st_zm(shp)
  # Use standard column name, "geometry", for the spatial info # fixed, e.g., shp = shapefile_from_any(system.file("testdata/shapes/portland.gdb.zip", package="EJAM"))
  if (any(grepl("sfc",lapply(shp,class)))) {
    colnames(shp)[grepl("sfc",lapply(shp,class))] <- "geometry"
    sf::st_geometry(shp) <- "geometry"
  }

  if (nrow(shp) > 0) {

    # count valid rows ####
    empty = sf::st_is_empty(shp)
    shp_valid_check <- data.frame(valid = rep(NA, NROW(shp)), reason = "")
    shp_valid_check[empty, "valid"] <- FALSE
    shp_valid_check[empty, "reason"] <- "empty geometry"
    shp_valid_check[!empty, ]  <- terra::is.valid(terra::vect(shp[!empty, ]), messages = T)
    shp_is_valid <- shp_valid_check$valid
    numna <- sum(!shp_is_valid)
    num_valid_pts_uploaded_SHP  <- length(shp_is_valid) - sum(!shp_is_valid)
    invalid_alert_SHP <- numna
    # "siteid" added ####
    shp <- dplyr::mutate(shp, siteid = dplyr::row_number())
    # crs ####
    shp <- sf::st_transform(shp, crs = crs)
    an_map_text_shp <- NA # ignored if !is.null(), or maybe will have to handle this as it gets returned?

  } else {

    invalid_alert_SHP <- 0 # hides the invalid site warning
    an_map_text_shp <- HTML(NULL)  # hides the count of uploaded sites/shapes
    disable_buttons_SHP <- TRUE
    validate_errmsg <- 'No shapes found in file uploaded.'
    ## zero-length equivalents of what the nrow > 0 branch computes, so that the shared code
    ## below works on an empty shapefile instead of failing on an undefined object. Without
    ## these, shapefile with 0 shapes errored with "object 'shp_is_valid' not found" and the
    ## message above was never reached. see issue #550
    shp_valid_check <- data.frame(valid = logical(0), reason = character(0))
    shp_is_valid    <- logical(0)
  }
  # "valid" flag added  ####
  shp$valid <- shp_is_valid

  # "ejam_uniq_id" added ####

  ## seq_len(), not 1:NROW(), so that 0 rows gives integer(0) rather than c(1, 0).
  ## isTRUE(), because all.equal() returns a descriptive STRING (not FALSE) when unequal,
  ## and !"some string" is an error - so this warning used to crash instead of warn.
  if (!("ejam_uniq_id" %in% names(shp))) {
    shp <- cbind(ejam_uniq_id = seq_len(NROW(shp)), shp)
  } else {
    if (!isTRUE(all.equal(seq_len(NROW(shp)), shp$ejam_uniq_id))) {
      warning("ejam_uniq_id already is a column in the shapefile, but is not 1 through N. However, it will NOT be overwritten.")
    }
  }
  # "invalid_msg" added ####
  ## rep(NA, NROW()), not a bare NA, so this also works when there are 0 rows
  ## (assigning a length-1 value into a 0-row frame is an error). Identical for NROW >= 1.
  shp$invalid_msg <- rep(NA, NROW(shp))
  shp$invalid_msg[shp$valid == F] <- shp_valid_check$reason[shp$valid == F]
  shp$invalid_msg[is.na(shp$geometry)] <- 'bad geometry'

  # pass info back to shiny for reactives, but if NULL, an attribute gets removed here
  attr(shp, "validate_errmsg") <- validate_errmsg
  attr(shp, "disable_buttons_SHP") <- disable_buttons_SHP
  attr(shp, "num_valid_pts_uploaded_SHP") <- num_valid_pts_uploaded_SHP
  attr(shp, "invalid_alert_SHP") <- invalid_alert_SHP
  attr(shp, "an_map_text_shp") <- an_map_text_shp
  return(shp)
}
############################################################ #
