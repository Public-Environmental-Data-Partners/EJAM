
cat("
Check for newer version of NAICS definitions, and
maybe update FRS datasets, and
check which version of NAICS codes are recorded in EPA FRS data.
See data-raw/datacreate_0_UPDATE_ALL_DATASETS.R and
see data-raw/datacreate_NAICS.R
    \n")

library(magrittr) # or maybe can now use |>  that is built into R

## Count distinct facilities and expand each NAICS code to its 2- through
## 6-digit ancestors once. Repeatedly calling frs_from_naics() here scans
## the full FRS table for each of roughly 2,200 NAICS codes.
frs_naics_sites <- unique(frs_by_naics[, .(REGISTRY_ID, NAICS)])
naics_counts_nosub <- frs_naics_sites[, .(count_no_subs = .N), by = NAICS]

naics_hierarchy <- data.table::as.data.table(naicstable)[,
  c("code", paste0("n", 2:6)), with = FALSE
]
unknown_naics <- setdiff(unique(frs_naics_sites$NAICS), naics_hierarchy$code)
if (length(unknown_naics)) {
  warning("FRS contains ", length(unknown_naics),
          " NAICS codes absent from naicstable; review the code universe")
}
frs_naics_hierarchy <- merge(
  frs_naics_sites, naics_hierarchy,
  by.x = "NAICS", by.y = "code", all = FALSE
)
frs_naics_ancestors <- data.table::melt(
  frs_naics_hierarchy,
  id.vars = "REGISTRY_ID", measure.vars = paste0("n", 2:6),
  value.name = "NAICS"
)
frs_naics_ancestors[, NAICS := as.numeric(NAICS)]
naics_counts_w_subs <- unique(
  frs_naics_ancestors[, .(REGISTRY_ID, NAICS)]
)[, .(count_w_subs = .N), by = NAICS]

## join and add counts to labels
naics_counts <- tibble::enframe(NAICS,value = 'NAICS') %>%
  dplyr::left_join(naics_counts_w_subs, by = "NAICS") %>%
  dplyr::left_join(naics_counts_nosub, by = "NAICS") %>%
  dplyr::mutate(label_w_subs = ifelse(!is.na(.data$count_w_subs) & .data$count_w_subs > 0,
                                      paste0(.data$name, ' (',
                                             prettyNum(.data$count_w_subs, big.mark = ','),' sites)'
                                      ),
                                      .data$name
  ),
  label_no_subs = ifelse(!is.na(.data$count_no_subs) & .data$count_no_subs > 0,
                         paste0(name, ' (',
                                prettyNum(.data$count_no_subs, big.mark = ','),' sites)'),
                         name)
  )

## save to EJAM package dataset

# naics_counts <- metadata_add(naics_counts)
metadata_add_and_use_this(objectname = "naics_counts")
# attr(naics_counts, "date_saved_in_package") <- as.character(Sys.Date())
# usethis::use_data(naics_counts, overwrite = TRUE)

dataset_documenter("naics_counts",
                   title = "naics_counts (DATA) data.frame with regulated facility counts for each industry code",
                   description = "data.frame with regulated facility counts for each NAICS code, with and without subcodes, and labels that include the site counts",
                   details = "This has all available NAICS codes, the count of sites for each of them in the frs data, both on their own and including all subcodes. Used by EJAM shiny app for dropdown menu.")
