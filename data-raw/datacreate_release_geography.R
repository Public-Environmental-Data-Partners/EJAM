# Held until Mark accepts the environmental inputs and authorizes resumption.
# Do not run a pipeline, data build or dry run during that hold.
# After approval, run from the package root with a new EJAM_GEOGRAPHY_OUTPUT
# subdirectory of the release-inputs folder specified by the saved v4 plan.
# Explicit EJAM_GEOGRAPHY_YEAR supports preparing release geography before the
# matching demographics are activated. No DESCRIPTION/data/ files are changed.
approved <- identical(Sys.getenv("EJAM_RELEASE_INPUTS_APPROVED"),"true")
if (!approved) stop("Release inputs are on hold. Mark must authorize resumption before setting EJAM_RELEASE_INPUTS_APPROVED=true")
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
  state_lookup=read_reference("stateinfo"),state_lookup_extended=read_reference("stateinfo2"),
  approved=approved)
invisible(release_geography_read(output))
message("Geography prepared and verified. Active datasets and versions are unchanged.")
