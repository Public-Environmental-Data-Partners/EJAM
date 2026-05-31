# Historical entry point for map_headernames review comparisons.
#
# Current maintenance should use data-raw/map_headernames.csv as the source and
# data-raw/datacreate_map_headernames_review_artifacts.R for review artifacts,
# including optional old-vs-new redline workbooks.

old_option <- getOption("map_headernames_review_artifacts.suppress_autorun")
options(map_headernames_review_artifacts.suppress_autorun = TRUE)
source(file.path("data-raw", "datacreate_map_headernames_review_artifacts.R"))
options(map_headernames_review_artifacts.suppress_autorun = old_option)

message(
  "Use datacreate_map_headernames_review_artifacts(old_csv = <old_csv_path>) ",
  "to create map_headernames comparison artifacts."
)
