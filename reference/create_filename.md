# create_filename - construct custom filename for downloads in EJAM app

Builds filename from file description, analysis title, buffer distance,
and site selection method. Values are pulled from Shiny app if used
there.

## Usage

``` r
create_filename(
  file_desc = "",
  filename_base = "EJAM",
  with_datetime = TRUE,
  ext = NULL,
  title = "",
  buffer_dist = 0,
  site_method = "",
  replace_spaces_with = " ",
  maxchar = 50,
  maxchar_total = 150
)
```

## Arguments

- file_desc:

  file description, such as "short report", "long report",
  "results_table"

- filename_base:

  optional word to start the file name

- with_datetime:

  boolean to include date and time

- ext:

  optional file extension, like ".html" etc. Will check for '.' and add
  if not provided.

- title:

  analysis title (capped at 100 characters)

- buffer_dist:

  buffer distance, to follow "Miles from"

- site_method:

  site selection method, such as SHP, latlon, FIPS, NAICS, FRS,
  EPA_PROGRAM, SIC, MACT, or anything to follow "places by"

- replace_spaces_with:

  substitutes this in place of each space in file_desc, title, "places
  by", "Miles from", and used to separate from text for buffer_dist and
  site_method @param maxchar optional max characters for each component
  of the name @param maxchar_total optional max for the entire filename,
  truncated at end if necessary

## Value

Returns string of file name (with extension but no path) with specified
components

## Examples

``` r
# specify title only
EJAM:::create_filename(title = 'Summary of Analysis', ext=".txt")

# test / see how it works for various combinations of input parameters
parameters_table = expand.grid(
  file_desc=c("", "FILE DESCRIPTION"),
  title = c("", "My Title"),
  buffer_dist = c(0, 3.2),
  site_method = c("", "latlon"),
  ext = c(NULL, ".html"),
  stringsAsFactors = F
)
cbind(output_filename =
  cbind(
    purrr::pmap(parameters_table, EJAM:::create_filename)
  ),
  parameters_table
)
```
