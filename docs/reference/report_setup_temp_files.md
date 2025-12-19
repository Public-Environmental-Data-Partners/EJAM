# helper - copies template, css to tempdir for render of summary report helper - copies .Rmd (template), .css from Rmd_folder to a temp dir subfolder for rendering

helper - copies template, css to tempdir for render of summary report
helper - copies .Rmd (template), .css from Rmd_folder to a temp dir
subfolder for rendering

## Usage

``` r
report_setup_temp_files(
  Rmd_name = "community_report_template.Rmd",
  Rmd_folder = "report/community_report/"
)
```

## Arguments

- Rmd_name:

  .Rmd filename the package uses

- Rmd_folder:

  folder the package stores the template in

## Details

used by
[`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md)
only now? was also copying logo .png ? but not now?
