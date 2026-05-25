
# UPDATES/MODIFIES SIC AFTER frs_by_sic is updated, using sictable

# Depends on SIC & sictable & frs_by_sic all being created beforehand!

### AND SEE  EJAM/data-raw/datacreate_sictable.R

library(magrittr)
# library(tibble) # for deframe() or is that different than the tibble::deframe() ??

names(SIC) <- sictable$num_name

sic_counts_nosub <- frs_by_sic[, .N, by = 'SIC']

sic_counts_names <- tibble::enframe(SIC) %>%
  dplyr::left_join(sic_counts_nosub, by = c('value' = 'SIC')) %>%
  dplyr::mutate(name = ifelse(!is.na(N),
                              paste0(name, ' (', N, ' sites)'), name)) %>%
  dplyr::select(-N) %>%
  tibble::deframe()

names(SIC) <- names(sic_counts_names)

EJAM:::metadata_add_and_use_this("SIC")
