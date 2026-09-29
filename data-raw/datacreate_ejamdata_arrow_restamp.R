############################################################################# #
# Restamp the version attributes stored INSIDE ejamdata .arrow files,
# without changing their data, for upload as assets on a new ejamdata release.
#
# Why: arrow::write_ipc_file() saves a table's R attributes (ejam_package_version,
# acs_version, etc.) inside the .arrow file, and arrow::read_ipc_file() restores
# them -- that is what attributes(bgej) shows. When the data are reused
# unchanged for a new EJAM release, only these labels need updating.
#
# How to use:
#  1. Check out the branch whose DESCRIPTION has the right Version / VersionACS /
#     VersionEJSCREEN / ReleaseDate* fields (e.g. v3.2022.3-version-bump).
#  2. Have the current copies of the six files in data/ (e.g. from ejamdata
#     v3.2022.0; data/ejamdata_version.txt says which release they came from).
#     Set EJAM_ARROW_RESTAMP_INPUT and EJAM_ARROW_RESTAMP_OUTPUT if the inputs
#     and outputs belong in other folders. The two folders must differ.
#  3. From the root of the EJAM source folder, run:
#        Rscript --vanilla data-raw/datacreate_ejamdata_arrow_restamp.R
#     or source() it in a fresh R session WITHOUT library(EJAM).
#     Set R_LIBS_USER if --vanilla cannot see the installed arrow/desc packages.
#     EJAM is deliberately not attached: attaching it tries to download the
#     arrow data named by DESCRIPTION's ejamdata_required_tag, which may not
#     exist yet.
#  4. Review the six files written to `outdir`, stage them with five current
#     FRS files, and upload all 11 to the new ejamdata release draft.
#
# The stamps mirror R/metadata_mapping.R's default_metadata plus
# date_saved_in_package, i.e. what metadata_add() would set. Source dates such
# as download_date and released are preserved from the input file.
############################################################################# #
### if these are not installed and attached, do that:
# library(arrow)
# library(desc)

indir  <- Sys.getenv("EJAM_ARROW_RESTAMP_INPUT", "data")
outdir <- Sys.getenv(
  "EJAM_ARROW_RESTAMP_OUTPUT",
  file.path("data-raw", "pipeline_outputs", "ejamdata-restamp")
)
save_date <- Sys.getenv("EJAM_ARROW_RESTAMP_DATE", as.character(Sys.Date()))
if (is.na(as.Date(save_date, format = "%Y-%m-%d")) ||
    format(as.Date(save_date), "%Y-%m-%d") != save_date) {
  stop("EJAM_ARROW_RESTAMP_DATE must be YYYY-MM-DD")
}
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
if (normalizePath(indir, mustWork = TRUE) == normalizePath(outdir, mustWork = TRUE)) {
  stop("Input and output folders must differ")
}
files  <- c("bgej", "blockwts", "bgid2fips", "blockid2fips", "blockpoints", "quaddata")

d <- desc::description$new("DESCRIPTION")
stamps <- list(
  ejam_package_version  = d$get("Version"),
  ejscreen_version      = d$get("VersionEJSCREEN"),
  ejscreen_releasedate  = d$get("ReleaseDateEJSCREEN"),
  acs_releasedate       = d$get("ReleaseDateACS"),
  acs_version           = d$get("VersionACS"),
  census_version        = d$get("VersionCensus"),
  date_saved_in_package = save_date
)
stamps <- lapply(stamps, unname)
cat("Stamps from DESCRIPTION:\n")
str(stamps)
if (any(is.na(unlist(stamps))) || any(!nzchar(unlist(stamps)))) {
  stop("A DESCRIPTION field is missing -- check the branch")
}

keys <- names(stamps)
report <- list()

for (f in files) {
  inpath  <- file.path(indir,  paste0(f, ".arrow"))
  outpath <- file.path(outdir, paste0(f, ".arrow"))
  stopifnot(file.exists(inpath))
  cat("\n==", f, "\n")

  x <- arrow::read_ipc_file(inpath)
  before <- attributes(x)[keys]
  other <- setdiff(names(attributes(x)), c(keys, "row.names"))
  other_before <- attributes(x)[other]
  for (k in keys) attr(x, k) <- stamps[[k]]
  arrow::write_ipc_file(x, sink = outpath)

  # Verify: same shape, columns, classes and values; only the stamps changed.
  new  <- arrow::read_ipc_file(outpath)
  stopifnot(
    identical(dim(x), dim(new)),
    identical(names(x), names(new)),
    identical(lapply(x, class), lapply(new, class))
  )
  for (col in names(x)) {
    if (!identical(x[[col]], new[[col]])) stop("Values changed in ", f, "$", col)
  }
  for (k in keys) {
    if (!identical(attr(new, k), stamps[[k]])) stop("Stamp not saved: ", f, " ", k)
  }
  for (k in other) {
    if (!identical(other_before[[k]], attr(new, k))) {
      stop("Other attribute changed: ", f, " ", k)
    }
  }

  report[[f]] <- data.frame(
    file = f, rows = nrow(new), cols = ncol(new),
    MB_before = round(file.size(inpath) / 1e6, 1), MB_after = round(file.size(outpath) / 1e6, 1),
    acs_version_before = paste(unlist(before$acs_version), collapse = ""),
    ejam_pkg_before = paste(unlist(before$ejam_package_version), collapse = ""),
    ejam_pkg_after = attr(new, "ejam_package_version")
  )
  cat("  OK: data identical; stamps updated.\n")
  rm(x, new)
  invisible(gc())
}

cat("\nSummary:\n")
print(do.call(rbind, report), row.names = FALSE)
cat("\nWritten to:", normalizePath(outdir), "\n")

############################################################################# #
# Publishing (by hand, after reviewing the files):
#
# Stage these six files with the five refreshed FRS assets and run
# EJAM:::datasets_arrow_publish(..., dry_run = TRUE) against all 11. For the
# existing saved draft, use `gh release upload v3.2022.3 ... --repo
# Public-Environmental-Data-Partners/ejamdata` to preserve its title, notes,
# and draft status. Replacing previously uploaded assets needs --clobber and
# verification of the resulting remote names, sizes, and SHA-256 digests.
#
# The release needs ALL 11 files EJAM downloads (EJAM:::.arrow_ds_names):
# these 6 plus frs, frs_by_programid, frs_by_naics, frs_by_sic, frs_by_mact.
# Do not mark it Latest, and never delete or edit ejamdata v3.2022.0.
# After publication, update data/ejamdata_version.txt and check the deployed
# image pins separately. An asset-filled draft is not a public install source.
############################################################################# #
