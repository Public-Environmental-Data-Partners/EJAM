# utility to create text for use in report about residents within X miles of Y

utility to create text for use in report about residents within X miles
of Y

## Usage

``` r
report_residents_within_xyz_from_ejamit(ejamitout, sitenumber = NULL, ...)
```

## Arguments

- ejamitout:

  list that is output of
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- sitenumber:

  optional, which site number to report on for a 1-site report instead
  of the overall summary of all sites

- ...:

  See
  [`report_residents_within_xyz()`](https://ejanalysis.github.io/EJAM/reference/report_residents_within_xyz.md)
  for details of optional parameters that can be specified – they get
  passed from here to that function. For example, if it is a 1-site
  report as via sitenumber=2, and you set ejam_uniq_id = "Jones Mill
  Site" it will use that in the header instead of using "ejam_uniq_id 2"
  (but ejam_uniq_id is ignored for a multisite summary report).

## Value

text string
