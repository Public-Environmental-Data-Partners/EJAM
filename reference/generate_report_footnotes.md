# helper - make footnote for summary report, like caveat about diesel PM, accuracy, or other notes

helper - make footnote for summary report, like caveat about diesel PM,
accuracy, or other notes

## Usage

``` r
generate_report_footnotes(
  diesel_caveat =
    paste0("Note: Diesel particulate matter index is from the EPA's Air Toxics Data Update, which is the Agency's ongoing, comprehensive evaluation of air toxics in the United States. This effort aims to prioritize air toxics, emission sources, and locations of interest for further study. It is important to remember that the air toxics data presented here provide broad estimates of health risks over geographic areas of the country, not definitive risks to specific individuals or locations. More information on the Air Toxics Data Update can be found at: ",
    
     url_linkify("https://www.epa.gov/haps/air-toxics-data-update",
    "https://www.epa.gov/haps/air-toxics-data-update"))
)
```

## Arguments

- diesel_caveat:

## See also

used by
[`build_community_report()`](https://public-environmental-data-partners.github.io/EJAM/reference/build_community_report.md)
