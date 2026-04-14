# Read shapefile from any file or folder (trying to infer the format)

Read shapefile from any file or folder (trying to infer the format)

## Usage

``` r
shapefile_from_any(
  path = NULL,
  cleanit = TRUE,
  crs = 4269,
  layer = NULL,
  inputname = NULL,
  silentinteractive = FALSE,
  ...
)
```

## Arguments

- path:

  path of file(s) that is/are .gdb, .zip, .shp, .kml, .geojson, .json,
  etc., or folder

  - If .zip or folder that has more than one shapefile in it, cannot be
    read by this function, and must be unzipped and handled separately.

  - If folder, tries to read with (unexported) helper
    [`shapefile_from_folder()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_folder.md)
    Folder must contain one each of files with extensions .shp, .shx,
    .dbf, and .prj

  - If .zip containing a folder, unzips, then tries to read with
    (unexported) helpers
    [`shapefile_from_folder()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_folder.md)
    or
    [`shapefile_from_gdbzip()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_gdbzip.md)

  - If .zip containing .gdb, reads with (unexported) helper
    [`shapefile_from_gdbzip()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_gdbzip.md)

  - If .gdb, reads with (unexported) helper
    [`shapefile_from_gdb()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_gdb.md)

  - If .json or .geojson, reads with (unexported) helper
    [`shapefile_from_json()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_json.md)

  - If text in geojson format, reads with (unexported) helper
    [`shapefile_from_geojson_text()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_geojson_text.md)

  - If .kml or .shp, uses
    [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

  - If vector of .shp, .shx, .dbf, and .prj file names (that may include
    paths), reads with (unexported) helper
    [`shapefile_from_filepaths()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_filepaths.md)

- cleanit:

  set to FALSE if you want to skip validation and dropping invalid rows

- crs:

  passed to helper functions and default is crs = 4269 or Geodetic CRS
  NAD83

- layer:

  optional layer name passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

- inputname:

  vector of shiny fileInput uploaded filenames

- silentinteractive:

  set to TRUE to NOT prompt for a file/folder when one is not specified

- ...:

  passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame
