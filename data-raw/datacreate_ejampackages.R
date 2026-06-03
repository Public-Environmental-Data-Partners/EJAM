
## somewhat obsolete,
## was a list of possibly relevant packages,
## was used as default in some utilities for pkg maintenance, now

ejampackages <- names(
  grep("EJAM.*", installed.packages()[, 'Package'], value = TRUE, ignore.case = TRUE)
  )
ejampackages <- "EJAM"

## dont add  ACSdownload and census2020download, used during annual updates

cat(paste0(" full list of possibly relevant packages: \n
  c('", paste0(ejampackages, collapse = "', '"), "')\n"))
cat('\n')

ejampackages <- c("EJAM")

cat(paste0(" critical EJAM-related packages being saved as 'ejampackages' are these: \n
  ejampackages <- c('", paste0(ejampackages, collapse = "', '"), "')\n"))
cat('\n')

# ejampackages <- metadata_add(ejampackages)
# usethis::use_data(ejampackages, overwrite = TRUE)
EJAM:::metadata_add_and_use_this("ejampackages")
dataset_documenter("ejampackages",
                   "ejampackages (DATA) list of names of key EJAM-related R packages\n#' @keywords internal")
