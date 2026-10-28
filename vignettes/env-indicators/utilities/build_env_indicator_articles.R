# Build each env-indicators article separately, so one failing article
# does not stop the others.
# Run from the EJAM package root: source("vignettes/env-indicators/utilities/build_env_indicator_articles.R")

articles <- c(
  "env-indicators/ejscreen-indicators-overview-diesel-particulate-matter",
  "env-indicators/ejscreen-indicators-overview-drinking-water-non-compliance",
  "env-indicators/ejscreen-indicators-overview-hazardous-waste-proximity",
  "env-indicators/ejscreen-indicators-overview-lead-paint",
  "env-indicators/ejscreen-indicators-overview-nitrogen-dioxide-no2",
  "env-indicators/ejscreen-indicators-overview-ozone",
  "env-indicators/ejscreen-indicators-overview-particulate-matter-25-pm25",
  "env-indicators/ejscreen-indicators-overview-risk-management-program-rmp-facility-proximity",
  "env-indicators/ejscreen-indicators-overview-superfund-proximity",
  "env-indicators/ejscreen-indicators-overview-toxic-releases-air",
  "env-indicators/ejscreen-indicators-overview-traffic-proximity-and-volume",
  "env-indicators/ejscreen-indicators-overview-underground-storage-tanks-ust",
  "env-indicators/ejscreen-indicators-overview-wastewater-discharge",
  "env-indicators/indicator-source-data",
  "overview-environmental-indicators-ejscreen"
)

failed <- character()

for (article in articles) {
  tryCatch(
    pkgdown::build_article(article, quiet = FALSE),
    error = function(e) {
      message("FAILED: ", article, "\n", conditionMessage(e))
      failed <<- c(failed, article)
    }
  )
}

message("\n", length(articles) - length(failed), " of ", length(articles), " articles built.")
if (length(failed) > 0) {
  message("Failed:\n  ", paste(failed, collapse = "\n  "))
}
