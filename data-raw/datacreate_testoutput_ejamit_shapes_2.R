#

testoutput_ejamit_shapes_2 <- ejamit(shapefile = testinput_shapes_2, radius = 0)
EJAM:::metadata_add_and_use_this("testoutput_ejamit_shapes_2")
# testoutput_ejamit_shapes_2 <- metadata_add(testoutput_ejamit_shapes_2)
# usethis::use_data(testoutput_ejamit_shapes_2, overwrite = TRUE)
EJAM:::dataset_documenter("testoutput_ejamit_shapes_2", description = "This is the output of ejamit(shapefile = testinput_shapes_2, radius = 0)",
                   seealso = "[ejamit()] [testdata()]")



# save as EXCEL via ejam2excel() ####
# if (resaving_ejam2excel) {
fname <- paste0("testoutput_ejam2excel_shapes" )
junk <- ejam2excel(
  testoutput_ejamit_shapes_2,
  shp = testinput_shapes_2,
  analysis_title = "Example of outputs of ejamit(shapefile= ) being formatted and saved using ejam2excel()",
  radius_or_buffer_in_miles = 0,
  # buffer_desc = paste0("Within ", myrad, " miles"),
  fname = paste0("./inst/testdata/examples_of_output/", fname, ".xlsx"),
  save_now = TRUE,
  overwrite = TRUE,
  launchexcel = FALSE,
  interactive_console = FALSE
)
# }

# save as HTML Report via ejam2report() ####
# if (resaving_ejam2report ) {
fname <- paste0("testoutput_ejam2report_shapes_2")
url_html <- ejam2report(
  (testoutput_ejamit_shapes_2),
  shp = testinput_shapes_2,
  analysis_title = "Sample Summary Report for Polygons",
  launch_browser = F
)
file.copy(url_html, paste0("./inst/testdata/examples_of_output/", fname, ".html"),
          overwrite = TRUE
)
# }
