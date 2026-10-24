# EJSCREEN Technical Documentation reference inventory

Source-file locations in EJAM to review before changing references to the
EJSCREEN Technical Documentation (v2.3). This inventory includes source
references to both the PDF and the archived EPA technical-information page,
since some source files point to the page rather than directly to the PDF.
Line numbers are a guide and may shift as files change.

Generated HTML and generated `man/*.Rd` files are intentionally excluded.

## PDF links and shared URL helper

| Source file | Lines | Reference / context |
| --- | ---: | --- |
| `R/URL_FUNCTIONS_part2.R` | 2048, 2056 | Defines `url_ejscreentechdoc()`, the shared helper returning the PDF from the EJAM GitHub `main` branch. Review this first if changing the canonical PDF destination. |
| `vignettes/ejscreen.Rmd` | 95–102, 209–214 | Describes the v2.3 manual as saved for EJAM; links through the helper and to a September 2025 Wayback PDF snapshot. Line 102 is a commented example using the `development` branch. |
| `vignettes/overview-environmental-indicators-ejscreen.Rmd` | 45, 52 | Links to the PDF on the EJAM `development` branch and to a January 2025 Wayback copy. |
| `vignettes/env-indicators/ejscreen-indicators-overview-particulate-matter-25-pm25.Rmd` | 50–51 | Links through the helper and separately to the archived technical-information page and PDF. |
| `vignettes/env-indicators/ejscreen-indicators-overview-ozone.Rmd` | 37 | Links through the shared helper for technical details on calculations and source data. |
| `data-raw/EJSCREEN_archived_pages/technical-information-and-data-downloads.Rmd` | 8, 13 | Links to the helper and the Wayback PDF; describes its coverage as data and methods used to create EJScreen indicators and indexes. |
| `data-raw/EJSCREEN_archived_pages/ejscreen-indicators-overview-particulate-matter-25-pm25.Rmd` | 37–38 | Archived-page source; links through the helper and directly to archived EPA page and PDF. |
| `data-raw/EJSCREEN_archived_pages/ejscreen-indicators-overview-ozone.Rmd` | 25 | Archived-page source; links through the helper for calculation and source-data details. |
| `data-raw/EJSCREEN_archived_pages/ejscreen-indicators-overview-diesel-particulate-matter.Rmd` | 30–31 | Archived-page source; links through the helper and to the locally archived technical-information page. |
| `R/data_formulas_ejscreen_acs.R` | 10 | Roxygen source documentation links to the January 2025 Wayback PDF as the location where EPA-documented formulas were archived. |
| `data-raw/archived_datacreate_formulas_ejscreen_acs_notes.R` | 593 | Legacy formula notes link to the same Wayback PDF and describe it as the source of EPA formulas. |

## Archived technical-information page or methodology references

These are not always direct PDF links, but they lead to or identify the EPA
technical-information page that presented the document.

| Source file | Lines | Reference / context |
| --- | ---: | --- |
| `vignettes/ejscreen.Rmd` | 142, 200, 202 | Links to the locally archived Technical Information and Data Downloads page and its Wayback counterpart. The PDF itself is linked separately above. |
| `vignettes/env-indicators/ejscreen-indicators-overview-particulate-matter-25-pm25.Rmd` | 51 | Links to the archived technical-information page as well as the archived PDF. |
| `data-raw/EJSCREEN_archived_pages/ejscreen-indicators-overview-particulate-matter-25-pm25.Rmd` | 38 | Archived-page source; links to the archived technical-information page and PDF. |
| `data-raw/EJSCREEN_archived_pages/ejscreen-indicators-overview-diesel-particulate-matter.Rmd` | 31 | Archived-page source; links to the local archived technical-information page. |
| `R/doaggregate.R` | 48–50 | Roxygen documentation points to a GitHub HTML preview of the archived page and its Wayback version, in the context of the nearby-residents methodology. |
| `inst/report/written_report/report.Rmd` | 269–270 | Written report refers readers to the archived EJSCREEN technical-documentation page for technical details. |
| `inst/report/written_report/long_report_template_2-10-25.Rmd` | 447, 457–458, 505 | Report template cites the archived EJSCREEN methodology / technical-information page in methodology and buffering discussions. |

## Methodology mentions without a direct document link

Review these if the goal includes updating attributions or claims, not just
changing URLs.

| Source file | Lines | Reference / context |
| --- | ---: | --- |
| `R/calc_blockgroup_demog_index.R` | 96 | Attributes the final adjustment that makes demographic-index values nonnegative to the EJSCREEN Tech Doc. |
| `R/doaggregate.R` | 48, 63 | Refers to EJSCREEN technical documentation for the nearby-residents approach and formulas; the linked page is listed above. |
| `R/getblocksnearbyviaQuadTree.R` | 209 | Cites the document's discussion of proximity-analysis rationale. |
| `R/getblocksnearbyviaQuadTree2-DRAFT.R` | 238 | Draft implementation comment cites the same proximity-analysis discussion. |
| `R/getpointsnearbyviaQuadTree.R` | 236 | Cites the same proximity-analysis discussion. |
| `data-raw/EJSCREEN_archived_pages/overview-socioeconomic-indicators-ejscreen.Rmd` | 42 | Says the Technical Documentation explains socioeconomic indicators; no direct PDF link in this source line. |

## Notes for review

- The shared helper currently targets GitHub `main`, while one overview source
  links directly to the `development` branch and the `ejscreen.Rmd` commented
  example also mentions `development`.
- Wayback PDF snapshots use different capture timestamps (January 2025 in most
  links; September 2025 in `ejscreen.Rmd`). The archived technical-information
  page is also referenced through several capture timestamps.
- Archived-page `.Rmd` files are included because they are source files, even
  though they represent archived content. Their generated `.html` counterparts
  are deliberately not listed.
- Generated files such as `man/formulas_ejscreen_acs.Rd`,
  `man/doaggregate.Rd`, `man/url_ejscreentechdoc.Rd`, and archived-page HTML
  copies are out of scope for this source-only review.
