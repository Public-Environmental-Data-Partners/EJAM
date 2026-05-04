
# utility to find / delete obsolete .Rd files in man/ (ie have no corresponding roxygen-tagged function/data) ####

# Usage:
#  # Dry run (default) - just reports what would be deleted:
#  pkg_clean_stale_rd()
#
#  # Actually delete (with backup)
#  pkg_clean_stale_rd(dry_run = FALSE, backup = TRUE)
#
# Notes:
#  - Run this from the package root (where DESCRIPTION and R/ and man/ live).
#  - Always run in dry-run mode first, or use version control to review changes.
#  - The script uses heuristics and is intentionally conservative to avoid removing
#    manually-maintained .Rd files unintentionally.
#  - Drafted by github copilot, then heavily modified

pkg_clean_stale_rd <- function(r_dir = "R",
                           verbose = FALSE,
                           report_basics_even_if_verbose_F = TRUE,
                           man_dir = "man",
                           dry_run = TRUE,
                           backup = TRUE,
                           backup_dir = file.path(man_dir, "backup_before_delete"),
                           max_lines_after_block = 50) {

  if (!dir.exists(man_dir)) stop("man/ directory not found: ", man_dir)
  if (!dir.exists(r_dir)) stop("R/ directory not found: ", r_dir)
  ################################################################## #
  # get package name from DESCRIPTION (if present), else NA
  get_package_name <- function(desc_path = "DESCRIPTION") {
    if (!file.exists(desc_path)) return(NA_character_)
    desc_lines <- tryCatch(read.dcf(desc_path, all = TRUE), error = function(e) NULL)
    if (is.null(desc_lines)) return(NA_character_)
    pkg <- desc_lines[1L, "Package"]
    if (is.null(pkg) || is.na(pkg) || identical(pkg, "")) NA_character_ else pkg
  }
  pkg_name <- get_package_name()
  if (verbose) {
    if (!is.na(pkg_name)) message("Package name from DESCRIPTION: ", pkg_name, '\n')
    else message("DESCRIPTION not found or no Package field; package name unknown \n")
  }
  ################################################################## #
  ## do pkg_find_roxygen_topics() ####
  # and report on skipped @noRd topics
  roxy_topics <- pkg_find_roxygen_topics(r_dir, pkg_name = pkg_name,
                                     max_lines_after_block = max_lines_after_block,
                                     verbose = verbose, report_basics_even_if_verbose_F = report_basics_even_if_verbose_F)

  if (verbose || report_basics_even_if_verbose_F) {
    message("\nDiscovered ", length(roxy_topics), " roxygen topics (after skipping any with @noRd) \n")
    if (verbose) {
      if (length(roxy_topics) > 0) {
        message("  ", paste(head(sort(roxy_topics), 200), collapse = ", "),
                if (length(roxy_topics) > 200) ", ..." else "")
      }
    }
  }
  rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
  if (length(rd_files) == 0) {
    if (verbose) message("Found no .Rd files in ", man_dir)
    return(invisible(character()))
  }
  ################################################################## #
  ## do extract_rd_name()
  ############################################ #
  # Extract the \name{...} from an .Rd file; fallback to basename without .Rd
  extract_rd_name <- function(rd_path) {
    lines <- tryCatch(readLines(rd_path, warn = FALSE), error = function(e) character(0))
    if (length(lines) == 0) return(tools::file_path_sans_ext(basename(rd_path)))
    # try to find \name{...} allowing optional spaces
    idx <- grep("\\\\name\\s*\\{", lines)
    if (length(idx) > 0) {
      # examine a short context around the match
      mline <- lines[idx[1]]
      m <- regexec("\\\\name\\s*\\{([^}]*)\\}", mline)
      mr <- regmatches(mline, m)[[1]]
      if (length(mr) >= 2 && nzchar(mr[2])) return(mr[2])
      # try a small context join in case it's split (unlikely)
      context <- paste(lines[idx[1]:(min(length(lines), idx[1] + 3))], collapse = " ")
      m2 <- regexec("\\\\name\\s*\\{([^}]*)\\}", context)
      mr2 <- regmatches(context, m2)[[1]]
      if (length(mr2) >= 2 && nzchar(mr2[2])) return(mr2[2])
    }
    # fallback: use file basename without .Rd
    tools::file_path_sans_ext(basename(rd_path))
  }
  ############################################ #
  rd_names <- vapply(rd_files, extract_rd_name, FUN.VALUE = character(1))
  names(rd_files) <- rd_names

  # Determine which .Rd files are stale: those whose \name{} is not among roxy_topics.
  to_delete_idx <- which(!(rd_names %in% roxy_topics))
  to_delete_files <- rd_files[to_delete_idx]
  ################################################################## #
  if (length(to_delete_files) == 0) {
    if (verbose || report_basics_even_if_verbose_F) {
      message("Found zero stale .Rd files to delete, because all .Rd topics have corresponding roxygen docs\n")
    }
    return(invisible(character()))
  }

  if (verbose || report_basics_even_if_verbose_F) {
    message("\nThe following .Rd files do not correspond to any roxygen topic in ", r_dir, ":\n")
    for (f in to_delete_files) message("  ", f)
  }

  if (dry_run) {
    if (verbose || report_basics_even_if_verbose_F) {
      message("\nDry run: no files were deleted. Set dry_run = FALSE to actually remove them.\n")
    }
    return(invisible(to_delete_files))
  }

  # Make backup if requested
  if (backup) {
    if (!dir.exists(backup_dir)) dir.create(backup_dir, recursive = TRUE)
    copied <- file.copy(to_delete_files, file.path(backup_dir, basename(to_delete_files)), overwrite = TRUE)
    if (verbose) {
      message("Backed up ", sum(copied), " of ", length(to_delete_files), " files to ", backup_dir)
      if (!all(copied)) message("Some files failed to copy to backup. Check permissions.")
    }
  }

  # Attempt delete and report
  deleted <- file.remove(to_delete_files)
  if (verbose || report_basics_even_if_verbose_F) {
    n_deleted <- sum(deleted)
    message("\nDeleted ", n_deleted, " of ", length(to_delete_files), " file(s).")
    if (any(!deleted)) {
      message("\nFailed to delete:")
      for (i in which(!deleted)) message("  ", to_delete_files[i])
    }
  }

  invisible(to_delete_files[deleted])
}
################################################################## #
# ~ ---------------------------------- ####
################################################################## #

# utility to find roxygen topics in R/ code ####

# - collects @name, @rdname, @aliases
# - respects @noRd (skips such blocks)
# - considers @docType package (uses @name if present, else pkgname-package)
# - if no explicit tags, attempts to infer object names from subsequent code
# - looks for multiple assignments and setClass(...) forms

pkg_find_roxygen_topics <- function(r_dir = "R", pkg_name = NA_character_,
                                max_lines_after_block = 50, verbose = FALSE, report_basics_even_if_verbose_F = TRUE) {

  r_files <- list.files(r_dir, pattern = "\\.R$", full.names = TRUE, recursive = TRUE)
  topics <- character(0)
  skipped_n_nord = 0

  ################################################################## #
  # Parse roxygen tag values from a block of roxygen text (single string).
  # If split = TRUE, split whitespace-separated tokens (useful for @aliases).

  parse_roxy_tag_values <- function(block_text, tag, split = FALSE) {

    # match @tag followed by one or more spaces and then capture until end-of-line
    # allow multiple occurrences; value is trimmed
    pattern <- paste0("@", tag, "\\s+([^\\n]*)")
    m <- gregexpr(pattern, block_text, perl = TRUE)
    if (m[[1]][1] == -1) return(character(0))
    matches <- regmatches(block_text, m)[[1]]
    values <- vapply(matches, function(x) {
      # x is like "@tag value", remove leading "@tag"
      sub(paste0("^@", tag, "\\s+"), "", x)
    }, FUN.VALUE = character(1))
    values <- trimws(values)
    if (length(values) == 0) return(character(0))
    if (split) {
      # split each value on whitespace and return tokens
      tokens <- unlist(strsplit(values, "\\s+"))
      tokens[tokens != ""]
    } else {
      values
    }
  }
  ################################################################## #

  for (f in r_files) {
    #                    next file

    lines <- tryCatch(readLines(f, warn = FALSE), error = function(e) character(0))
    if (length(lines) == 0) next
    n <- length(lines)
    i <- 1L

    while (i <= n) {
      #                next roxygen block

      if (grepl("^\\s*#'", lines[i])) {
        start <- i
        while (i <= n && grepl("^\\s*#'", lines[i])) i <- i + 1L
        end <- i - 1L
        block_lines <- lines[start:end]
        block <- sub("^\\s*#'\\s?", "", block_lines) # get rid of the #' at start of each line
        block_text <- paste(block, collapse = "\n")

        # If the block contains @noRd, skip adding topics for this block.
        if (grepl("@noRd\\b", block_text, perl = TRUE)) {
          skipped_n_nord <- skipped_n_nord + 1
          if (verbose) {
            message("Skipping block with @noRd in ", f, " (lines ", start, "-", end, ") -- ", gsub("^([^ ]*) .*$", "\\1()", trimws(lines[end+1]) ) )
          }
          next
        }

        # 1) explicit tags: @name, @rdname

        name_vals <- unique(c(
          parse_roxy_tag_values(block_text, "name"),
          parse_roxy_tag_values(block_text, "rdname")
        ))

        # 2) function name
        #
        # from a function definition even if lacking those tags ! - but
        # NOTE this is also attempted in the code below called "block_topics" which seemed to miss some cases this finds?
        #
        # in case the @name tag was not used for a function (which is very common in this package)
        # find the name of the function that is defined in this block_text, if any,
        # such as finding "xyz" as the name of the function if the text of lines[end+1] contains "xyz <- function(" or "xyz = function("
        function_name <- NULL
        if (end + 1 <= n) {
          next_line <- lines[end + 1] # this next_line should have any function definition on it
          # unless there is one or more empty here or lines with only # and/or spaces, between the roxygen tags block and the function definition
          # while next_line contains only "#" and/or " ", or nchar(next_line) == 0, redefine next_line as lines[end + 2], etc.
          k2 <- end + 1L
          # while (k2 <= n && grepl("^\\s*(#\\s*)?$", lines[k2])) { # this is not quite right
          while(k2 <= n && (grepl("^[#| ]*#.*$",  lines[k2]) || grepl(" *", lines[k2]) || nchar(lines[k2]) == 0)) {
            k2 <- k2 + 1L
          }
          if (k2 <= n) {
            next_line <- lines[k2]
          }
          # now parse the (substantive) next_line for function definition
          m_func <- regexec("^\\s*([.A-Za-z][A-Za-z0-9._]*)\\s*(?:<-|=)\\s*function\\s*\\(", next_line)
          mr_func <- regmatches(next_line, m_func)[[1]]
          if (length(mr_func) >= 2 && nzchar(mr_func[2])) {
            function_name <- mr_func[2]
          }
        }
        if (!is.null(function_name)) {
          name_vals <- unique(c(name_vals, function_name))
        }

        # 3) aliases (can be multiple tokens)

        alias_vals <- parse_roxy_tag_values(block_text, "aliases", split = TRUE)
        if (!is.null(alias_vals)) {
          name_vals <- unique(c(name_vals, alias_vals))
        }

        # 4) docType: if package, prefer explicit @name or fall back to pkgname-package

        doc_types <- parse_roxy_tag_values(block_text, "docType")
        if (length(doc_types) > 0 && any(tolower(doc_types) == "package")) {
          if (length(name_vals) > 0) {
            # keep explicit name
          } else if (!is.na(pkg_name) && nzchar(pkg_name)) {
            # package Rd produced by roxygen usually has name "pkgname-package"
            name_vals <- c(name_vals, paste0(pkg_name, "-package"))
          } else {
            if (verbose) message("Found @docType package but package name unknown; consider adding @name to the block in ", f)
          }
        }


        block_topics <- unique(name_vals)

        # 5) if no explicit topics, attempt to infer from subsequent code lines
        ## but note this was already attempted above in # 2 for function definitions, which seemed to work better in some cases

        if (length(block_topics) == 0) {
          # look ahead up to max_lines_after_block lines to find a code object definition
          k <- end + 1L
          looked <- 0L
          inferred <- character(0)
          while (k <= n && looked < max_lines_after_block) {
            line <- lines[k]
            looked <- looked + 1L
            # skip comments and blank lines
            if (grepl("^\\s*(#|$)", line)) { k <- k + 1L; next }

            # 5a) setClass("Name", ...) -> topic "Name-class"

            m_class <- regexec("setClass\\s*\\(\\s*['\"]([^'\"]+)['\"]", line)
            mr_class <- regmatches(line, m_class)[[1]]
            if (length(mr_class) >= 2 && nzchar(mr_class[2])) {
              inferred <- c(inferred, paste0(mr_class[2], "-class"))
              break
            }

            # 5b) setGeneric("name", ...) or setMethod("name", ...) -> topic "name"

            m_generic <- regexec("set(Generic|Generic|Method)\\s*\\(\\s*['\"]([^'\"]+)['\"]", line, perl = TRUE)
            mr_generic <- regmatches(line, m_generic)[[1]]
            if (length(mr_generic) >= 3 && nzchar(mr_generic[3])) {
              inferred <- c(inferred, mr_generic[3])
              break
            }

            # 5c) Detect left-hand-side assignments. Capture comma-separated names.
            # This tries to handle: a <- function(...), a, b <- function(...), a <- b <- function(...)
            # Strategy: find everything before the first '=' or '<-' on the line,
            # then split by commas and strip possible trailing '<-' fragments.
            ###################### #
            ## Helper to split and trim comma-separated LHS names like "a, b" ?? but this never gets used !
            # split_lhs_names <- function(lhs) {
            #   parts <- unlist(strsplit(lhs, "\\s*,\\s*"))
            #   parts <- trimws(parts)
            #   parts[parts != ""]
            # }
            ###################### #
            if (grepl("(?:<-|=)", line)) {
              # split at the first <- or =
              split1 <- strsplit(line, "<-|=", perl = TRUE)[[1]]
              if (length(split1) >= 1) {
                lhs <- split1[1]
                # remove parentheses and c(...) patterns e.g. c(a, b) <- ...
                lhs_clean <- gsub("^\\s*c?\\s*\\(\\s*|\\s*\\)\\s*$", "", lhs)
                # If there were chained '<-' like "a <- b <- function", then lhs will be "a " and the rest contains " b <- function".
                # To handle chained, also parse tokens separated by '<-' in original line and take all identifiers found before the last RHS marker.
                # A conservative approach: extract all identifier-like tokens from lhs_clean.
                names_found <- gregexpr("([.A-Za-z][A-Za-z0-9._]*)", lhs_clean, perl = TRUE)
                tokens <- regmatches(lhs_clean, names_found)[[1]]
                if (length(tokens) > 0) {
                  inferred <- c(inferred, tokens)
                }
              }
              # if we found any inferred names from assignment, stop scanning further lines for this block
              if (length(inferred) > 0) break
            }

            # 5d) fallback: simple object creation like "obj <- structure(..." or "dataName <- read.csv(...)" or "x <- 1"

            m_obj <- regexec("^\\s*([.A-Za-z][A-Za-z0-9._]*)\\s*(?:<-|=)", line)
            mm_obj <- regmatches(line, m_obj)[[1]]
            if (length(mm_obj) >= 2 && nzchar(mm_obj[2])) {
              inferred <- c(inferred, mm_obj[2])
              break
            }

            # otherwise advance
            k <- k + 1L
          } # end lookahead

          if (length(inferred) > 0) block_topics <- unique(c(block_topics, inferred))
        } # end inference

        # Collect block topics
        if (length(block_topics) > 0) {
          topics <- c(topics, block_topics)
        }

      } else {
        i <- i + 1L
      }
    } # end while through file
  } # end for each file

  if (verbose || report_basics_even_if_verbose_F) {
    message("\nSkipped ", skipped_n_nord, " roxygen topics(s) with @noRd")
  }

  # normalize and return unique topics
  topics <- unique(trimws(topics))
  topics <- topics[topics != ""]
  sort(topics)
}
################################################################## #


# If this file is sourced, optionally run a quick dry-run message in interactive mode
if (identical(environment(), globalenv()) && interactive()) {
  message("Loaded pkg_clean_stale_rd(). Example:  pkg_clean_stale_rd(dry_run = TRUE)")
}

