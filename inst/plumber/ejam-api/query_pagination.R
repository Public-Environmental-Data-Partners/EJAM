QUERY_DEFAULT_LIMIT <- 100L
QUERY_MAX_LIMIT <- 500L

query_positive_whole_number <- function(x, name, max_value = NULL) {
  x <- suppressWarnings(as.numeric(x))
  if (
    length(x) != 1 ||
    is.na(x) ||
    !is.finite(x) ||
    x < 1 ||
    x != floor(x) ||
    x > .Machine$integer.max ||
    (!is.null(max_value) && x > max_value)
  ) {
    if (!is.null(max_value)) {
      stop(
        sprintf("%s must be a positive whole number no larger than %d.", name, max_value),
        call. = FALSE
      )
    }
    stop(sprintf("%s must be a positive whole number.", name), call. = FALSE)
  }
  as.integer(x)
}

paginate_query_results <- function(
  results,
  page = 1,
  limit = QUERY_DEFAULT_LIMIT,
  max_limit = QUERY_MAX_LIMIT
) {
  page <- query_positive_whole_number(page, "page")
  limit <- query_positive_whole_number(limit, "limit", max_value = max_limit)

  total_rows <- nrow(results)
  total_pages <- if (total_rows == 0L) 0L else ceiling(total_rows / limit)
  start_idx <- ((page - 1L) * limit) + 1L
  end_idx <- min(page * limit, total_rows)

  if (start_idx > total_rows) {
    paginated_results <- results[0, , drop = FALSE]
  } else {
    paginated_results <- results[start_idx:end_idx, , drop = FALSE]
  }

  list(
    results = paginated_results,
    pagination = list(
      page = page,
      limit = limit,
      total_rows = as.integer(total_rows),
      total_pages = as.integer(total_pages),
      returned_rows = as.integer(nrow(paginated_results)),
      has_next_page = page < total_pages,
      has_previous_page = total_pages > 0L && page > 1L
    )
  )
}

query_endpoint_response <- function(
  attribute,
  value,
  page,
  limit,
  res,
  pctile_fun = pctile_x_is_hit_by_score,
  blockgroupstats_data = blockgroupstats,
  error_handler = function(message) list(error = message)
) {
  value <- suppressWarnings(as.numeric(value))
  if (length(value) != 1 || is.na(value) || value < 0 || value > 1) {
    res$status <- 400
    return(error_handler("value must be a numeric cutoff from 0 to 1."))
  }

  these <- pctile_fun(attribute, cutoff = value)
  results <- blockgroupstats_data[these, , drop = FALSE]

  tryCatch(
    paginate_query_results(results, page = page, limit = limit),
    error = function(e) {
      res$status <- 400
      error_handler(e$message)
    }
  )
}
