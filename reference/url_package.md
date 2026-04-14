# Get URL, or just owner/reponame, for the package code, datasets, or documentation website as specified in the DESCRIPTION file or by redirects from aliases

Get URL, or just owner/reponame, for the package code, datasets, or
documentation website as specified in the DESCRIPTION file or by
redirects from aliases

## Usage

``` r
url_package(
  type = c("code", "data", "docs")[1],
  get_full_url = FALSE,
  desc_or_alias = c("desc", "alias")[1],
  domain = NULL
)
```

## Arguments

- type:

  Which type of URL is needed? Can be "data", "code", or "docs".

  - "code" is for the github.com repository of R package code

  - "data" is for the github.com repository of datasets

  - "docs" is for the documentation website

- get_full_url:

  logical, whether to return full URL or just the owner/reponame info.
  Ignored if type = "docs", where full URL is always returned.

- desc_or_alias:

  must be "desc" or "alias" to use info from DESCRIPTION file or the URL
  based on a redirect from the aliases at

  - https://ejanalysis.org/code

  - https://ejanalysis.org/data

  - https://ejanalysis.org/docs

- domain:

  obsolete parameter - do not use

## Value

a single URL or owner/repo as a character string

## Details

See https://ejanalysis.com/ejam-code for a list of URLs

## Examples

``` r
 owner_repo <- url_package()
 reponame <- gsub(".*/", "", owner_repo)
 reponame

 url_package("docs")

 url_package("code")
 url_package("code", get_full_url=T)

 url_package("data")
 url_package("data", get_full_url=T)

 url_package("docs", desc_or_alias="alias")
 url_package("code", desc_or_alias="alias")
 url_package("data", desc_or_alias="alias")
```
