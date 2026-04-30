
#' View HTML Report on EJAM Results (Overall or at 1 Site)
#'
#' @description Get the html text or the path to the html file with a multisite summary or community report
#'
#' @param ejamitout output as from [ejamit()], list with a table in [data.table](https://r-datatable.com) format called `results_bysite`
#'   if sitenumber parameter is used, or a table in [data.table](https://r-datatable.com) format called `results_overall` otherwise
#' @param sitenumber If a valid number is provided, the report is a "1-site" report, about
#'   `ejamitout$results_bysite[sitenumber, ]`. If no valid number is provided (e.g., param is omitted, 0, NULL, "", etc.)
#'   then the report is a "Multisite" report, about `ejamitout$results_overall`.
#'   But note that it is treated / titled like a 1-site report if only
#'   one site was analyzed (or only one had valid results).
#'
#' @param analysis_title optional title of analysis, default is EJAM:::global_or_param("default_standard_analysis_title")
#'
#' @param report_title optional generic name of this type of report, to be shown at top,
#'   like "EJSCREEN Multisite Report" or "EJSCREEN Community Report".
#'   Default is EJAM:::global_or_param("report_title") or EJAM:::global_or_param("report_title_multisite")
#'   depending on number of sites analyzed and the sitenumber parameter.
#'
#' @param logo_path optional relative path to a logo for the upper right of the overall header.
#'   Ignored if logo_html is specified and not NULL, but otherwise uses default or param set in [ejamapp()]
#' @param logo_html optional HTML for img of logo for the upper right of the overall header.
#'   If specified, it overrides logo_path. If omitted, gets created based on logo_path.
#'
#' @param site_method optional word or phrase about the sites or how they were selected.
#'
#'   The `site_method` parameter can be used as-is by [create_filename()] to be part of the saved file name.
#'   It can also be used by the shiny app to add informational text in the header of a report,
#'   via [ejam2report()] and related helper functions like [report_residents_within_xyz()]
#'   or via [ejam2excel()] and related helper functions.
#'
#'   The `site_method` parameter provides more detailed info about how sites were specified in the web app,
#'   beyond what `sitetype` provides (e.g., from `ejamit()$sitetype` or `ejamitout$sitetype`):
#'
#'   - sitetype can be "latlon", "fips", or "shp"
#'
#'   - site_method can be one of these: "latlon", "SHP", "FIPS", "FIPS_PLACE", "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT"
#'
#'   The shiny app server provides `site_method` from the reactive called submitted_upload_method()
#'   which is much like the one called current_upload_method().
#'
#' @param shp provide the sf spatial data.frame of polygons that were analyzed so you can map them since
#'   they are not in ejamitout
#' @param launch_browser set TRUE to have it launch browser and show report.
#' @param return_html set TRUE to have function return HTML object instead of URL of local file
#' @param fileextension html or .html or pdf or .pdf - use "pdf" to create a PDF version of the report.
#'   PDF generation uses [pagedown::chrome_print()] which requires the `pagedown` package and a
#'   Chrome/Chromium browser to be available on the system.
#'   The PDF preserves the full HTML/CSS styling and supports smart page breaks.
#'   If `pagedown` is not installed, a warning is issued and HTML output is returned instead.
#' @param filename optional path and name for report file, used by web app
#' @param show_ratios_in_report logical, whether to add columns with ratios to US and State overall values, in main table of envt/demog. info.
#' @param extratable_show_ratios_in_report logical, whether to add columns with ratios to US and State overall values, in extra table
#'
#' @param extratable_title Text of overall title ABOVE the extra table
#' @param extratable_title_top_row Text INSIDE top left cell of extra table
#'
#' @param extratable_list_of_sections This defines what extra indicators are shown.
#'   It is a named list of vectors,
#'   where each name is text phrase that is title of a section of the table,
#'   and each vector is the vector of colnames of output_df that are indicators
#'   to show in that section, in extra table of demog. subgroups, etc.
#'
#' @param extratable_hide_missing_rows_for only for the indicators named in this vector,
#'   leave out rows in table where raw value is NA,
#'   as with many of names_d_language, in extra table of demog. subgroups, etc.
#'
#' @param footer_version_number,footer_date,footer_text,footer_html
#'   to customize the report footer - see [generate_report_footer()]
#'   Should provide footer_date to ensure user's timezone is used to determine today's date.
#' @param addlatlon optional, whether to include lat,lon coordinates in header (for "latlon" sitetype)
#' @return URL of temp file or object depending on return_html,
#'    and has side effect of launching browser to view it depending on return_html
#'
#' @examples
#' #out <- ejamit(testpoints_10, radius = 3, include_ejindexes = T)
#' out <- testoutput_ejamit_10pts_1miles
#'
#' ejam2report(out)
#' ejam2table_tall(out$results_overall)
#' if (interactive()) {
#'  x <- ejam2report(out, sitenumber = 1, launch_browser = T)
#'  table_gt_from_ejamit_overall(out$results_overall)
#'  table_gt_from_ejamit_1site(out$results_bysite[1, ])
#' }
#'
#' @export
#'
ejam2report <- function(ejamitout = testoutput_ejamit_10pts_1miles,
                        sitenumber = NULL,
                        logo_path = EJAM:::global_or_param("report_logo"),
                        logo_html = NULL, # defined downstream
                        report_title = NULL, # EJAM:::global_or_param("report_title") or EJAM:::global_or_param("report_title_multisite")
                        analysis_title = NULL, # EJAM:::global_or_param("default_standard_analysis_title")
                        addlatlon = TRUE,

                        site_method = NULL, # c("latlon", "SHP", "FIPS")[1],
                        shp = NULL,

                        show_ratios_in_report = TRUE,
                        extratable_show_ratios_in_report = TRUE,
                        extratable_title = '', #'Additional Information',
                        extratable_title_top_row = 'ADDITIONAL INFORMATION',
                        extratable_list_of_sections = list(
                          # see build_community_report defaults and see global_defaults_*.R
                          `Breakdown by Population Group` = names_d_subgroups,
                          `Language Spoken at Home` = names_d_language,
                          `Language in Limited English Speaking Households` = names_d_languageli,
                          `Breakdown by Sex` = c('pctmale','pctfemale'),
                          `Health` = names_health,
                          `Age` = c('pctunder5', 'pctunder18', 'pctover64'),
                          `Community` = names_community[!(names_community %in% c( 'pctmale', 'pctfemale', 'pctownedunits_dupe'))],
                          `Poverty` = names_d_extra,
                          `Features and Location Information` = c(
                            names_e_other,
                            names_sitesinarea,
                            names_featuresinarea,
                            names_flag
                          ),
                          `Climate` = names_climate,
                          `Critical Services` = names_criticalservice,
                          `Other` = names_d_other_count
                          # , `Count above threshold` = names_countabove  # need to fix map_headernames longname and calctype and weight and drop 2 of the 6
                        ),
                        ## all the indicators that are in extratable_list_of_sections:
                        extratable_hide_missing_rows_for = as.vector(unlist(extratable_list_of_sections)),

                        footer_version_number = NULL,
                        footer_date = NULL, # ideally should provide footer_date to ensure user's timezone is used to determine today's date
                        footer_text = NULL,
                        footer_html = NULL,
                        ## Rmd_name and Rmd_folder could be made params to pass to report_setup_temp_files()
                        fileextension = c("html", "pdf")[1],
                        filename = NULL,
                        return_html = FALSE,
                        launch_browser = TRUE
) {

  # analysis title default and report_title default depend on if this is 1-site or multisite

  if (!interactive()) {launch_browser <- FALSE} # but that means other functions cannot override this while not interactive.

  ## For convenience, like being able to recreate report from just output of API data endpoint that only provides the results_overall table, say,
  ## we could possibly allow ejamitout param to be provided as just ejamit()$results_overall,
  # and if so do for the is.null(sitenumber) | sitenumber %in% 0 case, ejamitout$results_overall <- ejamitout; ejamitout$results_bysite <- ???
  # but then also loosen these checks:
  # Check input valid
  stopifnot("ejamitout must be a list as from ejamit()" = is.list(ejamitout),
            "ejamitout must be a list that has ejamitout$results_bysite data.frame/table" = "results_bysite" %in% names(ejamitout),
            "ejamitout must be a list that has ejamitout$results_overall data.frame/table" = "results_overall" %in% names(ejamitout)
  )

  # SITE TYPE ####

  ## > sitetype shp/fips/latlon ####
  ## > site_method default  ####
  # 1st, check if "sitetype" is shp, fips, or latlon
  if (!("sitetype" %in% names(ejamitout))) {
    ejamitout$sitetype <- ejamit_sitetype_from_output(ejamitout)
  }
  sitetype <- ejamitout$sitetype

  # 2d, get more detailed info about how site was specified, from "site_method" parameter,
  # which server stores as the submitted_upload_method() reactive
  # and as used in server, this could be SHP, FIPS, latlon, MACT, FRS, EPA_PROGRAM_up, etc. etc.
  # which is useful for providing report header info
  if (missing(site_method) || is.null(site_method) || site_method %in% "") {
    if (sitetype %in% 'shp') {
      site_method <- 'SHP'
    } else {
      if (sitetype %in% 'fips') {
        site_method <- 'FIPS'
      } else {
        if (sitetype %in% 'latlon') {
          site_method <- 'latlon'
        }
      }
    }
  }
  ################################################## #  ################################################## #
  # REPORT TYPE (MULTISITE or 1-SITE REPORT) ? ####

  # Assume multisite report, unless only 1 site was analyzed (e.g., if called from the EJAM API) or a valid sitenumber >1 was provided

  ## > sitenumber & nsites ####
  sitenumber <- as.numeric(sitenumber)
  if (all(is.na(sitenumber)) || is.null(sitenumber) ||
      # length(sitenumber) == 0 ||
      length(sitenumber) != 1 ||
      all(sitenumber %in% "") || all(sitenumber %in% 0) || all(sitenumber < 0) ||
      !(all(sitenumber %in% 1:NROW(ejamitout$results_bysite))) # ensures integer could provide error msg for this case
  ) {
    sitenumber <- 0  # in case sitenumber was invalid
  }
  # How many sites were actually analyzed, in the (valid) results provided?
  nsites <- NROW(ejamitout$results_bysite[ejamitout$results_bysite$valid %in% TRUE, ]) # might differ from ejamout1$sitecount_unique
  # Treat it like a 1-site report if only 1 valid site was analyzed.
  #   And then if sitenumber omitted, or sitenumber=1, or sitenumber provided was invalid, just use that 1 site.
  if (sitenumber %in% 0 && nsites == 1) {
    sitenumber <- 1
  }

  # Multi-site  (results_overall) ###################################################

  ## > report_title if multisite ####
  if (sitenumber %in% 0) {

    if (is.null(report_title)) {
      report_title <- EJAM:::global_or_param("report_title_multisite")
    }
    ## > analysis_title if multisite ####
    if (is.null(analysis_title)) {
      analysis_title <- EJAM:::global_or_param("default_standard_analysis_title")
    }

    ejamout1 <- ejamitout$results_overall # one row
    ejamout1$valid <- TRUE
    # but shp is all rows, remember, and popup can still be like for site by site
    rad <- ejamout1$radius.miles

    ## > filename needs no location name ####
    selected_location_name_react <- NULL

    ## > fips polygons ####
    if (site_method %in% "FIPS" && is.null(shp)) {
      shp <- shapes_from_fips(ejamitout$results_bysite$ejam_uniq_id)
      if (!is.na(rad) && rad > 0) warning("Downloading fips bounds but NOT adding radius as buffer for mapping purposes here!")
      # radius would have to be used here to add any buffer ! ***
    }
  } else {

    # Single-site  (results_bysite, or _overall but just 1 site) ###################################################

    ## > report_title if 1-site ####
    if (is.null(report_title)) {
      report_title <- EJAM:::global_or_param("report_title")
    }
    ## > analysis_title if 1-site ####
    if (is.null(analysis_title)) {
      if (sitetype %in% 'fips') {
        analysis_title <- fips2name(ejamitout$results_bysite$ejam_uniq_id[sitenumber])
      } else {
        analysis_title <- global_or_param("default_standard_analysis_title")
      }
    }
    ejamout1 <- ejamitout$results_bysite[sitenumber, ]
    rad <- ejamout1$radius.miles

    ## > nsites
    nsites <- 1

    ## > filename will include name of location ####
    selected_location_name_react <- ejamout1$statename

    ## > fips polygons ####
    if (site_method %in% "FIPS" && is.null(shp)) {
      shp <- shapes_from_fips(fips = ejamitout$results_bysite$ejam_uniq_id[sitenumber])
      if (!is.na(rad) && rad > 0) warning("Downloading fips bounds but NOT adding radius as buffer for mapping purposes here!")
      # radius would have to be used here to add any buffer ! ***
    } else {
      if (!is.null(shp)) {
        shp <- shp[sitenumber, ]
      }
    }
  }
  ################################################## #  ################################################## #

  include_ejindexes <- any(names_ej_pctile %in% colnames(ejamout1))

  if (!("valid" %in% names(ejamout1))) {ejamout1$valid <- TRUE}
  if (isTRUE(ejamout1$valid)) {

    #############################################################################  #

    # HEADER  ####

    ## > logo_path ####
    if (is.null(logo_path)) {
      logo_path <- EJAM:::global_or_param("report_logo")
    }

    ## > population count formatted ####
    popstr <- prettyNum(round(ejamout1$pop, table_rounding_info("pop")), big.mark = ',')

    ## > fips2name() ####
    if (sitetype %in% "fips" && !is.null(sitenumber) && sitenumber > 0) {
      analysis_title <- fips2name(ejamitout$results_bysite[sitenumber, ejam_uniq_id])
    }
    if (sitetype %in% "shp" && is.null(shp)) {
      # this should not happen unless ejam2report() got called for shp analysis results but user did not provide the bounds
      warning("Cannot map polygons based on just output of ejamit() -- The sf class shapefile / spatial data.frame that was used should be provided as the shp parameter to ejam2report()")
    }
    ## > report_residents_within_xyz_from_ejamit()
    residents_within_xyz <- report_residents_within_xyz_from_ejamit(
      ejamitout = ejamitout,
      sitenumber = sitenumber,
      site_method = site_method
    )
    ####################################################### #

    # FILES ####

    ## copy .Rmd (template), .png (logo), .css from Rmd_folder to a temp dir subfolder for rendering
    ## > report_setup_temp_files() copies template, logo, .css files to where needed for rendering ####
    ## returns path to .Rmd template copied to a temp folder, but
    ## tempReport is not used - report_setup_temp_files() is used for side efx
    tempReport <- report_setup_temp_files()
    # Rmd_name = 'community_report_template.Rmd', # default, for summary report
    # # Rmd_name = 'barplot_report_template.Rmd' # for single site barplot report
    # Rmd_folder = 'report/community_report/'

    ## > fileextension ####
    # adjust this once .pdf option is implemented/working
    fileextension <- paste0(".", gsub("^\\.", "", fileextension)) # add leading dot if not present
    fileextensions_implemented <- c(".html", ".pdf")
    if (!(fileextension %in% fileextensions_implemented)) {
      warning("fileextension must be one of", fileextensions_implemented)
      fileextension <- ".html"
    }

    ## > filename ####
    # use create_filename() here like server does:
    if (!is.null(selected_location_name_react)) {
      location_suffix <- paste0(" - ", selected_location_name_react) # the statename, if just 1 site not overall results
    } else {
      location_suffix <-  ""
    }
    if (is.null(filename)) {
      filename <- create_filename(
        file_desc = paste0('community report', location_suffix),
        title =  analysis_title,
        buffer_dist = rad,
        site_method = site_method, # can be latlon, shp, SHP, fips, FIPS, MACT, etc. (just used as-is in filename)
        with_datetime = FALSE,
        ext = fileextension # in server,  ifelse(input$format1pager == 'pdf', '.pdf', '.html')
      )
      temp_comm_report <- file.path(tempdir(), filename)
    } else {
      temp_comm_report <- filename
    }
    output_file      <- temp_comm_report

    if (return_html) {
      temp_comm_report_or_null <- NULL
    } else {
      temp_comm_report_or_null <- temp_comm_report
    }
    ####################################################### #

    # ASSEMBLE REPORT  ####

    ## TABLES, LOGO, HEADER  ####
    ### > build_community_report() ####
    ## note build_community_report() is also used in community_report_template.Rmd and in server

    community_html <- build_community_report(

      logo_path      = logo_path,
      logo_html      = logo_html,
      report_title   = report_title,
      analysis_title = analysis_title,
      totalpop       = popstr,
      locationstr    = residents_within_xyz,

      output_df      = ejamout1,
      include_ejindexes     = include_ejindexes,
      show_ratios_in_report = show_ratios_in_report,
      extratable_title                 = extratable_title,
      extratable_title_top_row         = extratable_title_top_row,
      extratable_list_of_sections      = extratable_list_of_sections,
      extratable_show_ratios_in_report = extratable_show_ratios_in_report,
      extratable_hide_missing_rows_for = extratable_hide_missing_rows_for,

      in_shiny = FALSE,
      filename = temp_comm_report_or_null  # passing NULL should make it return the html object
    )

    ## seems like using cat() was a simpler approach tried initially: ***
    ##  that would write just the basics of it to the temp location, not needing render()
    ##  but the render() approach also add the map and plot !!
    # cat(community_html, file = temp_comm_report)

    rmd_template <- system.file("report/community_report/combine_after_build_community_report.Rmd", package = "EJAM")

    ## BARPLOT  ####

    plot <- plot_barplot_ratios_ez(ejamitout) + ggplot2::guides(fill = ggplot2::guide_legend(nrow = 2))

    ## MAP ####

    # This presumes shp was provided in SHP cases
    if (is.null(sitenumber) || length(sitenumber) == 0 || sitenumber %in% 0) {
      # Map from community report should be ALL the sites that were passed here, UNLESS sitenumber param was used to pick 1
      if (sitetype %in% c("fips", "shp") && !is.null(shp)) {
        # radius gets found, and used just in popups since shapefile given
        map <- ejam2map(ejamitout = ejamitout, shp = shp, launch_browser = FALSE)
      } else {
        map <- mapfastej(ejamitout, radius = rad)
      }
    } else {
      # just 1 site specified by sitenumber so map should show just that 1 site! shp and ejamout1 both 1 row already in this case
      if (sitetype %in% c("fips", "shp") && !is.null(shp)) {
        # radius gets found, and used just in popups since shapefile given
        map <- ejam2map(ejamitout = ejamout1, shp = shp, launch_browser = FALSE)
      } else {
        map <- mapfastej(ejamout1, radius = rad)
      }
    }
    ## FOOTER/DATE/VERSION ####
    # Those are created by .Rmd template based on footer_* parameters
    ######################################## #

    # RENDER as HTML FILE ####

    report_params <- list(
      community_html = community_html,
      plot = plot
    )
    if (!is.null(map)) {
      report_params$map = map
    }
    report_params <- c(report_params,
                       # NULL means use defaults
                       footer_version_number = footer_version_number,
                       footer_date = footer_date,  # ideally obtain local timezone of user to ensure correct date used
                       footer_text = footer_text,
                       footer_html = footer_html
    )
    ## render & return the HTML text by reading the file ####
    # >>>>>>> issue303AddMapAndBarPlot
    if (return_html) {
      rendered_path <- rmarkdown::render(
        input = rmd_template,
        output_format = "html_document",   #   pdf option not relevant here
        output_file = tempfile(fileext = ".html"),  #  not output_file since here you do not care about or see the filename
        params = report_params,
        envir = new.env(parent = globalenv()),
        quiet = TRUE
      )

      return(paste(readLines(rendered_path, warn = FALSE), collapse = "\n"))

    } else {
      ## render & return filepath ####
      if (fileextension == ".pdf") {
        ## For PDF: render HTML first, then convert to PDF using pagedown::chrome_print() ####
        # This preserves the full CSS styling unlike a LaTeX-based pdf_document
        html_temp <- tempfile(fileext = ".html")
        rmarkdown::render(
          input = rmd_template,
          output_format = "html_document",
          output_file = html_temp,
          params = report_params,
          envir = new.env(parent = globalenv()),
          quiet = TRUE
        )
        if (!requireNamespace("pagedown", quietly = TRUE)) {
          warning("The 'pagedown' package is required to generate PDF reports. ",
                  "Install it with: install.packages('pagedown'). ",
                  "Generated HTML output instead at: ", sub("\\.pdf$", ".html", output_file))
          file.copy(html_temp, sub("\\.pdf$", ".html", output_file))
          output_file <- sub("\\.pdf$", ".html", output_file)
        } else {
          pagedown::chrome_print(
            input   = html_temp,
            output  = output_file,
            wait    = 5,
            timeout = 120,
            verbose = 0
          )
        }
      } else {
        rmarkdown::render(
          input = rmd_template,
          output_format = "html_document",
          output_file = output_file,
          params = report_params,
          envir = new.env(parent = globalenv()),
          quiet = TRUE
        )
      }
      suppressWarnings({
        output_file <- normalizePath(output_file) # allows it to work on MacOS, e.g.
      })
      if (interactive() && !shiny::isRunning()) {
        cat("file saved at", output_file, '\n')
        cat("To open that folder from R, you could copy/paste this into the RStudio console:\n")
        cat(paste0("browseURL('", dirname(output_file),"')"), '\n')
      }

      if (launch_browser && !shiny::isRunning()) {
        browseURL(output_file)
      }

      return(output_file)
    }

    ########################################################################################### #
    ## can also generate reports through knitting Rmd template
    ## this is easier to add in maps and plots but is slower to appear

    #   ## pass params to customize .Rmd doc  # ###

    #browseURL(temp_comm_report)

  } else {
    rstudioapi::showDialog(title = 'Report not available',
                           'Individual site reports not yet available.')
    return(NA)
  }
}
########################################################################################### #
