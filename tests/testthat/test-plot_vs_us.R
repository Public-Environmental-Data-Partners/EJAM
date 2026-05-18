plot_vs_us_bysite_testdata <- function() {
  data.table::data.table(
    pop = c(100, 200, 300),
    pctlowinc = c(10, 20, 30),
    ejam_uniq_id = 1:3
  )
}

plot_vs_us_refdata_testdata <- function(n = 4) {
  data.table::data.table(
    pop = seq_len(n) * 100,
    pctlowinc = seq_len(n) * 5
  )
}

test_that("plot_vs_us returns a ggplot without draft warnings for small refdata", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(3)

  expect_no_warning({
    p <- plot_vs_us(bysite, refdata = refdata, nsample = 5000)
  })

  expect_true("ggplot" %in% class(p))
  expect_setequal(as.character(unique(p$data$Locations)), c("All Blockgroups Nationwide", "At Sites Analyzed"))
  expect_null(p$labels$subtitle)
  expect_match(p$labels$caption, "The boxplots")
  expect_match(p$labels$caption, "not population-weighted\\s+quantiles")
  expect_match(p$labels$caption, "analyzed sites")
  expect_match(p$labels$caption, "The white\\s+squares/lines show population")
  expect_match(p$labels$caption, "Reference rows are\\s+sampled")
  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("plot_vs_us title does not duplicate the location preposition", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(3)

  p <- plot_vs_us(bysite, refdata = refdata, nsample = 2)

  expect_false(grepl("at At", p$labels$title, fixed = TRUE))
  expect_match(p$labels$title, "At Sites Analyzed versus Nationwide", fixed = TRUE)
  expect_false(grepl("versus All Blockgroups Nationwide", p$labels$title, fixed = TRUE))
})

test_that("plot_vs_us title preserves custom reference area labels", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(3)

  p <- plot_vs_us(
    bysite,
    refdata = refdata,
    refarealabel = "Delaware Blockgroups",
    nsample = 2
  )

  expect_match(p$labels$title, "At Sites Analyzed versus Delaware Blockgroups", fixed = TRUE)
  expect_setequal(as.character(unique(p$data$Locations)), c("Delaware Blockgroups", "At Sites Analyzed"))
})

test_that("plot_vs_us ggplot uses full data for distributions and sampled data for points", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)

  p <- plot_vs_us(bysite, refdata = refdata, nsample = 2)
  jitter_layers <- vapply(
    p$layers,
    function(layer) inherits(layer$geom, "GeomPoint") && !isTRUE(attr(layer$data, "plot_vs_us_mean_point")),
    logical(1)
  )

  expect_equal(sum(p$data$Locations == "All Blockgroups Nationwide"), 4L)
  expect_equal(sum(p$layers[[which(jitter_layers)]]$data$Locations == "All Blockgroups Nationwide"), 2L)
})

test_that("plot_boxplot_vs_ref wrapper returns the same ggplot interface", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)

  expect_no_warning({
    p <- plot_boxplot_vs_ref(bysite, refdata = refdata, nsample = 2)
  })

  expect_true("ggplot" %in% class(p))
})

test_that("plot_vs_us accepts full ejamit-style output lists", {
  refdata <- plot_vs_us_refdata_testdata(4)

  expect_no_warning({
    p <- plot_vs_us(
      list(results_bysite = plot_vs_us_bysite_testdata()),
      refdata = refdata,
      nsample = 2
    )
  })

  expect_true("ggplot" %in% class(p))
})

test_that("plot_vs_us box type draws a base plot and returns plot data invisibly", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)
  grDevices::pdf(file = tempfile(fileext = ".pdf"))
  on.exit(grDevices::dev.off(), add = TRUE)

  expect_no_warning({
    out <- plot_vs_us(bysite, refdata = refdata, type = "box", nsample = 2)
  })

  expect_type(out, "list")
  expect_named(out, c(
    "boxplot",
    "data",
    "sampled_data",
    "means",
    "notes",
    "axis_mean_labels",
    "location_fill_colors",
    "box_fill_colors",
    "mean_line_colors"
  ))
  expect_match(out$notes$distribution, "not population-weighted quantiles")
  expect_match(out$notes$mean, "The white squares/lines show population")
  expect_match(out$notes$plot_note, "The boxplots")
  expect_match(out$notes$plot_note, "The white squares/lines show population")
  expect_true("axis_mean_labels" %in% names(out))
  expect_setequal(out$axis_mean_labels$location, c("All Blockgroups Nationwide", "At Sites Analyzed"))
  expect_true(all(grepl("^Avg\\. resident: ", out$axis_mean_labels$label)))
})

test_that("plot_vs_us aligns colors to location labels when custom reference labels sort after sites", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)
  colorfills <- c("lightblue", "yellow")
  grDevices::pdf(file = tempfile(fileext = ".pdf"))
  on.exit(grDevices::dev.off(), add = TRUE)

  out <- plot_vs_us(
    bysite,
    refdata = refdata,
    refarealabel = "Delaware Blockgroups",
    type = "box",
    nsample = 2,
    colorfills = colorfills
  )

  expect_identical(
    out$location_fill_colors[c("Delaware Blockgroups", "At Sites Analyzed")],
    stats::setNames(colorfills, c("Delaware Blockgroups", "At Sites Analyzed"))
  )
  expect_identical(
    out$box_fill_colors,
    unname(out$location_fill_colors[out$boxplot$names])
  )
  expect_identical(
    out$mean_line_colors,
    out$location_fill_colors[names(out$mean_line_colors)]
  )

  p <- plot_vs_us(
    bysite,
    refdata = refdata,
    refarealabel = "Delaware Blockgroups",
    nsample = 2,
    colorfills = colorfills
  )
  fill_scale <- p$scales$get_scales("fill")

  expect_identical(
    fill_scale$palette(2)[c("Delaware Blockgroups", "At Sites Analyzed")],
    stats::setNames(colorfills, c("Delaware Blockgroups", "At Sites Analyzed"))
  )
})

test_that("plot_vs_us ggplot includes per-location mean labels under the violins", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)

  p <- plot_vs_us(bysite, refdata = refdata, nsample = 2)
  mean_layers <- vapply(
    p$layers,
    function(layer) isTRUE(attr(layer$data, "plot_vs_us_axis_mean_label")),
    logical(1)
  )

  expect_equal(sum(mean_layers), 1L)
  expect_named(p$layers[[which(mean_layers)]]$data, c("Locations", "mean", "label"))
  expect_setequal(
    p$layers[[which(mean_layers)]]$data$Locations,
    c("All Blockgroups Nationwide", "At Sites Analyzed")
  )
  expect_true(all(grepl("^Avg\\. resident: ", p$layers[[which(mean_layers)]]$data$label)))
})

test_that("plot_vs_us ggplot shows population-weighted means as lines and white squares", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)

  p <- plot_vs_us(bysite, refdata = refdata, nsample = 2)
  mean_line_layers <- vapply(
    p$layers,
    function(layer) isTRUE(attr(layer$data, "plot_vs_us_mean_line")),
    logical(1)
  )
  mean_point_layers <- vapply(
    p$layers,
    function(layer) isTRUE(attr(layer$data, "plot_vs_us_mean_point")),
    logical(1)
  )

  expect_equal(sum(mean_line_layers), 1L)
  expect_equal(sum(mean_point_layers), 1L)
  expect_named(p$layers[[which(mean_point_layers)]]$data, c("Locations", "mean", "label"))
  expect_match(p$labels$caption, "population-weighted average")
  expect_match(p$labels$caption, "average resident")
  expect_match(p$labels$caption, "not average site")
  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("plot_vs_us plotly type returns a plotly object", {
  skip_if_not_installed("plotly")
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)

  expect_no_warning({
    p <- plot_vs_us(bysite, refdata = refdata, type = "plotly", nsample = 2)
  })

  expect_s3_class(p, "plotly")
  plotly_title <- p$x$layoutAttrs[[1]]$title$text
  expect_false(grepl("The violin", plotly_title))
  expect_false(grepl("White squares", plotly_title))
  plotly_note <- p$x$layoutAttrs[[1]]$annotations[[1]]$text
  expect_match(plotly_note, "The violin")
  expect_false(grepl("White squares", plotly_note))
})

test_that("plot_vs_us rejects unsupported plot types before plotting", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(6000)

  expect_error(
    plot_vs_us(bysite, refdata = refdata, type = "histogram"),
    "type"
  )
})

test_that("plot_vs_us validates required input columns clearly", {
  refdata <- plot_vs_us_refdata_testdata(4)

  expect_error(
    plot_vs_us(data.table::data.table(pop = 1:2), refdata = refdata),
    "bysite"
  )

  expect_error(
    plot_vs_us(plot_vs_us_bysite_testdata(), refdata = data.table::data.table(pctlowinc = 1:2)),
    "refdata"
  )
})

test_that("plot_vs_us validates numeric plotting columns clearly", {
  refdata <- plot_vs_us_refdata_testdata(4)

  expect_error(
    plot_vs_us(
      data.table::data.table(pop = c("100", "200"), pctlowinc = c(10, 20), ejam_uniq_id = 1:2),
      refdata = refdata
    ),
    "bysite"
  )

  expect_error(
    plot_vs_us(
      plot_vs_us_bysite_testdata(),
      refdata = data.table::data.table(pop = c(100, 200), pctlowinc = c("low", "high"))
    ),
    "refdata"
  )
})

test_that("plot_vs_us does not mutate caller supplied reference data", {
  bysite <- plot_vs_us_bysite_testdata()
  refdata <- plot_vs_us_refdata_testdata(4)
  original_names <- names(refdata)

  expect_no_warning({
    plot_vs_us(bysite, refdata = refdata, nsample = 2)
  })

  expect_identical(names(refdata), original_names)
})
