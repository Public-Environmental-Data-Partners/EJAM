# Normalize API ZIP inputs without downloading boundaries. Both wrappers use
# this so URL generation and JSON bodies identify the same ZCTA areas.
zipcodes_from_input <- function(zip = NULL, zipcode = NULL) {
  if (!is.null(zip) && !is.null(zipcode)) {
    stop("Provide only one of zip or zipcode (they are aliases).")
  }
  value <- if (is.null(zip)) zipcode else zip
  if (is.null(value)) return(NULL)
  value <- trimws(unlist(strsplit(as.character(unlist(value)), ",", fixed = TRUE)))
  if (!length(value) || anyNA(value) ||
      any(!grepl("^([0-9]{3,5}|[0-9]{5}-?[0-9]{4})$", value))) {
    stop("zip/zipcode must contain ZIP codes, as a vector or comma-separated string.")
  }
  value <- substr(gsub("-", "", value, fixed = TRUE), 1, 5)
  unique(sprintf("%05d", as.integer(value)))
}
