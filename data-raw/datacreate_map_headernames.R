if (!exists("askquestions")) {askquestions <- FALSE}
if (!exists("rawdir")) {rawdir <- "./data-raw"}

# Rebuild map_headernames from the authoritative CSV source.
#
# data-raw/map_headernames.csv is the editable source of truth. This script
# must not add metadata rows, change names, infer EJSCREEN helper fields, or
# apply one-off upserts after reading the CSV. If metadata is wrong or missing,
# fix the CSV itself and rerun this script.

datacreate_map_headernames <- function(rawdir = "./data-raw",
                                       fname = "map_headernames.csv",
                                       save_csv = FALSE) {

  if (length(rawdir) == 1 && file.exists(rawdir) && !dir.exists(rawdir)) {
    fname <- basename(rawdir)
    rawdir <- dirname(rawdir)
  }
  if (missing(fname) || is.null(fname) || !nzchar(fname)) {
    fname <- "map_headernames.csv"
  }
  if (grepl("[.]xlsx?$", fname, ignore.case = TRUE)) {
    stop(
      "map_headernames is now maintained in data-raw/map_headernames.csv; ",
      "do not rebuild it from an old .xlsx file.",
      call. = FALSE
    )
  }

  fpath <- file.path(rawdir, fname)
  if (!file.exists(fpath)) {
    stop("did not find required map_headernames CSV: ", fpath, call. = FALSE)
  }

  map_headernames <- utils::read.csv(
    fpath,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = c(""),
    colClasses = "character"
  )
  map_headernames[is.na(map_headernames)] <- ""

  EJAM:::validate_map_headernames_ejscreen_names(
    map_headernames,
    strict = TRUE,
    source_name = fpath
  )

  if (isTRUE(save_csv)) {
    utils::write.csv(
      map_headernames,
      file = fpath,
      row.names = FALSE,
      na = "",
      quote = TRUE
    )
  }

  invisible(map_headernames)
}
################################################################################# #

if (askquestions && interactive()) {
  fpath <- file.path(rawdir, "map_headernames.csv")
  y <- askYesNo("Want to open data-raw/map_headernames.csv to edit it now?")
  if (!is.na(y) && y) {
    if (requireNamespace("rstudioapi", quietly = TRUE) &&
        rstudioapi::isAvailable()) {
      rstudioapi::navigateToFile(normalizePath(fpath))
    } else {
      browseURL(normalizePath(fpath))
    }
    y <- askYesNo("Y if done editing and ready to validate/save, N to abort/stop")
    if (is.na(y) || !y) {stop("stopping script")}
  }
  rm(y)
}

map_headernames <- datacreate_map_headernames(rawdir = rawdir)

## metadata ####
# map_headernames <- metadata_add(map_headernames)
# usethis::use_data(map_headernames, overwrite = TRUE)
EJAM:::metadata_add_and_use_this("map_headernames")

rm(datacreate_map_headernames)

cat("FINISHED A SCRIPT\n")
cat("\n In globalenv() so far: \n\n")
print(ls())
################################################################################# #

# # which sources provide which variables or indicators?

some <- unique(map_headernames$rname[
  map_headernames$varlist != "" & map_headernames$varlist != "x_anyother"
])
info <- varinfo(some, info = c("ejscreen_apinames_old", "csv", "acs", "varlist"))
x <- info[nchar(paste0(
  info$ejscreen_apinames_old,
  info$csv,
  info$acs
)) > 0, ]
cat("\nSee a table of which source (old api, csv, acs, etc.) uses which variable names\n\n")
cat(
  "some = unique(map_headernames$rname[map_headernames$varlist != '' & map_headernames$varlist != 'x_anyother']) \n",
  "info = varinfo(some, info = c('ejscreen_apinames_old', 'csv', 'acs', 'varlist'))\n",
  "x = info[nchar(paste0(info$ejscreen_apinames_old, info$csv, info$acs)) > 0, ]",
  "head(x)",
  "\n\n"
)
head(x)
