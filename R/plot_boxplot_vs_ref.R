#' Plot indicator values at analyzed sites against a reference area
#'
#' @description
#' Visualize one indicator from `ejamit()$results_bysite` against the same
#' indicator in a reference dataset such as `blockgroupstats`.
#'
#' @name plot_vs_us
#' @aliases plot_boxplot_vs_ref
#'
#' @seealso
#'   See [plot_boxplot_pctiles()] for percentile indicators compared in one plot.
#'   See [ejam2boxplot_ratios()] and [ejam2barplot()] for ratio indicators.
#'
#' @details
#' `bysite` is expected to be `ejamit()$results_bysite` or a full `ejamit()`
#' output list containing `results_bysite`. The table must contain `pop`,
#' `ejam_uniq_id`, and the indicator column named by `varname`.
#'
#' `refdata` must contain `pop` and the same indicator column. When `refdata`
#' is omitted, all rows from `blockgroupstats` with non-missing population and
#' indicator values are used.
#'
#' Percentage columns in EJAM site output and `blockgroupstats` historically use
#' different scales for some variables. With `fix_pctcols = TRUE`, those columns
#' are rescaled to percent units before plotting.
#'
#' @param bysite Table of results from `ejamit()$results_bysite`, or a full
#'   `ejamit()` output list with a `results_bysite` element.
#' @param varname Single column name to plot, such as `"pctlowinc"`.
#' @param type Plot type. One of `"ggplot"`, `"box"`, or `"plotly"`.
#' @param refarealabel Label used for the reference-area rows.
#' @param siteslabel Label used for the analyzed-site rows.
#' @param siteidlabel Optional vector of labels, one per analyzed site, used
#'   only when `type = "box"`. Defaults to `ejam_uniq_id`.
#' @param refdata Reference-area data with columns `pop` and `varname`. Defaults
#'   to `blockgroupstats`.
#' @param nsample Maximum number of reference rows to draw as points in sampled
#'   plot layers. If `refdata` has fewer rows, all reference rows are used.
#' @param fix_pctcols Whether to rescale known percent-as-fraction columns to
#'   percent units before plotting.
#' @param colorfills Two colors: first for the reference area, second for
#'   analyzed sites.
#' @param box.cex.ref Point size for sampled reference rows when `type = "box"`.
#' @param box.cex.here Point size for analyzed-site rows when `type = "box"`.
#' @param box.pch.ref Point symbol for sampled reference rows when `type = "box"`.
#' @param box.pch.here Point symbol for analyzed-site rows when `type = "box"`.
#' @param ... Additional arguments passed to [boxplot()] when `type = "box"`.
#'
#' @return
#' For `type = "ggplot"`, a [ggplot2::ggplot()] object. For `type = "plotly"`,
#' a plotly htmlwidget. For `type = "box"`, draws a base R plot and invisibly
#' returns a list containing the boxplot result, plotted data, mean values, and
#' explanatory plot notes, including the per-location mean labels shown under
#' the x-axis categories.
#'
#' @examples
#' \donttest{
#' out <- testoutput_ejamit_1000pts_1miles
#' plot_vs_us(out$results_bysite, type = "ggplot")
#' plot_vs_us(out$results_bysite, varname = "pctlingiso", type = "box", ylim = c(0, 20))
#'
#' td <- testoutput_ejamit_1000pts_1miles$results_bysite
#' plot_vs_us(
#'   td[td$ST %in% "DE", ],
#'   "pcthisp",
#'   refdata = blockgroupstats[ST %in% "DE", .(pop, pcthisp)],
#'   refarealabel = "Delaware Blockgroups"
#' )
#' }
#'
#' @export
plot_boxplot_vs_ref <- function(bysite = NULL,
                                varname = "pctlowinc",
                                type = "ggplot",
                                refarealabel = "All Blockgroups Nationwide",
                                siteslabel = "At Sites Analyzed",
                                siteidlabel = NULL,
                                refdata = NULL,
                                nsample = 5000,
                                fix_pctcols = TRUE,
                                colorfills = c("lightblue", "yellow"),
                                box.cex.ref = 0.6,
                                box.cex.here = 2.2,
                                box.pch.ref = 20,
                                box.pch.here = 2,
                                ...) {
  plot_vs_us(
    bysite = bysite,
    varname = varname,
    type = type,
    refarealabel = refarealabel,
    siteslabel = siteslabel,
    siteidlabel = siteidlabel,
    refdata = refdata,
    nsample = nsample,
    fix_pctcols = fix_pctcols,
    colorfills = colorfills,
    box.cex.ref = box.cex.ref,
    box.cex.here = box.cex.here,
    box.pch.ref = box.pch.ref,
    box.pch.here = box.pch.here,
    ...
  )
}

#' @rdname plot_vs_us
#' @export
plot_vs_us <- function(bysite = NULL,
                       varname = "pctlowinc",
                       type = "ggplot",
                       refarealabel = "All Blockgroups Nationwide",
                       siteslabel = "At Sites Analyzed",
                       siteidlabel = NULL,
                       refdata = NULL,
                       nsample = 5000,
                       fix_pctcols = TRUE,
                       colorfills = c("lightblue", "yellow"),
                       box.cex.ref = 0.6,
                       box.cex.here = 2.2,
                       box.pch.ref = 20,
                       box.pch.here = 2,
                       ...) {
  type <- plot_vs_us_check_type(type)
  plot_vs_us_check_scalar_character(varname, "varname")
  plot_vs_us_check_scalar_character(refarealabel, "refarealabel")
  plot_vs_us_check_scalar_character(siteslabel, "siteslabel")
  nsample <- plot_vs_us_check_nsample(nsample)
  plot_vs_us_check_colorfills(colorfills)

  sites <- plot_vs_us_prepare_sites(
    bysite = bysite,
    varname = varname,
    siteslabel = siteslabel
  )
  ref <- plot_vs_us_prepare_refdata(
    refdata = refdata,
    varname = varname,
    refarealabel = refarealabel,
    fix_pctcols = fix_pctcols
  )
  notes <- plot_vs_us_plot_notes(n_sites = nrow(sites), type = type)

  sample_n <- min(nsample, nrow(ref))
  sample_i <- if (sample_n > 0) sample.int(nrow(ref), sample_n) else integer()

  both_sample <- data.table::rbindlist(
    list(ref[sample_i], sites),
    use.names = TRUE
  )
  both <- data.table::rbindlist(
    list(ref, sites),
    use.names = TRUE
  )

  data.table::setnames(both, varname, "literalvarname")
  data.table::setnames(both_sample, varname, "literalvarname")

  bothmeansinfo <- both[, .(
    mean = stats::weighted.mean(literalvarname, w = pop, na.rm = TRUE)
  ), by = "Locations"]
  data.table::setorder(bothmeansinfo, Locations)
  bothmeans <- bothmeansinfo$mean

  varlabel <- fixcolnames(varname, "r", "shortlabel")
  title_refarealabel <- plot_vs_us_title_ref_label(refarealabel)
  maintitle <- paste0(
    "Comparison of ",
    varlabel,
    ": ",
    siteslabel,
    " versus ",
    title_refarealabel
  )

  if (type == "box") {
    return(invisible(plot_vs_us_base_boxplot(
      both = both,
      both_sample = both_sample,
      bothmeans = bothmeans,
      bothmeansinfo = bothmeansinfo,
      varlabel = varlabel,
      maintitle = maintitle,
      siteslabel = siteslabel,
      siteidlabel = siteidlabel,
      notes = notes,
      colorfills = colorfills,
      box.cex.ref = box.cex.ref,
      box.cex.here = box.cex.here,
      box.pch.ref = box.pch.ref,
      box.pch.here = box.pch.here,
      ...
    )))
  }

  if (type == "plotly") {
    return(plot_vs_us_plotly(
      both_sample = both_sample,
      maintitle = maintitle,
      notes = notes
    ))
  }

  plot_vs_us_ggplot(
    both = both,
    both_sample = both_sample,
    varlabel = varlabel,
    maintitle = maintitle,
    notes = notes,
    bothmeansinfo = bothmeansinfo,
    colorfills = colorfills
  )
}

plot_vs_us_prepare_sites <- function(bysite, varname, siteslabel) {
  if (is.null(bysite)) {
    if (interactive()) {
      bysite <- ejamit()$results_bysite
    } else {
      stop("bysite is required unless running interactively.", call. = FALSE)
    }
  }

  if ("results_bysite" %in% names(bysite)) {
    bysite <- bysite$results_bysite
  }

  bysite <- data.table::as.data.table(data.table::copy(bysite))
  plot_vs_us_check_columns(bysite, c("pop", "ejam_uniq_id", varname), "bysite")
  plot_vs_us_check_numeric_columns(bysite, c("pop", varname), "bysite")

  bysite <- fix_pctcols_x100(bysite, cnames = names_pct_as_fraction_ejamit)
  bysite <- data.table::as.data.table(bysite)
  plot_vs_us_check_numeric_columns(bysite, c("pop", varname), "bysite")
  sites <- bysite[, c("pop", varname, "ejam_uniq_id"), with = FALSE]
  sites[, Locations := siteslabel]
  sites <- sites[!is.na(pop) & !is.na(get(varname))]

  if (nrow(sites) == 0) {
    stop("bysite has no rows with non-missing pop and ", varname, ".", call. = FALSE)
  }

  sites
}

plot_vs_us_prepare_refdata <- function(refdata,
                                       varname,
                                       refarealabel,
                                       fix_pctcols) {
  if (is.null(refdata)) {
    plot_vs_us_check_columns(blockgroupstats, c("pop", varname), "blockgroupstats")
    refdata <- data.table::as.data.table(data.table::copy(blockgroupstats))
    refdata <- refdata[!is.na(pop) & !is.na(get(varname)), c("pop", varname), with = FALSE]
    if (!fix_pctcols) {
      warning(
        "fix_pctcols must be TRUE when using default blockgroupstats refdata; rescaling known percent columns anyway.",
        call. = FALSE
      )
    }
    refdata <- fix_pctcols_x100(refdata, cnames = names_pct_as_fraction_blockgroupstats)
  } else {
    refdata <- data.table::as.data.table(data.table::copy(refdata))
    plot_vs_us_check_columns(refdata, c("pop", varname), "refdata")
    refdata <- refdata[!is.na(pop) & !is.na(get(varname)), c("pop", varname), with = FALSE]
    plot_vs_us_check_numeric_columns(refdata, c("pop", varname), "refdata")
    if (fix_pctcols) {
      refdata <- fix_pctcols_x100(refdata, cnames = names_pct_as_fraction_blockgroupstats)
    }
  }

  refdata <- data.table::as.data.table(refdata)
  plot_vs_us_check_numeric_columns(refdata, c("pop", varname), "refdata")
  refdata[, ejam_uniq_id := NA_integer_]
  refdata[, Locations := refarealabel]

  if (nrow(refdata) == 0) {
    stop("refdata has no rows with non-missing pop and ", varname, ".", call. = FALSE)
  }

  refdata
}

plot_vs_us_base_boxplot <- function(both,
                                    both_sample,
                                    bothmeans,
                                    bothmeansinfo,
                                    varlabel,
                                    maintitle,
                                    siteslabel,
                                    siteidlabel,
                                    notes,
                                    colorfills,
                                    box.cex.ref,
                                    box.cex.here,
                                    box.pch.ref,
                                    box.pch.here,
                                    ...) {
  ylabel <- varlabel

  here <- siteslabel == both_sample$Locations
  axis_mean_labels <- plot_vs_us_axis_mean_labels(bothmeansinfo)
  old_mar <- graphics::par("mar")
  graphics::par(mar = old_mar + c(4.5, 0, 1, 0))
  on.exit(graphics::par(mar = old_mar), add = TRUE)

  boxresult <- do.call(
    graphics::boxplot,
    c(
      list(
        formula = literalvarname ~ Locations,
        data = both,
        ylab = ylabel,
        col = colorfills,
        xlab = "",
        main = plot_vs_us_wrap_note(maintitle, width = 70),
        xaxt = "n"
      ),
      list(...)
    )
  )
  axis_mean_labels <- axis_mean_labels[match(boxresult$names, axis_mean_labels$location), ]
  graphics::axis(1, at = seq_along(boxresult$names), labels = boxresult$names, tick = FALSE)
  graphics::mtext(
    axis_mean_labels$label,
    side = 1,
    at = seq_along(boxresult$names),
    line = 1.7,
    cex = 0.6
  )
  graphics::mtext("Locations", side = 1, line = 3.1)
  plot_vs_us_base_note(notes$plot_note, line = 5.2, cex = 0.55)

  points(
    jitter(1 + (siteslabel == both_sample$Locations[!here])),
    both_sample$literalvarname[!here],
    pch = box.pch.ref,
    col = "darkgray",
    cex = box.cex.ref
  )

  xv <- jitter(1 + (siteslabel == both_sample$Locations[here]))
  yv <- both_sample$literalvarname[here]
  points(
    xv,
    yv,
    pch = box.pch.here,
    col = "black",
    cex = box.cex.here
  )

  if (is.null(siteidlabel)) {
    siteidlabel <- both_sample$ejam_uniq_id[here]
  } else if (length(siteidlabel) != length(xv)) {
    warning("siteidlabel must be the same length as the list of analyzed sites; using ejam_uniq_id.", call. = FALSE)
    siteidlabel <- both_sample$ejam_uniq_id[here]
  }
  text(x = xv, y = yv, labels = siteidlabel, pos = 4, cex = 0.6)

  points(1:2, bothmeans, col = "black", pch = 22, bg = "white", cex = 3)
  abline(h = bothmeans[1], col = colorfills[1])
  abline(h = bothmeans[2], col = colorfills[2])

  list(
    boxplot = boxresult,
    data = both,
    sampled_data = both_sample,
    means = bothmeansinfo,
    notes = notes,
    axis_mean_labels = axis_mean_labels
  )
}

plot_vs_us_plotly <- function(both_sample, maintitle, notes) {
  plotdata <- data.table::copy(both_sample)
  data.table::setnames(plotdata, "literalvarname", "Indicator")
  d <- plotly::highlight_key(plotdata)

  violin <- plotly::plot_ly(d, x = ~Locations, y = ~Indicator, color = I("blue")) %>%
    plotly::add_trace(type = "violin", name = " ")
  plotly::subplot(violin, shareY = TRUE, titleX = TRUE, titleY = TRUE) %>%
    plotly::layout(
      barmode = "overlay",
      title = list(text = maintitle),
      showlegend = FALSE,
      margin = list(b = 95),
      annotations = list(list(
        text = notes$plot_note,
        x = 0,
        y = -0.18,
        xref = "paper",
        yref = "paper",
        xanchor = "left",
        yanchor = "top",
        showarrow = FALSE,
        align = "left",
        font = list(size = 10)
      ))
    ) %>%
    plotly::highlight("plotly_selected")
}

plot_vs_us_ggplot <- function(both, both_sample, varlabel, maintitle, notes, bothmeansinfo, colorfills) {
  axis_mean_labels <- plot_vs_us_axis_mean_labels(bothmeansinfo)
  ggplot2::ggplot(
    both,
    ggplot2::aes(x = Locations, y = literalvarname, color = Locations, fill = Locations)
  ) +
    ggplot2::scale_color_manual(values = c("gray35", "black")) +
    ggplot2::scale_fill_manual(values = colorfills) +
    ggplot2::geom_violin(
      alpha = 0.15,
      trim = FALSE,
      na.rm = TRUE
    ) +
    ggplot2::geom_boxplot(
      width = 0.15,
      alpha = 0.3,
      outlier.shape = NA,
      na.rm = TRUE
    ) +
    ggplot2::geom_jitter(
      data = both_sample,
      size = 1,
      width = 0.05,
      alpha = 0.7,
      na.rm = TRUE
    ) +
    plot_vs_us_ggplot_mean_line_layer(axis_mean_labels) +
    plot_vs_us_ggplot_mean_point_layer(axis_mean_labels) +
    plot_vs_us_ggplot_axis_mean_layer(axis_mean_labels) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      legend.position = "none",
      plot.caption = ggplot2::element_text(size = 7, hjust = 0, lineheight = 0.95),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 22)),
      plot.margin = ggplot2::margin(t = 5.5, r = 5.5, b = 48, l = 5.5)
    ) +
    ggplot2::xlab("Locations") +
    ggplot2::ylab(varlabel) +
    ggplot2::ggtitle(maintitle) +
    ggplot2::labs(caption = plot_vs_us_wrap_note(notes$plot_note, width = 145))
}

plot_vs_us_axis_mean_labels <- function(bothmeansinfo) {
  out <- data.table::as.data.table(data.table::copy(bothmeansinfo))
  out[, "label" := paste0("Avg. resident: ", format(round(mean, 1), nsmall = 1, trim = TRUE))]
  out[, "location" := out[["Locations"]]]
  out[, c("location", "Locations", "mean", "label"), with = FALSE]
}

plot_vs_us_title_ref_label <- function(refarealabel) {
  if (identical(refarealabel, "All Blockgroups Nationwide")) {
    return("Nationwide")
  }
  refarealabel
}

plot_vs_us_ggplot_mean_line_layer <- function(axis_mean_labels) {
  layer_data <- data.table::as.data.table(data.table::copy(axis_mean_labels[, c("Locations", "mean", "label"), with = FALSE]))
  attr(layer_data, "plot_vs_us_mean_line") <- TRUE
  ggplot2::geom_errorbar(
    data = layer_data,
    ggplot2::aes(x = Locations, ymin = mean, ymax = mean),
    inherit.aes = FALSE,
    width = 0.45,
    linewidth = 0.5,
    color = "black"
  )
}

plot_vs_us_ggplot_mean_point_layer <- function(axis_mean_labels) {
  layer_data <- data.table::as.data.table(data.table::copy(axis_mean_labels[, c("Locations", "mean", "label"), with = FALSE]))
  attr(layer_data, "plot_vs_us_mean_point") <- TRUE
  ggplot2::geom_point(
    data = layer_data,
    ggplot2::aes(x = Locations, y = mean),
    inherit.aes = FALSE,
    shape = 22,
    size = 3,
    stroke = 0.6,
    color = "black",
    fill = "white"
  )
}

plot_vs_us_ggplot_axis_mean_layer <- function(axis_mean_labels) {
  layer_data <- data.table::as.data.table(data.table::copy(axis_mean_labels[, c("Locations", "mean", "label"), with = FALSE]))
  attr(layer_data, "plot_vs_us_axis_mean_label") <- TRUE
  ggplot2::geom_text(
    data = layer_data,
    ggplot2::aes(x = Locations, y = -Inf),
    inherit.aes = FALSE,
    label = layer_data[["label"]],
    size = 2.5,
    vjust = 4.2
  )
}

plot_vs_us_plot_notes <- function(n_sites, type) {
  n_sites_label <- format(n_sites, big.mark = ",", scientific = FALSE)
  distribution_prefix <- switch(
    type,
    box = "The boxplots and medians summarize rows",
    ggplot = "The boxplots, violins, and medians summarize rows",
    plotly = "The violin summarizes displayed rows"
  )
  distribution <- paste0(
    distribution_prefix,
    " (reference blockgroups and ",
    n_sites_label,
    " analyzed sites), not population-weighted quantiles."
  )
  mean <- "The white squares/lines show population-weighted average resident, not average site."
  reference <- "Reference rows are sampled for point display."
  plot_note <- if (type == "plotly") {
    paste(distribution, reference)
  } else {
    paste(distribution, mean, reference)
  }
  list(
    distribution = distribution,
    mean = mean,
    reference = reference,
    plot_note = plot_note
  )
}

plot_vs_us_base_note <- function(note, line, cex, width = 120) {
  note_lines <- strwrap(note, width = width)
  for (i in seq_along(note_lines)) {
    graphics::mtext(
      note_lines[[i]],
      side = 1,
      line = line + ((i - 1) * 0.85),
      adj = 0,
      cex = cex
    )
  }
}

plot_vs_us_wrap_note <- function(x, width = 85) {
  paste(strwrap(x, width = width), collapse = "\n")
}

plot_vs_us_check_scalar_character <- function(x, name) {
  if (!is.character(x) || length(x) != 1 || is.na(x) || !nzchar(x)) {
    stop(name, " must be a single non-missing character value.", call. = FALSE)
  }
}

plot_vs_us_check_type <- function(type) {
  allowed <- c("ggplot", "box", "plotly")
  if (!is.character(type) || length(type) != 1 || is.na(type) || !(type %in% allowed)) {
    stop(
      "type must be one of: ",
      paste(allowed, collapse = ", "),
      call. = FALSE
    )
  }
  type
}

plot_vs_us_check_columns <- function(x, required, data_name) {
  missing_cols <- setdiff(required, names(x))
  if (length(missing_cols) > 0) {
    stop(
      data_name,
      " must include column(s): ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
}

plot_vs_us_check_numeric_columns <- function(x, required, data_name) {
  non_numeric <- required[!vapply(x[, required, with = FALSE], is.numeric, logical(1))]
  if (length(non_numeric) > 0) {
    stop(
      data_name,
      " column(s) must be numeric: ",
      paste(non_numeric, collapse = ", "),
      call. = FALSE
    )
  }
}

plot_vs_us_check_nsample <- function(nsample) {
  if (!is.numeric(nsample) || length(nsample) != 1 || is.na(nsample) || nsample < 0) {
    stop("nsample must be a single non-negative number.", call. = FALSE)
  }
  floor(nsample)
}

plot_vs_us_check_colorfills <- function(colorfills) {
  if (!is.character(colorfills) || length(colorfills) != 2 || any(is.na(colorfills))) {
    stop("colorfills must be a character vector of exactly two colors.", call. = FALSE)
  }
}
