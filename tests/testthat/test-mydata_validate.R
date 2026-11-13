# mydata_validate() checks a user's blockgroup table against its metadata

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

test_that("a clean table covering the whole US is accepted, with full coverage", {
  x <- data.frame(bgfips = blockgroupstats$bgfips, myscore = blockgroupstats$pctlowinc)
  suppressWarnings({
    out <- mydata_validate(x, mydata_metadata("myscore"), quiet = TRUE)
  })
  expect_true(out$ok)
  expect_true(all(c("bgfips", "bgid", "myscore") %in% names(out$mydata)))
  expect_false(anyNA(out$mydata$bgid))
  # blockgroupstats also has rows for the Island Areas, which are not in the list of blockgroups used for analysis
  expect_equal(nrow(out$mydata) + nrow(out$unmatched), nrow(x))
  us <- out$coverage[out$coverage$zone == "USA" & out$coverage$indicator == "myscore", ]
  expect_gt(us$coverage, 0.99)
  expect_true(us$comparisons_possible)
  expect_equal(out$builtin_columns, "pop")
})

test_that("a one-county table is accepted and reports coverage by indicator", {
  x <- onecounty()
  before <- x
  out <- mydata_validate(x, meta3(), quiet = TRUE)
  expect_identical(x, before) # the table provided is not changed
  expect_true(out$ok)
  expect_equal(nrow(out$mydata), nrow(x))
  expect_setequal(unique(out$coverage$indicator), c("myscore", "mycount", "pct_mine"))
  expect_setequal(unique(out$coverage$zone), c("USA", "DE"))
  expect_false(any(out$coverage$comparisons_possible))
  de <- out$coverage[out$coverage$zone == "DE" & out$coverage$indicator == "myscore", ]
  expect_gt(de$coverage, 0.1)
  expect_lt(de$coverage, 0.5)
  expect_true(any(grepl("split in proportion to population", out$problems$message)))
  expect_message(mydata_validate(x, meta3()), "ready to analyze")
})

test_that("coverage counts only blockgroups with usable values for that indicator", {
  x <- onecounty()
  x$mycount[1:20] <- NA
  out <- mydata_validate(x, meta3(), quiet = TRUE)
  n <- function(ind) {out$coverage$n_blockgroups[out$coverage$zone == "USA" & out$coverage$indicator == ind]}
  expect_equal(n("myscore"), nrow(x))
  expect_equal(n("mycount"), nrow(x) - 20)
  expect_equal(n("pct_mine"), nrow(x) - 20) # the formula needs mycount
})

test_that("a whole state gets state comparisons but not US comparisons", {
  x <- data.frame(bgfips = blockgroupstats$bgfips[blockgroupstats$ST == "DE"])
  x$myscore <- 1
  out <- mydata_validate(x, mydata_metadata("myscore"), quiet = TRUE)
  cov <- out$coverage
  expect_true(cov$comparisons_possible[cov$zone == "DE"])
  expect_false(cov$comparisons_possible[cov$zone == "USA"])
})

test_that("FIPS problems are reported: repeats, invalid codes, lost leading zeroes, tracts", {
  x <- onecounty()
  expect_error(mydata_validate(rbind(x, x[1, ]), meta3(), quiet = TRUE), "repeated")

  bad <- rbind(x, data.frame(bgfips = c("999999999999", "abc"), myscore = 1, mycount = 1, myuniverse = 1))
  expect_warning(out <- mydata_validate(bad, meta3(), quiet = TRUE), "left out")
  expect_equal(nrow(out$mydata), nrow(x))
  expect_equal(out$unmatched$fips, c("999999999999", "abc"))

  al <- data.frame(bgfips = blockgroupstats$bgfips[substr(blockgroupstats$bgfips, 1, 5) == "01001"], myscore = 1)
  asnumber <- data.frame(bgfips = as.numeric(al$bgfips), myscore = 1)
  out2 <- mydata_validate(asnumber, mydata_metadata("myscore"), quiet = TRUE)
  expect_equal(out2$mydata$bgfips, al$bgfips)
  expect_true(any(grepl("not stored as text", out2$problems$message)))

  mixed <- rbind(x[1:5, c("bgfips", "myscore")], data.frame(bgfips = substr(x$bgfips[6], 1, 11), myscore = 1))
  expect_warning(out3 <- mydata_validate(mixed, mydata_metadata("myscore"), quiet = TRUE), "not a blockgroup FIPS code")
  expect_equal(nrow(out3$mydata), 5)

  tr <- data.frame(fips = unique(substr(x$bgfips, 1, 11)), myscore = 1)
  expect_error(mydata_validate(tr, mydata_metadata("myscore"), quiet = TRUE), "tracts")
  expect_error(mydata_validate(data.frame(id = 1:3, myscore = 1), quiet = TRUE), "No column of FIPS codes")
})

test_that("name, column and value problems each say what to fix", {
  x <- onecounty()
  expect_error(mydata_validate(x, data.frame(rname = "pctlowinc"), quiet = TRUE), "already used")

  expect_error(mydata_validate(x[, c("bgfips", "myscore", "mycount")], meta3(), quiet = TRUE), "needs column myuniverse")
  expect_error(mydata_validate(x[, c("bgfips", "mycount", "myuniverse")], meta3(), quiet = TRUE), "myscore needs a column with that name")
  expect_error(mydata_validate(x, mydata_metadata("myscore", denominator = "nosuchweight"), quiet = TRUE), "nosuchweight")

  y <- x
  y$myscore <- as.character(y$myscore)
  y$myscore[3] <- "n/a"
  expect_error(mydata_validate(y, meta3(), quiet = TRUE), "not numbers")
  y$myscore[3] <- "7"
  out <- mydata_validate(y, meta3(), quiet = TRUE)
  expect_true(is.numeric(out$mydata$myscore))

  z <- x
  z$mycount[2] <- -5
  expect_error(mydata_validate(z, meta3(), quiet = TRUE), "cannot be negative")
  z$mycount[2] <- Inf
  expect_warning(out <- mydata_validate(z, meta3(), quiet = TRUE), "infinite")
  expect_true(is.na(out$mydata$mycount[2]))

  # all problems are listed at once, and can be returned without stopping
  w <- rbind(x, x[1, ])
  w$mycount[2] <- -5
  out <- mydata_validate(w, meta3(), stop_on_error = FALSE, quiet = TRUE)
  expect_false(out$ok)
  expect_equal(sum(out$problems$level == "error"), 2)
})

test_that("with no metadata, numeric columns are treated as indicators", {
  x <- onecounty()
  out <- mydata_validate(x[, c("bgfips", "myscore")], quiet = TRUE)
  expect_true(out$ok)
  expect_equal(out$mydata_map_headernames$rname[out$mydata_map_headernames$vartype == "raw"], "myscore")
  mine <- data.frame(rname = "myscore", longname = "My score")
  out2 <- mydata_validate(x, mine, quiet = TRUE)
  expect_equal(out2$mydata_map_headernames$longname[1], "My score")
  expect_equal(out2$mydata_map_headernames$calculation_type[1], "wtdmean")
})
