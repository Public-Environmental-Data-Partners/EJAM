# Retain only currently present facilities from this historical ECHO example.
# Keep the original EPA-supplied names and address fields with their own IDs;
# do not pair those fields with replacement facilities.
if (!exists("frs")) stop("Load the newly built frs.arrow before checking the ECHO example")

csv_path <- "inst/testdata/registryid/FRS_example_data.CSV"
x <- read.csv(csv_path, colClasses = "character", check.names = FALSE,
              stringsAsFactors = FALSE)
if (!"REGISTRY_ID" %in% names(x)) stop("ECHO example lacks REGISTRY_ID")
keep <- x$REGISTRY_ID %in% as.character(frs$REGISTRY_ID)
if (!any(keep)) stop("No ECHO example registry IDs remain in the new FRS snapshot")
if (any(!keep)) {
  message("Removing ", sum(!keep), " retired ECHO example IDs from the upload fixture")
  x <- x[keep, , drop = FALSE]
  write.csv(x, csv_path, row.names = FALSE, na = "")
  openxlsx::write.xlsx(x,
    "inst/testdata/registryid/FRS_example_data.xlsx", overwrite = TRUE)
}
