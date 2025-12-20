# utility to prep URLs for being written to Excel

utility to prep URLs for being written to Excel

## Usage

``` r
url_xl_style(urls, urltext = urls)
```

## Arguments

- urls:

  vector of urls such as from
  [`url_ejamapi()`](https://ejanalysis.github.io/EJAM/reference/url_ejamapi.md)

- urltext:

  The text to appear in Excel cells instead of just the URL showing

## Details

See table_xls_format()

Works best if using
[`openxlsx::writeData()`](https://rdrr.io/pkg/openxlsx/man/writeData.html)
not
[`openxlsx::write.xlsx()`](https://rdrr.io/pkg/openxlsx/man/write.xlsx.html)

To write this column of urls to a worksheet:

    lat <- c(30.977402, 32.515813); lon = c(-83.368997, -86.377325)
    radius <- 1
    urls <- url_ejscreenmap(lat=lat, lon=lon, radius=radius)

    urlx <- EJAM:::url_xl_style(urls, urltext = paste0("Report ", 1:2))

    wb <- openxlsx::createWorkbook()
    openxlsx::addWorksheet(wb, sheetName = 'tab1')
    openxlsx::writeData(wb, sheet = 1, x = urlx, startCol = 1, startRow = 2)
    openxlsx::saveWorkbook(wb, file = '~/test1.xlsx', overwrite = TRUE)

    # using just [openxlsx::write.xlsx()] is simpler but ignores the urltext param:
    openxlsx::write.xlsx(data.frame(lat = lat, lon = lon, urlx), file = 'test2.xlsx')
