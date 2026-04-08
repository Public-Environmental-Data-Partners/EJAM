# Updating Documentation

This document addresses how to update the documentation supporting the
package.

## Updating package documentation

The R package is documented in webpages (and in standard help documents
viewable in RStudio). Documentation will generally need to be updated in
preparation for a new release of the package. Updates may be needed in
the following:

1.  [Package: overall, package-wide information/
    documents](#package-overall-package-wide-information-documents)

2.  [Functions: reference docs explaining the R
    functions](#functions-reference-docs-explaining-the-r-functions)

3.  [Datasets: reference docs explaining the
    datasets](#datasets-reference-docs-explaining-the-datasets) (in
    EJAM/R/data\_\*.R files)

4.  [Articles: vignettes helping R users with the
    package](#articles-vignettes-helping-r-users-with-the-package) (in
    `EJAM/vignettes/*.Rmd`)

5.  [User Guide: help for people using the web
    app](#user-guide-help-for-people-using-the-web-app) (in
    `EJAM/inst/app/www/` as a .pdf file)

6.  [Spell-checking package-wide](#spell-checking-package-wide)

7.  [Website: web pages providing all of the above in html
    format](#website-web-pages-providing-all-of-the-above-in-html-format),
    via the [pkgdown](https://pkgdown.r-lib.org/) package

Each is explained below:

### Package: overall, package-wide information/ documents

- Package-wide documentation files can be updated/edited and include the
  following: `DESCRIPTION`, `README.Rmd` (for README, **edit the
  README*.Rmd**NOT* the README.*md* file**), R/EJAM-package.R (for
  `?EJAM-package`), `NEWS.md` used to make
  [NEWS](https://ejanalysis.github.io/EJAM/news/index.md),
  `CONTRIBUTING.md` used to make
  [CONTRIBUTING](https://ejanalysis.github.io/EJAM/CONTRIBUTING.md),
  [LICENSE](https://ejanalysis.github.io/EJAM/LICENSE.md) based on
  `inst/LICENSE.md`,
  [CITATION](https://ejanalysis.github.io/EJAM/authors.html#citation)
  based on `inst/CITATION`, CITATION.cff, and others.

- Some of these are used by and shown by the github.com repository,
  notably the `README.md` that is generated from the `README.Rmd` file
  and appears on the github repository as
  [README](https://ejanalysis.github.io/EJAM/articles/%60r%20paste0(code_reponame_url,%20%22?tab=readme-ov-file#readme%22)%60)
  and in the pkgdown site as
  [README](https://ejanalysis.github.io/EJAM/index.md), and the
  `DESCRIPTION` file that stores package version number and URLs of the
  package repository, etc.

### Functions: reference docs explaining the R functions

- [roxygen2](https://roxygen2.r-lib.org/) package tags define the
  documentation in the R/\*.R files that contain the source code and
  documentation of functions and datasets.

- While many functions or objects have their own .R files, some .R files
  contain code and documentation for multiple functions, so not every
  function has a .R file of its own.

- some utility/helper functions, mostly not exported, are stored in
  files prefixed with “utils\_” such as `R/utils_indexblocks.R`
  documenting
  [`indexblocks()`](https://ejanalysis.github.io/EJAM/reference/indexblocks.md)
  (but not all helper functions are in files named that way).

- you might find it useful to check docs with
  [`tools::checkDocFiles`](https://rdrr.io/r/tools/QC.html)(“EJAM”)

### Datasets: reference docs explaining the datasets

- all datasets are documented in the files named with a prefix of
  “data\_” such as `R/data_blockgroupstats.R` which documents the
  [`?blockgroupstats`](https://ejanalysis.github.io/EJAM/reference/blockgroupstats.md)
  dataset.

- most dataset documentation is created/updated alongside the code that
  created or updates those datasets. That is best done starting with the
  overarching file called `data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`
  which helps walk through updating various datasets as needed and their
  documentation is often updated in that same process.

- Many `R/*.R` files for datasets are created automatically, not edited
  by hand, through the
  [`dataset_documenter()`](https://ejanalysis.github.io/EJAM/reference/dataset_documenter.md)
  function as used in the scripts within `data-raw/datacreate_*.R` while
  others are updated by editing the .R file directly.

### Articles: vignettes helping R users with the package

- Articles (called vignettes, here) are written/edited as .Rmd files in
  the `vignettes` folder. You can test one using something like
  [`pkgdown::build_article()`](https://pkgdown.r-lib.org/reference/build_articles.html)
  before trying to rebuild the whole pkgdown site.

- New articles or renamed files require edits to the `_pkgdown.yml` file
  also.

### User Guide: help for people using the web app

- If you change the UI then new screenshots are needed for a new version
  of the User Guide that was stored as a .pdf document built from a Word
  doc.

### Spell-checking package-wide

- To run a spell check (see terms flagged as possible problems)

``` r
    x <- spelling::spell_check_package()
    x <- data.frame(
      frq = sapply(x$found, function(z) {length(unlist(z))}), 
      word = x$word)
    x <- x[order(x$frq), ]
    rownames(x) <- NULL
    x
```

- Then you can use ctrl-shift-F to search in all files for a flagged
  term to check if it is actually a problem

- If you wanted to update the WORDLIST (list of words to ignore spelling
  of)

``` r
    # 1. Add obvious dataset names documented to the WORDLIST
    datanames = gsub('\\.R$', '', gsub('^data_', '', dir('./R', pattern = '^data_.*R')))
    datanames = datanames[!grepl('aaaaaaaaaaaaa|xxxxxxxxxx', datanames)]
    # 2. Add names of functions to the WORDLIST
    funcnames = EJAM:::pkg_functions_and_data( 'EJAM' )$object
    wordlist = readLines('inst/WORDLIST')
    wordlist = sort(unique(union(wordlist, c(datanames, funcnames))))
    # Write the revised list of words to the file
    writeLines(wordlist, 'inst/WORDLIST')
```

### Website: web pages providing all of the above in html format

The web-based documentation pages should be updated right after any of
the above are edited/created. These pkgdown-based webpages should be
updated by someone who is managing the package, as follows:

- The first step in updating those web pages is updating the yml file.
  The web-based documentation pages are organized by a file called
  `_pkgdown.yml` – see
  [`usethis::edit_pkgdown_config()`](https://usethis.r-lib.org/reference/edit.html)
  – which specifies the contents of the webpages of documentation, such
  as the names of any vignettes files to be shown in the list of
  articles, which functions are included in the reference pages index,
  etc. Any new or removed or renamed functions/ vignettes/ datasets, or
  changes in what is exported, will require edits to the .yml file.

- The pkgdown-based webpages should be updated by someone who is
  managing the package, and they should use the
  [`pkgdown_update()`](https://ejanalysis.github.io/EJAM/reference/pkgdown_update.md)
  function mentioned in
  `data-raw/datacreate_0_UPDATE_ALL_DOCUMENTATION_pkgdown.R` You use the
  function pkgdown_update() so that the pages get rebuilt by the
  [pkgdown](https://pkgdown.r-lib.org/) R package, based on the above
  files and all other documentation from .R and .md files. For more
  information about using the [pkgdown](https://pkgdown.r-lib.org/)
  package to create documentation in the form of webpages, see [pkgdown
  articles](https://pkgdown.r-lib.org/articles/pkgdown.html). The
  documentation is created/updated using the
  [roxygen2](https://roxygen2.r-lib.org/) and
  [pkgdown](https://pkgdown.r-lib.org/) R packages, which read
  information from the .R files in the R folder, from .Rmd file
  vignettes (aka “articles”) in the vignettes folder, and from the
  `_pkgdown.yml` file in the root folder of the source package. The
  [roxygen2](https://roxygen2.r-lib.org/) package reads the .R files to
  create the .Rd files in the `man/` directory. The
  [pkgdown](https://pkgdown.r-lib.org/) package uses all those files as
  well as `DESCRIPTION` and others, to generate a website for the
  package, first created as files in the `docs/` folder, which are then
  published via github actions and the github repository settings, to be
  hosted on GitHub Pages. The packages
  [devtools](https://devtools.r-lib.org/) and
  [usethis](https://usethis.r-lib.org) are also relevant.

- the package’s github repository settings define which branch and which
  folder should hold the html files for deployment (see github and
  pkgdown documentation on that)

- the package’s Github Actions can be used to deploy the webpages when
  triggered by an event like any push to the main branch, for example.

- depending on which folder you publish/deploy from, you might have to
  remove that folder from `.gitignore` in case it was listed there via
  some [pkgdown](https://pkgdown.r-lib.org/) or
  [usethis](https://usethis.r-lib.org) function.

- The name of the repo from which documentation is published at any
  given time needs to be recorded as part of the URL parameter in the
  `DESCRIPTION` file in the root folder of the source package. That repo
  URL can be read from there using the helper function
  `url_package()` as
  `url_package(type = "docs")`. Prior to mid-2025,
  documentation webpages had been on github pages at URLs related to the
  USEPA/EJAM and USEPA/EJAM-open repositories – but those pages might be
  archived and/or unpublished, and that source of documentation has
  become obsolete.
