# Rebuild the program-ID upload examples from the FRS Arrow table just created
# by datacreate_frs_.R. Use one deterministic sample for all file sizes.
if (!exists("frs_by_programid")) {
  stop("Load the newly built frs_by_programid.arrow before rebuilding test data")
}

program_rows <- frs_by_programid[
  !is.na(REGISTRY_ID) & !is.na(lat) & !is.na(lon) &
    !is.na(program) & nzchar(program) &
    !is.na(pgm_sys_id) & nzchar(pgm_sys_id)
]
program_rows <- unique(program_rows, by = "PGM_SYS_ACRNMS")
numeric_rows <- which(grepl("^[1-9][0-9]+$", program_rows$pgm_sys_id) &
                      nchar(program_rows$pgm_sys_id) <= 15L)
if (!length(numeric_rows) || nrow(program_rows) < 10000L) {
  stop("The current FRS program table lacks enough valid sample IDs")
}

snapshot_date <- as.Date(attr(frs_by_programid, "download_date"))
if (length(snapshot_date) != 1L || is.na(snapshot_date)) {
  stop("The new program lookup needs a valid download_date attribute")
}
set.seed(as.numeric(snapshot_date))
first_row <- sample(numeric_rows, 1L)
sample_rows <- c(first_row, sample(setdiff(seq_len(nrow(program_rows)), first_row), 9999L))
sampled <- program_rows[sample_rows]
folder <- "inst/testdata/programid"

for (n in c(10L, 100L, 1000L, 10000L)) {
  out <- as.data.frame(sampled[seq_len(n), .(program, pgm_sys_id)])
  write.csv(out, file.path(folder, paste0("program_test_data_", n, ".csv")), row.names = FALSE)
}

# The 10-row workbook intentionally demonstrates one numeric Excel ID cell
# alongside text IDs, as documented in its note column.
ten <- as.data.frame(sampled[1:10, .(program, pgm_sys_id)])
ten$note <- c("stored as a number", rep("stored as text", 9L))
wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "Sheet1")
openxlsx::writeData(wb, "Sheet1", ten)
openxlsx::writeData(wb, "Sheet1", as.numeric(ten$pgm_sys_id[1]),
                    startCol = 2, startRow = 2, colNames = FALSE)
openxlsx::saveWorkbook(wb, file.path(folder, "program_test_data_10.xlsx"), overwrite = TRUE)

known <- as.data.frame(sampled[1:1000,
  .(knownlat = lat, knownlon = lon, knownregid = REGISTRY_ID,
    program, pgm_sys_id)])
openxlsx::write.xlsx(known, file.path(folder, "test_pgm_sys_id_1000.xlsx"),
                    overwrite = TRUE)

for (n in c(10L, 100L, 1000L, 10000L)) {
  actual <- read.csv(file.path(folder, paste0("program_test_data_", n, ".csv")),
                     stringsAsFactors = FALSE)
  if (any(!paste(actual$program, actual$pgm_sys_id, sep = ":") %in%
          frs_by_programid$PGM_SYS_ACRNMS)) {
    stop("A saved program-ID sample is absent from the new FRS table")
  }
}
