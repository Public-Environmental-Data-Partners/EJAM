# Prepare geography in a new external output directory; never activate data.
# Set EJAM_GEOGRAPHY_YEAR for the desired boundary vintage and
# EJAM_GEOGRAPHY_OUTPUT to a new release-input folder. Existing inputs are kept.
source("R/utils_release_geography.R")
read_reference <- function(name) {
  env <- new.env(parent=emptyenv())
  load(file.path("data",paste0(name,".rda")),envir=env)
  env[[name]]
}
year <- Sys.getenv("EJAM_GEOGRAPHY_YEAR",sub(".*-","",read.dcf("DESCRIPTION",fields="VersionACS")[1]))
output <- Sys.getenv("EJAM_GEOGRAPHY_OUTPUT")
if (!nzchar(output)) stop("Set EJAM_GEOGRAPHY_OUTPUT to a new directory outside the checkout")
bundle <- release_geography_build(output_dir=output,year=year,
  state_lookup=read_reference("stateinfo"),state_lookup_extended=read_reference("stateinfo2"))
invisible(release_geography_read(output))
message("Geography prepared and verified. Active datasets and versions are unchanged.")
