# Extracted from test-mydata_validate.R:21

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "EJAM", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
onecounty <- function() {
  x <- data.frame(bgfips = blockgroupstats$bgfips[substr(blockgroupstats$bgfips, 1, 5) == "10001"])
  x$myscore <- seq_len(nrow(x))
  x$mycount <- 10
  x$myuniverse <- 100
  x
}
meta3 <- function() {
  mydata_metadata(
    rname = c("myscore", "mycount", "pct_mine"),
    formula = c("", "", "pct_mine = ifelse(myuniverse == 0, 0, mycount / myuniverse)"),
    calculation_type = c("wtdmean", "sum of counts", "formula")
  )
}

# test -------------------------------------------------------------------------
x <- data.frame(bgfips = blockgroupstats$bgfips, myscore = blockgroupstats$pctlowinc)
suppressWarnings({
    out <- mydata_validate(x, mydata_metadata("myscore"), quiet = TRUE)
  })
