###################################################### #

#' Download raw 2020 Island Areas Census DHC block group tables
#'
#' @details This is a draft raw-data stage for AS/GU/MP/VI. These areas are
#' not included in ACS, so the closest Census source is the 2020 Island Areas
#' Census Detailed Housing Characteristics data. The returned object mirrors the
#' `bg_acs_raw` table-list shape closely enough for later formula-mapping work.
#'
#' @param tables 2020 Island Areas Census DHC table groups to download, such as `"P1"`.
#' @param areas Island Area postal abbreviations to include.
#' @param key optional Census API key. Defaults to `CENSUS_API_KEY`.
#' @param download_fun function used to download one API URL. Defaults to
#'   [census_api_json_table()].
#'
#' @return list with raw `blockgroup` Island Areas Census DHC table lists plus metadata.
#'
#' @keywords internal
#'
download_bg_islandareas_raw <- function(tables = islandareas_tables_for_bg_acsdata(),
                                areas = c("AS", "GU", "MP", "VI"),
                                key = Sys.getenv("CENSUS_API_KEY", unset = ""),
                                download_fun = census_api_json_table,
                                metadata_fun = census_api_group_variables) {
  if (length(tables) == 0) {
    stop("tables must include at least one 2020 Island Areas Census DHC table name")
  }

  tables <- unique(toupper(as.vector(tables)))
  area_info <- islandareas_area_metadata(areas)
  download_fun <- match.fun(download_fun)

  blockgroup <- stats::setNames(vector("list", length(tables)), tables)
  for (table in tables) {
    by_area <- lapply(seq_len(NROW(area_info)), function(i) {
      meta <- area_info[i]
      url <- islandareas_dhc_api_url(
        endpoint = meta$dhc_endpoint,
        state = meta$FIPS.ST,
        table = table,
        key = key
      )
      tab <- normalize_islandareas_dhc_blockgroup_table(download_fun(url), ST = meta$ST)
      if (!is.null(metadata_fun)) {
        tab <- add_islandareas_canonical_columns(
          tab,
          table = table,
          endpoint = meta$dhc_endpoint,
          key = key,
          metadata_fun = metadata_fun
        )
      }
      tab
    })
    blockgroup[[table]] <- data.table::rbindlist(by_area, fill = TRUE)
    data.table::setorder(blockgroup[[table]], bgfips)
  }

  out <- list(
    stage = "bg_islandareas_raw",
    yr = 2020L,
    downloaded_at = as.character(Sys.time()),
    source = "2020 Island Areas Census Detailed Housing Characteristics via Census API",
    source_url = "https://www.census.gov/programs-surveys/decennial-census/decade/2020/planning-management/release/2020-island-areas-data-products.html",
    blockgroup_tables = tables,
    areas = area_info,
    blockgroup = blockgroup
  )
  class(out) <- c("ejam_bg_islandareas_raw", class(out))
  out
}

islandareas_tables_for_bg_acsdata <- function() {
  c(
    "P1",    # total population
    "PCT1",  # exact single-year age by sex, metadata exists but block-group values may be unavailable
    "P5",    # Hispanic origin and non-Hispanic race
    "P3",    # race alone and two or more races
    "PBG74", # ratio of income to poverty level
    "PCT80", # ratio of income to poverty level
    "PBG78", # household poverty
    "PBG19", # educational attainment
    "PCT26", # language spoken at home and ability to speak English
    "HBG18", # year structure built
    "PBG32", # employment status
    "H4",    # tenure
    "HBG42", # internet subscriptions
    "PBG29", # health insurance coverage
    "PBG68", # per capita income
    "PBG26"  # disability status
  )
}

islandareas_area_metadata <- function(areas = c("AS", "GU", "MP", "VI")) {
  x <- data.table::data.table(
    ST = c("AS", "GU", "MP", "VI"),
    FIPS.ST = c("60", "66", "69", "78"),
    statename = c(
      "American Samoa",
      "Guam",
      "Commonwealth of the Northern Mariana Islands",
      "United States Virgin Islands"
    ),
    dhc_endpoint = c("dhcas", "dhcgu", "dhcmp", "dhcvi")
  )

  areas <- unique(toupper(as.vector(areas)))
  bad <- setdiff(areas, x$ST)
  if (length(bad) > 0) {
    stop("Unsupported Island Areas: ", paste(bad, collapse = ", "))
  }
  x[match(areas, ST)]
}

islandareas_dhc_api_url <- function(endpoint,
                            state,
                            table,
                            geography = "block group",
                            key = Sys.getenv("CENSUS_API_KEY", unset = "")) {
  encode <- function(x) utils::URLencode(x, reserved = TRUE)
  url <- paste0(
    "https://api.census.gov/data/2020/dec/", endpoint,
    "?get=", encode(paste0("group(", toupper(table), ")")),
    "&for=", encode(paste0(geography, ":*")),
    "&in=", encode(paste0("state:", state)),
    "&in=", encode("county:*"),
    "&in=", encode("tract:*")
  )
  if (nzchar(key)) {
    url <- paste0(url, "&key=", encode(key))
  }
  url
}

census_api_json_table <- function(url) {
  x <- jsonlite::fromJSON(url, simplifyVector = FALSE)
  census_api_json_to_data_table(x)
}

census_api_group_variables <- function(endpoint,
                                       table,
                                       key = Sys.getenv("CENSUS_API_KEY", unset = "")) {
  encode <- function(x) utils::URLencode(x, reserved = TRUE)
  url <- paste0(
    "https://api.census.gov/data/2020/dec/", endpoint,
    "/groups/", encode(toupper(table)), ".json"
  )
  if (nzchar(key)) {
    url <- paste0(url, "?key=", encode(key))
  }
  x <- jsonlite::fromJSON(url)$variables
  out <- data.table::rbindlist(lapply(names(x), function(nm) {
    data.table::data.table(
      name = nm,
      label = if (is.null(x[[nm]]$label)) NA_character_ else islandareas_clean_label(x[[nm]]$label),
      concept = if (is.null(x[[nm]]$concept)) NA_character_ else x[[nm]]$concept
    )
  }), fill = TRUE)
  out[grepl("N$", name) & !grepl("NA$", name)]
}

census_api_json_to_data_table <- function(x) {
  if (is.data.frame(x)) {
    return(normalize_census_api_column_types(data.table::as.data.table(data.table::copy(x))))
  }
  if (!is.list(x) || length(x) < 2) {
    stop("Census API response must be a header row plus at least one data row")
  }

  header <- as.character(unlist(x[[1]], use.names = FALSE))
  rows <- lapply(x[-1], function(row) {
    values <- vapply(row, function(value) {
      if (is.null(value)) {
        return(NA_character_)
      }
      as.character(value)
    }, character(1))
    if (length(values) < length(header)) {
      values <- c(values, rep(NA_character_, length(header) - length(values)))
    }
    stats::setNames(as.list(values[seq_along(header)]), header)
  })
  normalize_census_api_column_types(data.table::rbindlist(rows, fill = TRUE))
}

normalize_census_api_column_types <- function(x) {
  numeric_cols <- grep("^[A-Z]+[0-9]+[A-Z]*_[0-9]+[A-Z]*N$", names(x), value = TRUE)
  numeric_cols <- setdiff(numeric_cols, grep("NA$", numeric_cols, value = TRUE))
  for (col in numeric_cols) {
    x[, (col) := suppressWarnings(as.numeric(get(col)))]
    x[get(col) <= -666666666, (col) := NA_real_]
  }
  x
}

normalize_islandareas_dhc_blockgroup_table <- function(x, ST) {
  x <- data.table::as.data.table(data.table::copy(x))
  x <- normalize_census_api_column_types(x)
  required <- c("state", "county", "tract", "block group")
  missing_cols <- setdiff(required, names(x))
  if (length(missing_cols) > 0) {
    stop("Island Areas Census DHC table is missing required geography columns: ", paste(missing_cols, collapse = ", "))
  }

  x[, fips := paste0(state, county, tract, `block group`)]
  x[, bgfips := fips]
  if (!"GEO_ID" %in% names(x)) {
    x[, GEO_ID := paste0("1500000US", bgfips)]
  }
  x[, SUMLEVEL := "150"]
  x[, ST := ST]

  leading <- intersect(c("GEO_ID", "fips", "bgfips", "SUMLEVEL", "ST", "NAME"), names(x))
  data.table::setcolorder(x, c(leading, setdiff(names(x), leading)))
  x
}

add_islandareas_canonical_columns <- function(x,
                                      table,
                                      endpoint,
                                      key = Sys.getenv("CENSUS_API_KEY", unset = ""),
                                      metadata_fun = census_api_group_variables) {
  vars <- metadata_fun(endpoint = endpoint, table = table, key = key)
  table <- toupper(table)

  if (table == "PCT1") {
    x[, ISLANDAREAS_POP := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_MALE := islandareas_col_by_label(x, vars, "^!!Total:!!Male:$")]
    x[, ISLANDAREAS_FEMALE := islandareas_col_by_label(x, vars, "^!!Total:!!Female:$")]
    age <- islandareas_age_variable_metadata(vars)
    x[, ISLANDAREAS_UNDER5 := islandareas_sum(x, age[age < 5, name])]
    x[, ISLANDAREAS_UNDER18 := islandareas_sum(x, age[age < 18, name])]
    x[, ISLANDAREAS_OVER64 := islandareas_sum(x, age[age >= 65, name])]

  } else if (table == "P5") {
    x[, ISLANDAREAS_HISP := islandareas_sum_by_label(x, vars, "Hispanic or Latino \\(of any race\\)$")]
    x[, ISLANDAREAS_NHWA := islandareas_sum_by_label(x, vars, "Not Hispanic or Latino:!!One Race:!!White$")]
    x[, ISLANDAREAS_NHBA := islandareas_sum_by_label(x, vars, "Not Hispanic or Latino:!!One Race:!!Black or African American$")]
    x[, ISLANDAREAS_NHAIANA := islandareas_sum_by_label(x, vars, "Not Hispanic or Latino:!!One Race:!!American Indian and Alaska Native$")]
    x[, ISLANDAREAS_NHAA := islandareas_sum_by_label(x, vars, "Not Hispanic or Latino:!!One Race:!!Asian:$")]
    x[, ISLANDAREAS_NHNHPIA := islandareas_sum_by_label(x, vars, "Not Hispanic or Latino:!!One Race:!!Native Hawaiian and Other Pacific Islander:$")]
    x[, ISLANDAREAS_NHOTHERALONE := islandareas_sum_by_label(x, vars, "Not Hispanic or Latino:!!One Race:!!Some Other Race$")]
    x[, ISLANDAREAS_NHMULTI := islandareas_sum_by_label(x, vars, "Not Hispanic or Latino:!!Two or More Races:$")]

  } else if (table == "P3") {
    x[, ISLANDAREAS_WA := islandareas_sum_by_label(x, vars, "!!Total:!!One Race:!!White$")]
    x[, ISLANDAREAS_BA := islandareas_sum_by_label(x, vars, "!!Total:!!One Race:!!Black or African American$")]
    x[, ISLANDAREAS_AIANA := islandareas_sum_by_label(x, vars, "!!Total:!!One Race:!!American Indian and Alaska Native$")]
    x[, ISLANDAREAS_AA := islandareas_sum_by_label(x, vars, "!!Total:!!One Race:!!Asian:$")]
    x[, ISLANDAREAS_NHPIA := islandareas_sum_by_label(x, vars, "!!Total:!!One Race:!!Native Hawaiian and Other Pacific Islander:$")]
    x[, ISLANDAREAS_OTHERALONE := islandareas_sum_by_label(x, vars, "!!Total:!!One Race:!!Some Other Race$")]
    x[, ISLANDAREAS_MULTI := islandareas_sum_by_label(x, vars, "!!Total:!!Two or More Races:$")]

  } else if (table %in% c("PBG74", "PCT80")) {
    x[, ISLANDAREAS_POVKNOWN := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_POV2PLUS := islandareas_sum_by_label(x, vars, "2\\.00 and over$")]

  } else if (table == "PBG78") {
    x[, ISLANDAREAS_HH_POV_UNIVERSE := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_HH_POOR := islandareas_col_by_label(x, vars, "^!!Total:!!Income in 2019 below poverty level:$")]

  } else if (table == "PBG19") {
    x[, ISLANDAREAS_AGE25UP := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_LTHS := islandareas_sum_by_label(x, vars, "Less than 9th grade|9th grade to 12th grade, no diploma")]

  } else if (table == "PCT26") {
    x[, ISLANDAREAS_LAN_UNIVERSE := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_LAN_ENGLISH := islandareas_sum_by_label(x, vars, "Speak only English$")]
    x[, ISLANDAREAS_LINGISO := islandareas_sum_by_label(x, vars, "Speak English less than \"very well\"$")]

  } else if (table == "HBG18") {
    x[, ISLANDAREAS_BUILTUNITS := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_PRE1960 := islandareas_sum_by_label(x, vars, "Built 1950 to 1959$|Built 1940 to 1949$|Built 1939 or earlier$")]

  } else if (table == "PBG32") {
    x[, ISLANDAREAS_UNEMPLOYEDBASE := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_LABORFORCE := islandareas_sum_by_label(x, vars, "In labor force:!!Civilian:$")]
    x[, ISLANDAREAS_UNEMPLOYED := islandareas_sum_by_label(x, vars, "Civilian:!!Unemployed$")]

  } else if (table == "H4") {
    x[, ISLANDAREAS_OCCUPIEDUNITS := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_OWNEDUNITS := islandareas_sum_by_label(x, vars, "Owned with a mortgage or a loan$|Owned free and clear$")]

  } else if (table == "HBG42") {
    x[, ISLANDAREAS_BROADBAND_UNIVERSE := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_BROADBAND_WITH := islandareas_col_by_label(x, vars, "With an Internet subscription:!!Broadband of any type:$")]

  } else if (table == "PBG29") {
    x[, ISLANDAREAS_HEALTH_UNIVERSE := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_NOHEALTH := islandareas_sum_by_label(x, vars, "No health insurance coverage$")]

  } else if (table == "PBG68") {
    x[, ISLANDAREAS_PERCAPINCOME := islandareas_col_by_label(x, vars, "Per capita income in 2019")]

  } else if (table == "PBG26") {
    x[, ISLANDAREAS_DISAB_UNIVERSE := islandareas_col_by_label(x, vars, "^!!Total:$")]
    x[, ISLANDAREAS_DISABILITY := islandareas_sum_by_label(x, vars, "With a disability$")]
  }

  x
}

islandareas_clean_label <- function(label) {
  trimws(gsub("\\s+", " ", as.character(label)))
}

islandareas_col_by_label <- function(x, vars, pattern) {
  cols <- vars$name[grepl(pattern, islandareas_clean_label(vars$label), perl = TRUE)]
  if (length(cols) == 0) {
    return(rep(NA_real_, NROW(x)))
  }
  islandareas_sum(x, cols[1])
}

islandareas_sum_by_label <- function(x, vars, pattern) {
  islandareas_sum(x, vars$name[grepl(pattern, islandareas_clean_label(vars$label), perl = TRUE)])
}

islandareas_age_variable_metadata <- function(vars) {
  x <- data.table::copy(vars)
  x[, label := islandareas_clean_label(label)]
  x <- x[grepl("!!Total:!!(Male|Female):!!", label)]
  x[, age := islandareas_age_from_label(label)]
  x[!is.na(age), .(name, age)]
}

islandareas_age_from_label <- function(label) {
  label <- islandareas_clean_label(label)
  out <- rep(NA_integer_, length(label))
  out[grepl("Under 1 year$", label)] <- 0L

  years <- grepl("!![0-9]+ years?$", label, perl = TRUE)
  out[years] <- as.integer(sub(".*!!([0-9]+) years?$", "\\1", label[years], perl = TRUE))

  ranges <- grepl("!![0-9]+ to [0-9]+ years$", label, perl = TRUE)
  out[ranges] <- as.integer(sub(".*!!([0-9]+) to [0-9]+ years$", "\\1", label[ranges], perl = TRUE))

  over <- grepl("!![0-9]+ years and over$", label, perl = TRUE)
  out[over] <- as.integer(sub(".*!!([0-9]+) years and over$", "\\1", label[over], perl = TRUE))

  out
}

calc_bg_islandareasdata <- function(islandareas_raw) {
  islandareas <- merge_islandareas_raw_tables(islandareas_raw_component(islandareas_raw, "blockgroup"))
  data.table::setDT(islandareas)
  islandareas[, bgfips := fips]

  out <- islandareas[, .(bgfips)]
  out[, bgid := bgfips]
  out[, islandareas_source := "2020 Island Areas Census DHC"]

  out[, pop := islandareas_value_any(islandareas, c("ISLANDAREAS_POP", "PCT1_001N", "P1_001N"))]
  out[, male := islandareas_value_any(islandareas, c("ISLANDAREAS_MALE", "PCT1_002N"), default = NA_real_)]
  out[, female := islandareas_value_any(islandareas, c("ISLANDAREAS_FEMALE", "PCT1_106N"), default = NA_real_)]
  out[, under5 := islandareas_value_any(islandareas, "ISLANDAREAS_UNDER5", default = islandareas_sum(islandareas, c(sprintf("PCT1_%03dN", 3:7), sprintf("PCT1_%03dN", 107:111))))]
  out[, under18 := islandareas_value_any(islandareas, "ISLANDAREAS_UNDER18", default = islandareas_sum(islandareas, c(sprintf("PCT1_%03dN", 3:20), sprintf("PCT1_%03dN", 107:124))))]
  out[, over64 := islandareas_value_any(islandareas, "ISLANDAREAS_OVER64", default = islandareas_sum(islandareas, c(sprintf("PCT1_%03dN", 68:105), sprintf("PCT1_%03dN", 172:209))))]
  out[, over17 := pop - under18]
  out[, pctunder5 := islandareas_ratio(under5, pop)]
  out[, pctunder18 := islandareas_ratio(under18, pop)]
  out[, pctover64 := islandareas_ratio(over64, pop)]
  out[, pctover17 := islandareas_ratio(over17, pop)]
  out[, pctfemale := islandareas_ratio(female, pop)]
  out[, pctmale := islandareas_ratio(male, pop)]

  out[, hisp := islandareas_value_any(islandareas, c("ISLANDAREAS_HISP", "P5_002N"))]
  out[, nonhisp := islandareas_value_any(islandareas, c("ISLANDAREAS_NONHISP", "P5_003N"))]
  out[, nhwa := islandareas_value_any(islandareas, c("ISLANDAREAS_NHWA", "P5_026N"))]
  out[, nhba := islandareas_value_any(islandareas, c("ISLANDAREAS_NHBA", "P5_027N"))]
  out[, nhaiana := islandareas_value_any(islandareas, c("ISLANDAREAS_NHAIANA", "P5_028N"))]
  out[, nhnhpia := islandareas_value_any(islandareas, c("ISLANDAREAS_NHNHPIA", "P5_005N"))]
  out[, nhaa := islandareas_value_any(islandareas, c("ISLANDAREAS_NHAA", "P5_017N"))]
  out[, nhotheralone := islandareas_value_any(islandareas, c("ISLANDAREAS_NHOTHERALONE", "P5_029N"))]
  out[, nhmulti := islandareas_value_any(islandareas, c("ISLANDAREAS_NHMULTI", "P5_030N"))]
  out[, nonmins := nhwa]
  out[, mins := pop - nhwa]
  out[, pcthisp := islandareas_ratio(hisp, pop)]
  out[, pctnhwa := islandareas_ratio(nhwa, pop)]
  out[, pctnhba := islandareas_ratio(nhba, pop)]
  out[, pctnhaiana := islandareas_ratio(nhaiana, pop)]
  out[, pctnhnhpia := islandareas_ratio(nhnhpia, pop)]
  out[, pctnhaa := islandareas_ratio(nhaa, pop)]
  out[, pctnhotheralone := islandareas_ratio(nhotheralone, pop)]
  out[, pctnhmulti := islandareas_ratio(nhmulti, pop)]
  out[, pctmin := islandareas_ratio(mins, pop)]

  out[, wa := islandareas_value_any(islandareas, c("ISLANDAREAS_WA", "P3_024N"))]
  out[, ba := islandareas_value_any(islandareas, c("ISLANDAREAS_BA", "P3_025N"))]
  out[, aiana := islandareas_value_any(islandareas, c("ISLANDAREAS_AIANA", "P3_026N"))]
  out[, aa := islandareas_value_any(islandareas, c("ISLANDAREAS_AA", "P3_015N"))]
  out[, nhpia := islandareas_value_any(islandareas, c("ISLANDAREAS_NHPIA", "P3_003N"))]
  out[, otheralone := islandareas_value_any(islandareas, c("ISLANDAREAS_OTHERALONE", "P3_027N"))]
  out[, multi := islandareas_value_any(islandareas, c("ISLANDAREAS_MULTI", "P3_028N"))]
  out[, pctwa := islandareas_ratio(wa, pop)]
  out[, pctba := islandareas_ratio(ba, pop)]
  out[, pctaiana := islandareas_ratio(aiana, pop)]
  out[, pctaa := islandareas_ratio(aa, pop)]
  out[, pctnhpia := islandareas_ratio(nhpia, pop)]
  out[, pctotheralone := islandareas_ratio(otheralone, pop)]
  out[, pctmulti := islandareas_ratio(multi, pop)]

  two_plus_cols <- sprintf("PCT80_%03dN", seq(13, 157, by = 12))
  out[, povknownratio := islandareas_value_any(islandareas, c("PBG74_001N", "ISLANDAREAS_POVKNOWN", "PCT80_001N"))]
  out[, pov2plus := islandareas_value_any(islandareas, "PBG74_010N", default = islandareas_value_any(islandareas, "ISLANDAREAS_POV2PLUS", default = islandareas_sum(islandareas, two_plus_cols)))]
  out[, lowinc := povknownratio - pov2plus]
  out[, pctlowinc := islandareas_ratio(lowinc, povknownratio)]
  out[, poverty_household_universe := islandareas_value_any(islandareas, c("ISLANDAREAS_HH_POV_UNIVERSE", "PBG78_001N"))]
  out[, poor := islandareas_value_any(islandareas, c("ISLANDAREAS_HH_POOR", "PBG78_002N"))]
  out[, pctpoor := islandareas_ratio(poor, poverty_household_universe)]

  out[, age25up := islandareas_value_any(islandareas, c("ISLANDAREAS_AGE25UP", "PBG19_001N"))]
  out[, lths := islandareas_value_any(islandareas, "ISLANDAREAS_LTHS", default = islandareas_sum(islandareas, c("PBG19_003N", "PBG19_004N", "PBG19_010N", "PBG19_011N")))]
  out[, pctlths := islandareas_ratio(lths, age25up)]

  out[, lan_universe := islandareas_value_any(islandareas, c("ISLANDAREAS_LAN_UNIVERSE", "PCT26_001N"))]
  out[, lan_english := islandareas_value_any(islandareas, "ISLANDAREAS_LAN_ENGLISH", default = islandareas_sum(islandareas, c("PCT26_003N", "PCT26_020N", "PCT26_037N")))]
  out[, lan_nonenglish := lan_universe - lan_english]
  out[, lingiso := islandareas_value_any(islandareas, "ISLANDAREAS_LINGISO", default = islandareas_sum(islandareas, c(
    "PCT26_006N", "PCT26_009N", "PCT26_012N", "PCT26_015N", "PCT26_018N",
    "PCT26_023N", "PCT26_026N", "PCT26_029N", "PCT26_032N", "PCT26_035N",
    "PCT26_040N", "PCT26_043N", "PCT26_046N", "PCT26_049N", "PCT26_052N"
  )))]
  out[, pctlingiso := islandareas_ratio(lingiso, lan_universe)]
  out[, pctlan_english := islandareas_ratio(lan_english, lan_universe)]
  out[, pctlan_nonenglish := islandareas_ratio(lan_nonenglish, lan_universe)]

  out[, builtunits := islandareas_value_any(islandareas, c("ISLANDAREAS_BUILTUNITS", "HBG18_001N"))]
  out[, built1950to1959 := islandareas_value(islandareas, "HBG18_009N")]
  out[, built1940to1949 := islandareas_value(islandareas, "HBG18_010N")]
  out[, builtpre1940 := islandareas_value(islandareas, "HBG18_011N")]
  out[, pre1960 := islandareas_value_any(islandareas, "ISLANDAREAS_PRE1960", default = built1950to1959 + built1940to1949 + builtpre1940)]
  out[, pctpre1960 := islandareas_ratio(pre1960, builtunits)]

  out[, unemployedbase := islandareas_value_any(islandareas, c("ISLANDAREAS_UNEMPLOYEDBASE", "PBG32_001N"))]
  out[, laborforce_universe := islandareas_value_any(islandareas, "ISLANDAREAS_LABORFORCE", default = islandareas_sum(islandareas, c("PBG32_005N", "PBG32_012N")))]
  out[, unemployed := islandareas_value_any(islandareas, "ISLANDAREAS_UNEMPLOYED", default = islandareas_sum(islandareas, c("PBG32_007N", "PBG32_014N")))]
  out[, pctunemployed := ifelse(laborforce_universe == 0, NA_real_, as.numeric(unemployed) / laborforce_universe)]

  out[, occupiedunits := islandareas_value_any(islandareas, c("ISLANDAREAS_OCCUPIEDUNITS", "H4_001N"))]
  out[, ownedunits := islandareas_value_any(islandareas, "ISLANDAREAS_OWNEDUNITS", default = islandareas_sum(islandareas, c("H4_002N", "H4_003N")))]
  out[, pctownedunits := islandareas_ratio(ownedunits, occupiedunits)]

  out[, broadband_universe := islandareas_value_any(islandareas, c("ISLANDAREAS_BROADBAND_UNIVERSE", "HBG42_001N"))]
  out[, nobroadband := broadband_universe - islandareas_value_any(islandareas, c("ISLANDAREAS_BROADBAND_WITH", "HBG42_004N"))]
  out[, pctnobroadband := islandareas_ratio(nobroadband, broadband_universe)]

  out[, healthinsurance_universe := islandareas_value_any(islandareas, c("ISLANDAREAS_HEALTH_UNIVERSE", "PBG29_001N"))]
  out[, nohealthinsurance := islandareas_value_any(islandareas, "ISLANDAREAS_NOHEALTH", default = islandareas_sum(islandareas, c("PBG29_004N", "PBG29_007N", "PBG29_010N")))]
  out[, pctnohealthinsurance := islandareas_ratio(nohealthinsurance, healthinsurance_universe)]

  out[, percapincome := islandareas_value_any(islandareas, c("ISLANDAREAS_PERCAPINCOME", "PBG68_001N"))]
  out[percapincome < 0, percapincome := NA_real_]

  out[, disab_universe := islandareas_value_any(islandareas, c("ISLANDAREAS_DISAB_UNIVERSE", "PBG26_001N"))]
  out[, disability := islandareas_value_any(islandareas, "ISLANDAREAS_DISABILITY", default = islandareas_sum(islandareas, c(
    "PBG26_004N", "PBG26_007N", "PBG26_010N", "PBG26_013N", "PBG26_016N", "PBG26_019N",
    "PBG26_023N", "PBG26_026N", "PBG26_029N", "PBG26_032N", "PBG26_035N", "PBG26_038N"
  )))]
  out[, pctdisability := islandareas_ratio(disability, disab_universe)]

  out[, ST := islandareas_value(islandareas, "ST", default = NA_character_)]
  out[, statename := islandareas_statename(ST)]
  out[, REGION := islandareas_region(ST)]
  out[, countyname := NA_character_]

  data.table::setorder(out, bgfips)
  out
}

islandareas_raw_component <- function(islandareas_raw, component = "blockgroup") {
  if (is.null(islandareas_raw)) {
    return(NULL)
  }
  if (!is.null(islandareas_raw[[component]])) {
    return(islandareas_raw[[component]])
  }
  if (all(vapply(islandareas_raw, is.data.frame, logical(1)))) {
    return(islandareas_raw)
  }
  stop("islandareas_raw must be a bg_islandareas_raw object or a named list of Island Areas Census table data.frames")
}

merge_islandareas_raw_tables <- function(islandareas_tables) {
  if (is.null(islandareas_tables) || length(islandareas_tables) == 0) {
    stop("islandareas_tables must contain at least one table")
  }
  if (!all(vapply(islandareas_tables, is.data.frame, logical(1)))) {
    stop("islandareas_tables must be a named list of data.frames")
  }

  prepared <- lapply(islandareas_tables, function(x) {
    x <- data.table::as.data.table(data.table::copy(x))
    if (!"fips" %in% names(x)) {
      stop("Island Areas Census raw table is missing fips")
    }
    x
  })

  out <- prepared[[1]]
  if (length(prepared) > 1) {
    for (i in 2:length(prepared)) {
      x <- prepared[[i]]
      drop_shared <- setdiff(intersect(names(out), names(x)), "fips")
      if (length(drop_shared) > 0) {
        x[, (drop_shared) := NULL]
      }
      out <- merge(out, x, by = "fips", all = TRUE, sort = FALSE)
    }
  }
  out
}

islandareas_value <- function(x, col, default = 0) {
  if (col %in% names(x)) {
    return(x[[col]])
  }
  if (length(default) == NROW(x)) {
    return(default)
  }
  rep(default, NROW(x))
}

islandareas_value_any <- function(x, cols, default = 0) {
  out <- rep(NA, NROW(x))
  for (col in cols) {
    if (col %in% names(x)) {
      values <- x[[col]]
      replace <- is.na(out) & !is.na(values)
      out[replace] <- values[replace]
    }
  }
  if (!all(is.na(out))) {
    if (any(is.na(out))) {
      fallback <- if (length(default) == NROW(x)) default else rep(default, NROW(x))
      out[is.na(out)] <- fallback[is.na(out)]
    }
    return(out)
  }
  if (length(default) == NROW(x)) {
    return(default)
  }
  rep(default, NROW(x))
}

islandareas_sum <- function(x, cols) {
  cols <- intersect(cols, names(x))
  if (length(cols) == 0) {
    return(rep(0, NROW(x)))
  }
  values <- as.data.frame(x[, cols, with = FALSE])
  out <- rowSums(values, na.rm = TRUE)
  out[rowSums(!is.na(values)) == 0] <- NA_real_
  out
}

islandareas_ratio <- function(num, den) {
  ifelse(den == 0, 0, as.numeric(num) / den)
}

islandareas_statename <- function(ST) {
  x <- data.table::data.table(
    ST = c("AS", "GU", "MP", "VI"),
    statename = c("American Samoa", "Guam", "Northern Mariana Islands", "U.S. Virgin Islands")
  )
  x$statename[match(ST, x$ST)]
}

islandareas_region <- function(ST) {
  x <- c(AS = 9, GU = 9, MP = 9, VI = 2)
  as.integer(x[ST])
}

merge_bg_acsdata_islandareas_data <- function(bg_acsdata, bg_islandareasdata) {
  bg_acsdata <- data.table::as.data.table(data.table::copy(bg_acsdata))
  bg_islandareasdata <- data.table::as.data.table(data.table::copy(bg_islandareasdata))

  if (!"bgfips" %in% names(bg_acsdata)) {
    stop("bg_acsdata must have a bgfips column")
  }
  if (!"bgfips" %in% names(bg_islandareasdata)) {
    stop("bg_islandareasdata must have a bgfips column")
  }
  duplicated_bgfips <- intersect(bg_acsdata$bgfips, bg_islandareasdata$bgfips)
  if (length(duplicated_bgfips) > 0) {
    stop("bg_islandareasdata overlaps existing bg_acsdata bgfips values: ", paste(head(duplicated_bgfips), collapse = ", "))
  }

  out <- data.table::rbindlist(list(bg_acsdata, bg_islandareasdata), fill = TRUE)
  data.table::setorder(out, bgfips)
  out
}

###################################################### #
