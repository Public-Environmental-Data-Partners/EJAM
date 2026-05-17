# Compare subsets (types) of places that are all from one list

This function may change but works as currently designed e.g., may
change output formats of results_bytype vs results_overall

## Usage

``` r
ejamit_compare_types_of_places(
  sitepoints,
  typeofsite = NULL,
  shapefile = NULL,
  fips = NULL,
  silentinteractive = TRUE,
  ...
)
```

## Arguments

- sitepoints:

  see
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- typeofsite:

  vector of length same as NROW(sitepoints), where each unique value
  defines a group of sites

- shapefile:

  see
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- fips:

  see
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- silentinteractive:

  passed to
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- ...:

  see
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

## Value

similar to ejamit output but results_overall has one row per unique
typeofsite

## Examples

``` r
  out <- ejamit_compare_types_of_places(testpoints_10[1:4, ],
    typeofsite = c("A", "B", "B", "C"))
  cbind(Rows_or_length = sapply(out, NROW))

  ejam2barplot_sitegroups(out, names_these_ratio_to_avg[1], topn = 3)

  ejam2barplot_sitegroups(out, "sitecount_unique", topn=3, sortby = FALSE)

  ejam2barplot_sitegroups(out, "pop", topn = 3, sortby = FALSE)

  # use calculated variable not in original table
  df <- out$results_bytype
  df$share <- df$pop / sum(df$pop)
  df$pop_per_site <- df$pop / df$sitecount_unique

  plot_barplot_sites(df,
    "share", ylab = "Share of Total Population",
    topn = 3, names.arg = out$types , sortby = FALSE)

  plot_barplot_sites(df,
    "pop_per_site", ylab = "Pop. at Avg. Site in Group",
    topn = 3, main = "Nearby Residents per Site, by Site Type",
    names.arg = out$types , sortby = FALSE)

  # \donttest{

  # Analyze by EPA Region

  pts <- data.frame(testpoints_1000)

  # Get State and EPA Region of each point from lat/lon

   x <- state_from_latlon(lat = pts$lat, lon = pts$lon)
   pts <- data.frame(pts, x)

   out_byregion <- ejamit_compare_types_of_places(
     pts, typeofsite = pts$REGION)

   dvarname <- names_d[3]
   ejam2barplot_sitegroups(out_byregion, dvarname)
   abline(h = usastats_means(dvarname))

   ejam2barplot_sitegroups(out_byregion, "ratio.to.avg.pctmin",
      main = "By EPA Region", ylim = c(0, 2))
   abline(h = 1)

   # Analyze by State (slow! e.g., may take 2-3 minutes
   # for 1,000 sites state by state)

   out_bystate <- ejamit_compare_types_of_places(pts, typeofsite = pts$ST)

   ejam2barplot_sitegroups(out_bystate, "sitecount_unique",
     names.arg = out_bystate$types, topn = 52, cex.names = 0.5,
     main = "Sites by State")

  # }
```
