
#' Utility to download / load datasets (other than typical datasets, which get lazy-loaded from the data folder)
#'
#' @details
#'   First checks memory, then the installed package's data folder. When the
#'   package is first loaded, Arrow files are downloaded from the package's data
#'   repository, normally called `ejamdata`, into the package's data directory.
#'
#'   Arrow files do not all follow the same release rule. Facility and most
#'   geography Arrow files are still treated as dynamic data and normally come
#'   from the latest applicable `ejamdata` release, tracked with the local
#'   `ejamdata_version.txt` marker. Annual EJSCREEN/EJAM data files such as
#'   `bgej.arrow` are package-coupled: they are pinned to the installed EJAM
#'   package version, so EJAM 2.5.0 looks for `bgej.arrow` in the `ejamdata`
#'   release tagged `v2.5.0` rather than in the latest data-repository release.
#'
#' @param varnames character vector of names of R objects to get from board,
#'   or set this to "all" to load all of them
#' @param envir if needed to specify environment other than default, e.g., globalenv() or parent.frame()
#' @param folder_local_source path of local folder to
#'   look in for locally saved copies
#' @param silent set to TRUE to suppress cat() msgs to console
#' @param return_data_table whether the [read_ipc_file()] should return a table in
#'   [data.table](https://r-datatable.com) format (T, the default), or arrow (F). Passed to [dataload_from_local()]
#' @param onAttach Indicates whether the function is being called from onAttach. IF so, it will download all arrow files if necessary
#' @param piggybacktag default is `"latest"` for dynamic Arrow data. Package-
#'   coupled annual datasets such as `bgej` override `"latest"` internally and
#'   use `paste0("v", packageVersion("EJAM"))` as their release tag.
#' @return
#'
#'   returns vector of names of objects now in memory in specified envir, either because
#'
#'   1) already in memory or
#'
#'   2) loaded from local disk or
#'
#'   3) successfully downloaded.
#'
#' @export
#'
dataload_dynamic <- function(
    varnames = .arrow_ds_names[1:3],
    envir = globalenv(),
    folder_local_source = NULL, # './data/', # or "~/../Downloads"
    silent = FALSE,
    return_data_table = TRUE,
    onAttach = FALSE,
    piggybacktag = "latest") {

  message(paste0("Loading specified arrow datasets: ", paste(varnames, collapse = ", ")))

  ####################################################### #
  # make sure varnames are specified correctly
  if (!all(is.character(varnames))) {
    ok = FALSE
    varnames = deparse(substitute(varnames))
    if (all(sapply(varnames, exists))) {
      if (interactive()) {
        ok <- askYesNo(paste0("looks like you provided unquoted object names ... do you mean '", varnames[1],"' etc.?"))
        if (is.na(ok)) {ok <- FALSE} # clicked cancel
        warning("varnames must be a character vector of quoted names of objects like c('x', 'y') \n")
        if (!ok) {return(NULL)}
      }}
    if (!ok) {
      stop("varnames must be a character vector of quoted names of objects like c('x', 'y') ")
    }}

  if ('all' %in% tolower(varnames)) {
    varnames <- .arrow_ds_names
  }

  ####################################################### #
  # try downloading datasets ####
  # download all if loading EJAM, otherwise only those requested
  # the download function will first check if they're already downloaded.

  if (onAttach) message("Finding or downloading all arrow files: ", paste0(if (onAttach) .arrow_ds_names else varnames, collapse = ", "))

  download_latest_arrow_data(
    varnames = if (onAttach) .arrow_ds_names else varnames,
    envir = envir,
    piggybacktag = piggybacktag
  )

  ####################################################### #
  # make output in console easier to read:
  if (length(varnames) > 1) {
    widest <- max(nchar(varnames))
  } else {
    widest <- max(10, nchar(varnames))
  }
  spacing <- sapply(1:length(varnames), function(x) {
    paste0(rep(" ", widest - nchar(varnames[x])), collapse = '')
  })

  ####################################################### #
  # first change varnames if requesting arrow version, rather than DT
  if (!return_data_table) varnames <- paste0(varnames, "_arrow")

  ####################################################### #
  # check memory
  message(paste0("looking for ", paste(varnames, collapse = ', '), " in memory..."))
  files_loaded <- sapply(varnames, function(v) exists(v, envir = envir))
  if (all(files_loaded)) {
    if (return_data_table && "bgej" %in% varnames) {
      if (isTRUE(dataload_dynamic_validate_bgej(envir = envir, silent = silent))) {
        return(NULL)
      }
      files_loaded <- sapply(varnames, function(v) exists(v, envir = envir))
    } else {
      return(NULL)
    }
  }

  ####################################################### #
  # get files from installed package's data folder (where they were downloaded)
  files_not_loaded <- varnames[!files_loaded]
  dataload_from_local(
    files_not_loaded,
    folder_local_source = folder_local_source,
    envir = envir,
    return_data_table = return_data_table,
    silent = silent
  )

  if (return_data_table && "bgej" %in% varnames) {
    if (!isTRUE(dataload_dynamic_validate_bgej(envir = envir, silent = silent))) {
      downloaded <- download_latest_arrow_data(
        varnames = "bgej",
        envir = envir,
        piggybacktag = piggybacktag,
        force = TRUE
      )
      if (isTRUE(downloaded)) {
        dataload_from_local(
          "bgej",
          folder_local_source = folder_local_source,
          envir = envir,
          return_data_table = return_data_table,
          silent = silent
        )
        dataload_dynamic_validate_bgej(envir = envir, silent = silent)
      }
    }
  }

  if (!silent) {cat("\n")}

  return(varnames)
}

dataload_dynamic_validate_bgej <- function(envir = globalenv(), silent = FALSE) {
  if (!exists("bgej", envir = envir, inherits = FALSE)) {
    return(invisible(TRUE))
  }

  bgej_loaded <- get("bgej", envir = envir, inherits = FALSE)
  if (!all(c("bgfips", "pop") %in% names(bgej_loaded))) {
    return(invisible(TRUE))
  }

  blockgroupstats_ref <- NULL
  if ("package:EJAM" %in% search() &&
      exists("blockgroupstats", envir = as.environment("package:EJAM"), inherits = FALSE)) {
    blockgroupstats_ref <- get("blockgroupstats", envir = as.environment("package:EJAM"), inherits = FALSE)
  } else {
    tmp <- new.env(parent = emptyenv())
    loaded <- try(utils::data("blockgroupstats", package = "EJAM", envir = tmp), silent = TRUE)
    if (!inherits(loaded, "try-error") &&
        exists("blockgroupstats", envir = tmp, inherits = FALSE)) {
      blockgroupstats_ref <- get("blockgroupstats", envir = tmp, inherits = FALSE)
    }
  }

  if (is.null(blockgroupstats_ref) || !"bgfips" %in% names(blockgroupstats_ref)) {
    return(invisible(TRUE))
  }

  bgej_bgfips <- as.character(bgej_loaded$bgfips)
  blockgroupstats_bgfips <- as.character(blockgroupstats_ref$bgfips)
  bgfips_set_equal <- setequal(bgej_bgfips, blockgroupstats_bgfips)
  pop_mismatch_n <- 0L

  if (bgfips_set_equal && "pop" %in% names(blockgroupstats_ref)) {
    bgej_pop <- data.frame(
      bgfips = bgej_bgfips,
      pop_bgej = bgej_loaded$pop,
      stringsAsFactors = FALSE
    )
    bgstats_pop <- data.frame(
      bgfips = blockgroupstats_bgfips,
      pop_blockgroupstats = blockgroupstats_ref$pop,
      stringsAsFactors = FALSE
    )
    pop_compare <- merge(bgej_pop, bgstats_pop, by = "bgfips", all = FALSE, sort = FALSE)
    both_na <- is.na(pop_compare$pop_bgej) & is.na(pop_compare$pop_blockgroupstats)
    pop_mismatch <- !both_na &
      !(is.na(pop_compare$pop_bgej) == is.na(pop_compare$pop_blockgroupstats) &
          abs(pop_compare$pop_bgej - pop_compare$pop_blockgroupstats) < 1e-8)
    pop_mismatch_n <- sum(pop_mismatch, na.rm = TRUE)
  }

  if (bgfips_set_equal && pop_mismatch_n == 0L) {
    return(invisible(TRUE))
  }

  rm(list = "bgej", envir = envir)
  mismatch_reason <- if (!bgfips_set_equal) {
    paste0(
      "the loaded bgej has ", length(unique(bgej_bgfips)),
      " unique bgfips values, while package blockgroupstats has ",
      length(unique(blockgroupstats_bgfips)), "."
    )
  } else {
    paste0("the loaded bgej has pop values that differ from package blockgroupstats for ",
           pop_mismatch_n, " blockgroups.")
  }
  warning(
    paste(
      "The loaded bgej table does not match this package's blockgroupstats;",
      mismatch_reason,
      "The bgej object was removed from memory so stale EJ indexes are not used.",
      "This can happen after installing from source before the matching ejamdata release has been published."
    ),
    call. = FALSE
  )
  if (!silent) {
    message("Removed incompatible bgej from memory.")
  }
  invisible(FALSE)
}
