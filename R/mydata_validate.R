
#' Check a table of user-defined blockgroup indicators and get it ready to analyze
#'
#' @description
#' Checks a table that has one row per blockgroup and one or more columns of
#' user-defined indicators (scores, counts, denominators), along with the
#' metadata that describes those indicators. Returns the cleaned table and
#' metadata, how much of the US and of each State the data cover, and a plain
#' list of any problems found.
#'
#' @details
#' The table can cover any part of the US, such as one county or one State.
#'
#' What is checked:
#'
#' - FIPS codes: stored as text, leading zeroes, all blockgroups (12 digits),
#'   no repeats, and found in the list of blockgroups EJAM uses. Rows that
#'   cannot be matched are left out of the cleaned table and are listed in
#'   the `unmatched` element of the result, not dropped silently.
#' - Names: an indicator cannot have the name of an indicator built into EJAM.
#' - Columns: every indicator, and every weight, denominator or formula input
#'   it needs, has to be a column of the table or a column of
#'   [blockgroupstats] (such as `pop`). A column of the table is used in
#'   preference to a column of [blockgroupstats] with the same name.
#' - Values: numeric. Infinite values are changed to NA. Counts, weights and
#'   denominators cannot be negative.
#'
#' Coverage is reported for each indicator, using only the blockgroups that
#' have a usable value for it (and for the weight or the formula inputs it
#' needs). It is the share of population, for the US and for each State with
#' any data, living in those blockgroups.
#'
#' Tract data are recognized but not yet handled here: they first have to be
#' converted to blockgroups.
#'
#' The table you provide is not changed. A cleaned copy is returned.
#'
#' @param mydata data.frame or data.table with one row per blockgroup. One
#'   column has the blockgroup FIPS codes as text. The others are numeric.
#' @param mydata_map_headernames metadata describing the indicators, from
#'   [mydata_metadata()], or a small data.frame with at least a column named
#'   `rname`. If NULL, every numeric column of `mydata` other than the FIPS
#'   column is treated as an indicator to be aggregated as a
#'   population-weighted mean.
#' @param fips_colname name of the column of `mydata` that has the FIPS codes.
#'   If NULL, the first column found with a name like `bgfips`, `fips`, or
#'   `geoid` is used.
#' @param coverage_needed share of population that has to be covered before
#'   US or State averages, percentiles and ratios are considered possible.
#'   Default is 0.99.
#' @param stop_on_error TRUE (default) to stop with a message that lists every
#'   problem that prevents analysis. FALSE to return the list of problems
#'   without stopping, with `ok` set to FALSE.
#' @param quiet FALSE (default) to print a short summary and any notes.
#'
#' @return a list:
#'
#'   - `mydata`: cleaned data.table with columns `bgfips` and `bgid` first
#'   - `mydata_map_headernames`: the metadata, completed
#'   - `coverage`: data.frame with one row per indicator and zone (`"USA"` or a
#'     State abbreviation): number of blockgroups with usable data, population
#'     covered, population of the zone, `coverage` (0 to 1), and
#'     `comparisons_possible`
#'   - `problems`: data.frame with columns `level` (`"error"`, `"warning"` or
#'     `"note"`) and `message`
#'   - `unmatched`: data.frame of rows left out, with the FIPS code as provided
#'     and the reason
#'   - `builtin_columns`: names of columns that will be taken from
#'     [blockgroupstats] because they are not in `mydata`
#'   - `columns_needed`: for each indicator, the columns that must all have a
#'     value in a blockgroup for it to be usable there
#'   - `formulas_needed`: for each indicator, the formulas used to calculate it
#'   - `ok`: TRUE if nothing prevents analysis
#'
#' @seealso [mydata_metadata()]
#'
#' @examples
#' \dontrun{
#' # a table for one county, with one score and one count
#' x <- data.frame(blockgroupstats[substr(bgfips, 1, 5) == "10001", .(bgfips)])
#' x$myscore <- seq_len(nrow(x))
#' x$mycount <- 10
#' meta <- mydata_metadata(c("myscore", "mycount"),
#'                         calculation_type = c("wtdmean", "sum of counts"))
#' checked <- mydata_validate(x, meta)
#' checked$coverage
#' }
#'
#' @export
#'
mydata_validate <- function(mydata,
                            mydata_map_headernames = NULL,
                            fips_colname = NULL,
                            coverage_needed = 0.99,
                            stop_on_error = TRUE,
                            quiet = FALSE) {

  problems <- data.frame(level = character(0), message = character(0))
  add_problem <- function(level, ...) {
    problems[nrow(problems) + 1, ] <<- list(level, paste0(...))
    invisible(NULL)
  }
  examples <- function(x, n = 5) {
    x <- unique(x)
    paste0(paste0(utils::head(x, n), collapse = ", "), if (length(x) > n) {paste0(", and ", length(x) - n, " more")} else {""})
  }
  finish <- function(result) {
    result$problems <- problems
    result$ok <- !any(problems$level == "error")
    errs <- problems$message[problems$level == "error"]
    if (length(errs) > 0 && stop_on_error) {
      stop("The table cannot be analyzed until these are fixed:\n", paste0(" - ", errs, collapse = "\n"), call. = FALSE)
    }
    warns <- problems$message[problems$level == "warning"]
    if (length(warns) > 0) {
      warning(paste0(warns, collapse = "\n"), call. = FALSE)
    }
    if (!quiet) {
      notes <- problems$message[problems$level == "note"]
      if (length(notes) > 0) {message(paste0(notes, collapse = "\n"))}
    }
    return(result)
  }
  empty_result <- list(mydata = NULL, mydata_map_headernames = mydata_map_headernames, coverage = NULL,
                       problems = NULL, unmatched = NULL, builtin_columns = character(0),
                       columns_needed = list(), formulas_needed = list(), ok = FALSE)

  # the table ####
  if (!is.data.frame(mydata) || nrow(mydata) == 0) {
    add_problem("error", "mydata must be a data.frame or data.table with at least one row.")
    return(finish(empty_result))
  }
  mydata <- data.table::as.data.table(data.table::copy(mydata)) # a copy, so the table provided is never changed

  # FIPS column ####
  if (is.null(fips_colname)) {
    likely <- c("bgfips", "fips", "geoid", "blockgroupfips", "bg_fips", "fips_bg", "tractfips")
    found <- names(mydata)[tolower(names(mydata)) %in% likely]
    found <- found[order(match(tolower(found), likely))]
    if (length(found) == 0) {
      add_problem("error", "No column of FIPS codes was found. Name that column bgfips, or use the fips_colname parameter to say which column it is.")
      return(finish(empty_result))
    }
    fips_colname <- found[1]
  } else if (length(fips_colname) != 1 || !fips_colname %in% names(mydata)) {
    add_problem("error", "fips_colname must be the name of one column of mydata.")
    return(finish(empty_result))
  }
  fips_asgiven <- trimws(as.character(mydata[[fips_colname]]))
  if (!is.character(mydata[[fips_colname]])) {
    add_problem("note", "FIPS codes in column ", fips_colname, " were not stored as text. They were converted, and leading zeroes were restored where needed. Storing them as text is safer.")
  }
  fips <- suppressWarnings(fips_lead_zero(fips_asgiven, quiet = TRUE))
  n_zero_fixed <- sum(!is.na(fips) & fips != fips_asgiven)
  if (n_zero_fixed > 0 && is.character(mydata[[fips_colname]])) {
    add_problem("note", "A leading zero was restored in ", n_zero_fixed, " FIPS codes.")
  }
  ftype <- suppressWarnings(fipstype(fips, quiet = TRUE))
  ftype[is.na(ftype)] <- "not a FIPS code"
  types_found <- table(ftype[ftype != "not a FIPS code"])
  if (length(types_found) == 1 && names(types_found) == "tract") {
    add_problem("error", "The FIPS codes are for tracts. Tract data have to be converted to blockgroups before this step, and that conversion is not yet available.")
    return(finish(empty_result))
  }
  if (!"blockgroup" %in% names(types_found)) {
    add_problem("error", "No blockgroup FIPS codes were found in column ", fips_colname,
                ". A blockgroup FIPS code has 12 digits, such as 100010401001.",
                if (length(types_found) > 0) {paste0(" Found instead: ", paste0(names(types_found), collapse = ", "), ".")} else {""})
    return(finish(empty_result))
  }

  # rows that cannot be used ####
  if (!exists("bgid2fips")) {dataload_dynamic("bgid2fips", silent = TRUE)}
  bgid <- bgid2fips$bgid[match(fips, bgid2fips$bgfips)]
  reason <- rep(NA_character_, length(fips))
  reason[ftype == "not a FIPS code"] <- "not a valid FIPS code"
  reason[is.na(reason) & ftype != "blockgroup"] <- "not a blockgroup FIPS code"
  reason[is.na(reason) & is.na(bgid)] <- "not in the list of blockgroups EJAM uses for this data year"
  unmatched <- data.frame(fips = fips_asgiven[!is.na(reason)], reason = reason[!is.na(reason)])
  if (nrow(unmatched) > 0) {
    add_problem("warning", nrow(unmatched), " of ", length(fips), " rows were left out because the FIPS code is ",
                paste0(unique(unmatched$reason), collapse = ", or "), ": ", examples(unmatched$fips),
                ". They are listed in the unmatched element of the result.")
  }
  usable_row <- is.na(reason)
  dupes <- fips[usable_row][duplicated(fips[usable_row])]
  if (length(dupes) > 0) {
    add_problem("error", "Each blockgroup can appear only once, but these FIPS codes are repeated: ", examples(dupes), ".")
  }
  if (!any(usable_row)) {
    add_problem("error", "No rows could be matched to a blockgroup.")
    return(finish(utils::modifyList(empty_result, list(unmatched = unmatched))))
  }
  mydata[, (fips_colname) := NULL]
  othercols <- names(mydata)
  data.table::set(mydata, j = "bgfips", value = fips) # set() so a column of the table named fips or bgid cannot be picked up by mistake
  data.table::set(mydata, j = "bgid", value = bgid)
  data.table::setcolorder(mydata, c("bgfips", "bgid", setdiff(othercols, c("bgfips", "bgid"))))
  mydata <- mydata[usable_row, ]
  datacols <- setdiff(names(mydata), c("bgfips", "bgid"))

  # the metadata ####
  if (is.null(mydata_map_headernames)) {
    numericish <- datacols[vapply(datacols, function(nm) {is.numeric(mydata[[nm]])}, logical(1))]
    numericish <- setdiff(numericish, map_headernames$rname)
    if (length(numericish) == 0) {
      add_problem("error", "No metadata was provided, and the table has no numeric columns to treat as indicators (other than columns named like indicators built into EJAM).")
      return(finish(utils::modifyList(empty_result, list(unmatched = unmatched))))
    }
    mydata_map_headernames <- mydata_metadata(rname = numericish)
    add_problem("note", "No metadata was provided, so each of these columns is treated as an indicator to be averaged with population as the weight: ",
                paste0(numericish, collapse = ", "), ". Use mydata_metadata() to say otherwise.")
  }
  if (!is.data.frame(mydata_map_headernames) || !"rname" %in% names(mydata_map_headernames)) {
    add_problem("error", "mydata_map_headernames must be a data.frame with a column named rname, such as the output of mydata_metadata().")
    return(finish(utils::modifyList(empty_result, list(unmatched = unmatched))))
  }
  md <- as.data.frame(mydata_map_headernames, stringsAsFactors = FALSE)
  used_names <- md$rname[md$rname %in% map_headernames$rname]
  if (length(used_names) > 0) {
    add_problem("error", "These names are already used by indicators built into EJAM, so a different name is needed: ",
                paste0(unique(used_names), collapse = ", "), ".")
    return(finish(utils::modifyList(empty_result, list(unmatched = unmatched))))
  }
  needed_cols <- c("calculation_type", "denominator", "formula", "comparisons", "allocation", "source_geography", "vartype")
  if (!all(needed_cols %in% names(md))) {
    # a small hand-made table: let mydata_metadata() fill in everything else
    args <- as.list(md[, intersect(names(md), names(formals(mydata_metadata))), drop = FALSE])
    md <- tryCatch(do.call(mydata_metadata, args), error = function(e) {
      add_problem("error", "The metadata could not be completed: ", conditionMessage(e))
      NULL
    })
    if (is.null(md)) {
      return(finish(utils::modifyList(empty_result, list(unmatched = unmatched))))
    }
  }
  is_indicator <- md$vartype %in% "raw"
  ind <- md[is_indicator, , drop = FALSE]
  ind$formula[is.na(ind$formula)] <- ""

  # columns each indicator needs ####
  formula_inputs <- lapply(ind$formula, function(f) {
    if (!nzchar(f)) {return(character(0))}
    rhs <- sub("^[^<=]*(<-|=)", "", f)
    tryCatch(all.vars(parse(text = rhs)[[1]]), error = function(e) character(0))
  })
  names(formula_inputs) <- ind$rname
  needs <- lapply(seq_len(nrow(ind)), function(i) {
    switch(ind$calculation_type[i],
           "wtdmean" = c(ind$rname[i], ind$denominator[i]),
           "sum of counts" = if (nzchar(ind$formula[i])) {formula_inputs[[i]]} else {ind$rname[i]},
           "formula" = formula_inputs[[i]],
           ind$rname[i])
  })
  names(needs) <- ind$rname
  needs <- lapply(needs, function(z) {unique(z[!is.na(z) & nzchar(z)])})
  # an input that is itself calculated by a formula is replaced by what that formula needs
  for (pass in seq_len(nrow(ind))) {
    changed <- FALSE
    for (i in seq_along(needs)) {
      calculated <- setdiff(intersect(needs[[i]], ind$rname[nzchar(ind$formula)]), c(names(needs)[i], datacols))
      if (length(calculated) > 0) {
        needs[[i]] <- unique(c(setdiff(needs[[i]], calculated), unlist(needs[calculated])))
        changed <- TRUE
      }
    }
    if (!changed) {break}
  }
  allneeded <- unique(unlist(needs))
  from_table <- intersect(allneeded, datacols)
  builtin_columns <- intersect(setdiff(allneeded, datacols), names(blockgroupstats))
  missing_cols <- setdiff(allneeded, c(datacols, builtin_columns))
  for (i in seq_along(needs)) {
    lacking <- intersect(needs[[i]], missing_cols)
    if (length(lacking) > 0) {
      add_problem("error", "Indicator ", names(needs)[i], " needs ",
                  if (identical(lacking, names(needs)[i])) {"a column with that name"} else {paste0("column", if (length(lacking) > 1) {"s"} else {""}, " ", paste0(lacking, collapse = ", "))},
                  ", which is not in the table",
                  if (identical(lacking, names(needs)[i])) {"."} else {" and is not a column of blockgroupstats."})
    }
  }
  shadowed <- intersect(from_table, names(blockgroupstats))
  if (length(shadowed) > 0) {
    add_problem("note", "The table's own column is used, not the EJAM column of the same name, for: ", paste0(shadowed, collapse = ", "), ".")
  }

  # values ####
  count_like <- unique(c(ind$rname[ind$calculation_type == "sum of counts"], ind$denominator,
                         unlist(formula_inputs)))
  for (nm in from_table) {
    v <- mydata[[nm]]
    if (!is.numeric(v)) {
      asnum <- suppressWarnings(as.numeric(as.character(v)))
      notnumber <- !is.na(v) & nzchar(trimws(as.character(v))) & is.na(asnum)
      if (any(notnumber)) {
        add_problem("error", "Column ", nm, " has ", sum(notnumber), " values that are not numbers, such as: ", examples(as.character(v)[notnumber], 3), ".")
        next
      }
      data.table::set(mydata, j = nm, value = asnum)
      add_problem("note", "Column ", nm, " was stored as text and was converted to numbers.")
      v <- asnum
    }
    if (any(is.infinite(v) | is.nan(v))) {
      add_problem("warning", "Column ", nm, " had ", sum(is.infinite(v) | is.nan(v)), " infinite or undefined values, which are now treated as missing.")
      v[is.infinite(v) | is.nan(v)] <- NA
      data.table::set(mydata, j = nm, value = v)
    }
    if (nm %in% count_like && any(v < 0, na.rm = TRUE)) {
      add_problem("error", "Column ", nm, " is a count, weight or denominator, so it cannot be negative, but ", sum(v < 0, na.rm = TRUE), " values are.")
    }
  }
  counts <- ind$rname[ind$calculation_type == "sum of counts"]
  if (length(counts) > 0) {
    add_problem("note", "Counts (", paste0(counts, collapse = ", "),
                ") will be split in proportion to population where a site includes only part of a blockgroup. That assumes they are spread within the blockgroup the way residents are, so treat the results as estimates.")
  }

  # coverage, for each indicator, from blockgroups with usable values ####
  bgpop <- blockgroupstats[, unique(c("bgid", "ST", "pop", builtin_columns)), with = FALSE]
  here <- match(mydata$bgid, bgpop$bgid)
  zone_pop <- bgpop[, list(pop_zone = sum(pop, na.rm = TRUE)), by = "ST"]
  us_pop <- sum(bgpop$pop, na.rm = TRUE)
  coverage <- lapply(names(needs), function(nm) {
    usable <- rep(TRUE, nrow(mydata))
    for (col in needs[[nm]]) {
      if (col %in% names(mydata)) {
        usable <- usable & !is.na(mydata[[col]])
      } else if (col %in% builtin_columns) {
        usable <- usable & !is.na(bgpop[[col]][here])
      } else {
        usable <- usable & FALSE
      }
    }
    covered <- data.table::data.table(ST = bgpop$ST[here][usable], pop = bgpop$pop[here][usable])
    bystate <- covered[, list(n_blockgroups = .N, pop_covered = sum(pop, na.rm = TRUE)), by = "ST"]
    bystate <- merge(bystate, zone_pop, by = "ST")
    data.table::setnames(bystate, "ST", "zone")
    out <- rbind(
      data.table::data.table(zone = "USA", n_blockgroups = sum(usable), pop_covered = sum(covered$pop, na.rm = TRUE), pop_zone = us_pop),
      bystate[order(bystate$zone), ]
    )
    cbind(indicator = nm, out)
  })
  coverage <- as.data.frame(data.table::rbindlist(coverage))
  coverage$coverage <- ifelse(coverage$pop_zone > 0, coverage$pop_covered / coverage$pop_zone, NA_real_)
  coverage$comparisons_possible <- !is.na(coverage$coverage) & coverage$coverage >= coverage_needed

  # the formulas to run, in addition to its own, for an indicator whose formula uses other calculated columns
  own_formula <- stats::setNames(ind$formula, ind$rname)
  formulas_needed <- lapply(ind$rname, function(nm) {
    todo <- nm
    found <- character(0)
    while (length(todo) > 0) {
      this <- todo[1]
      todo <- todo[-1]
      if (this %in% found || !nzchar(own_formula[[this]])) {next}
      found <- c(found, this)
      inputs <- intersect(formula_inputs[[this]], ind$rname[nzchar(ind$formula)])
      todo <- c(todo, setdiff(inputs, c(found, datacols)))
    }
    unname(own_formula[found])
  })
  names(formulas_needed) <- ind$rname

  result <- list(mydata = mydata, mydata_map_headernames = md, coverage = coverage, problems = NULL,
                 unmatched = unmatched, builtin_columns = builtin_columns,
                 columns_needed = needs, formulas_needed = formulas_needed, ok = FALSE)
  result <- finish(result)

  if (!quiet) {
    us <- coverage[coverage$zone == "USA", ]
    states_ok <- tapply(coverage$comparisons_possible[coverage$zone != "USA"], coverage$indicator[coverage$zone != "USA"], sum)
    message(nrow(mydata), " blockgroups in ", length(unique(bgpop$ST[here])), " State(s) are ready to analyze.")
    for (i in seq_len(nrow(us))) {
      n_states <- if (us$indicator[i] %in% names(states_ok)) {states_ok[[us$indicator[i]]]} else {0}
      message("  ", us$indicator[i], ": ", us$n_blockgroups[i], " blockgroups with usable data, covering ",
              format(round(100 * us$coverage[i], 1), nsmall = 1), "% of US population. US comparisons ",
              if (us$comparisons_possible[i]) {"are possible"} else {"are not possible"},
              "; State comparisons are possible in ", n_states, " State(s).")
    }
  }
  return(result)
}
