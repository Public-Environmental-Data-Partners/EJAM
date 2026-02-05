
############## # ############## # ejamit()


# ejamit() ####

## COUNTIES ####

testoutput_ejamit_fips_counties <- ejamit(fips = testinput_fips_counties)  #  COUNTIES
EJAM:::metadata_add_and_use_this("testoutput_ejamit_fips_counties")
# data(testoutput_ejamit_fips_counties) # may be need to see the just-updated attributes
# testoutput_ejamit_fips_counties <- metadata_add(testoutput_ejamit_fips_counties)
# usethis::use_data(testoutput_ejamit_fips_counties, overwrite = TRUE)
EJAM:::dataset_documenter("testoutput_ejamit_fips_counties", description = "This is the output of ejamit(fips = testinput_fips_counties)",
                   seealso = "[ejamit()] [testdata()]")
############## # #

## CITIES ####

testoutput_ejamit_fips_cities <- ejamit(fips = testinput_fips_cities) #  CITIES
EJAM:::metadata_add_and_use_this("testoutput_ejamit_fips_cities")
# testoutput_ejamit_fips_cities <- metadata_add(testoutput_ejamit_fips_cities)
# usethis::use_data(testoutput_ejamit_fips_cities, overwrite = TRUE)
EJAM:::dataset_documenter("testoutput_ejamit_fips_cities", description = "This is the output of ejamit(fips = testinput_fips_cities)",
                   seealso = "[ejamit()] [testdata()]")


############## # ############## # ejam2excel()


# save as EXCEL via ejam2excel() COUNTIES ####

# if (resaving_ejam2excel) {
fname <- paste0("testoutput_ejamit_fips_counties" )  #  COUNTIES
junk <- ejam2excel(
  (testoutput_ejamit_fips_counties),
  analysis_title = "Example of outputs of ejamit(fips= testinput_fips_counties) for Counties being formatted and saved using ejam2excel()",
  radius_or_buffer_in_miles = 0,
  # buffer_desc = paste0("Within ", myrad, " miles"),
  fname = paste0("./inst/testdata/examples_of_output/", fname, ".xlsx"),
  save_now = TRUE,
  overwrite = TRUE,
  launchexcel = FALSE,
  interactive_console = FALSE
)
# }
############## # #

# save as EXCEL via ejam2excel() CITIES ####

# if (resaving_ejam2excel) {
  fname <- paste0("testoutput_ejam2excel_fips_cities" )  #  CITIES
  junk <- ejam2excel(
     (testoutput_ejamit_fips_cities),
     analysis_title = "Example of outputs of ejamit(fips= testinput_fips_cities) being formatted and saved using ejam2excel()",
    radius_or_buffer_in_miles = 0,
    # buffer_desc = paste0("Within ", myrad, " miles"),
    fname = paste0("./inst/testdata/examples_of_output/", fname, ".xlsx"),
    save_now = TRUE,
    overwrite = TRUE,
    launchexcel = FALSE,
    interactive_console = FALSE
  )
# }

  ############## # ############## # ejam2report()


  # save as HTML Report via ejam2report() COUNTIES ####

  # if (resaving_ejam2report ) {
  fname <- paste0("testoutput_ejamit_fips_counties")  #  COUNTIES
  url_html <- ejam2report(
    (testoutput_ejamit_fips_counties),
    analysis_title = "Sample Summary Report for County FIPS",
    launch_browser = F
  )
  file.copy(url_html, paste0("./inst/testdata/examples_of_output/", fname, ".html"),
            overwrite = TRUE
  )
  # }
  ############## # #

# save as HTML Report via ejam2report() CITIES ####

# if (resaving_ejam2report ) {
  fname <- paste0("testoutput_ejam2report_fips_cities") #  CITIES
  url_html <- ejam2report(
     (testoutput_ejamit_fips_cities),
    analysis_title = "Sample Summary Report for City FIPS",
    launch_browser = F
  )
  file.copy(url_html, paste0("./inst/testdata/examples_of_output/", fname, ".html"),
            overwrite = TRUE
  )
# }
