{############################################################# # ############################################################# #
# . ####
# HOW TO USE THIS FUNCTION ####

  # note this could at some point be replaced by a gh actions workflow that would automatically update the pkgdown site (after a PR or push),
  # but for now, this is a utility function to run manually when you want to update the pkgdown site,
  # and it has some options for what steps to do or not do, and whether to ask about each step or just use defaults.

# cat(
#   "
# To use this function:
#
# Maybe create a background job that runs this:
#   './data-raw/pkgdown_update_background_job.R'
#
# pkgdown_update(doask = TRUE)
#
# or change from any of these defaults:
#
# pkgdown_update = function(
#     doask              = FALSE,
#     dotests            = FALSE,
#     testinteractively  = FALSE, ## maybe we want to do this interactively even if ask=F ?
#     doyamlcheck        = TRUE, ## dataset_pkgdown_yaml_check() does siterep but also check internal v exported, listed in pkgdown reference TOC etc.
#     dodocument         = TRUE,  ## in case we just edited help, exports, or func names,
#     ##   since doinstall=T via this script omits document()
#     doinstall          = FALSE,  ## but skips document() and vignettes
#     doloadall_not_library = TRUE, ## (happens after install, if that is being done here)
#     doclean_man  = F,   ## file.remove(list.files('./man', full.names = TRUE))
#     doclean_docs  = F,  ## pkgdown::clean_site('.', force=T) # deletes html etc in docs or relevant folder
#     dobuild_site      = TRUE     ## use build_site() or stop?
# )
# ")
# cat("\n  Current defaults: \n\n")
# x = (EJAM:::args2(pkgdown_update)); rm(x)
############################################################# # ############################################################# #

############################################################# # ############################################################# #

  ## Notes on initial setup of pkgdown site ####
  #

  # Note the URL of the repository publishing the pkgdown site belongs
  # in DESCRIPTION and also must be separately placed
  # in _pkdgown.yml
  #

  # To specify which branch site gets published from:
  #    https://github.com/OWNERGOESHERE/REPONAME/settings/pages ( REPONAME may be EJAM )
  #    to get likely URL from DESCRIPTION file:  EJAM::url_package(get_full_url = T)
  # see https://pkgdown.r-lib.org/articles/pkgdown.html#configuration
  # see https://usethis.r-lib.org/reference/use_pkgdown.html
  ### also possibly of interest:
  # devtools::build_manual()          # for a  pdf manual
  # postdoc::render_package_manual()  # for an html manual
  ############################################################# #
  #
  ##   Initial setup of authorization tokens:
  #
  ## 1st confirm personal access token PAT exists and not expired
  ##  (to allow use of github API to create new branch gh-pages, create github action, etc.)
  #     To check on PATs:
  # usethis::gh_token_help() and
  # usethis::git_sitrep() # git situation report
  ##    To make a PAT:
  # usethis::create_github_token()
  ##    To register a PAT, see
  # credentials::set_github_pat()
  ##    https://usethis.r-lib.org/articles/git-credentials.html#git-credential-helpers-and-the-credential-store
  ##    Windows more or less takes care of this for you now, in conjunction with github.
  ############################################# #
  #
  ##   Initial setup of github pages website using pkgdown:
  #
  # usethis::use_github_pages(branch = "main", path = "/docs")
  ##   does
  # usethis::use_pkgdown()   and does other steps,
  ##   but note it replaces/deletes any existing _pkgdown.yml file
  #
  #   Traditional (not pkgdown) vignettes are no longer recommended by roxygen2 pkg docs:
  # see   help(vignette_roclet, package = "roxygen2")
  # Can turn them off in RStudio "Build" - "Configure Build Options" - "Build Tools" - "Generate Docs with Roxygen"
  #   and by adding   --no-build-vignettes to the "Build Source Package" field in your project options.
}
############################################################# # ############################################################# #
# . ####


#' Configure Pandoc for local pkgdown rendering
#'
#' @return TRUE, invisibly.
#'
#' @keywords internal
#'
pkgdown_configure_pandoc = function() {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Package 'rmarkdown' is required to render pkgdown articles.", call. = FALSE)
  }
  if (rmarkdown::pandoc_available()) {
    return(invisible(TRUE))
  }

  rstudio_pandoc_dirs <- c(
    Sys.getenv("RSTUDIO_PANDOC", unset = NA_character_),
    "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64",
    "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/x86_64"
  )
  rstudio_pandoc_dirs <- rstudio_pandoc_dirs[!is.na(rstudio_pandoc_dirs)]
  rstudio_pandoc_dirs <- rstudio_pandoc_dirs[
    file.exists(file.path(rstudio_pandoc_dirs, "pandoc"))
  ]

  if (length(rstudio_pandoc_dirs) > 0) {
    Sys.setenv(RSTUDIO_PANDOC = rstudio_pandoc_dirs[[1]])
  }

  if (!rmarkdown::pandoc_available()) {
    stop(
      "Pandoc was not found. Open RStudio and retry, or set RSTUDIO_PANDOC ",
      "to the folder containing the pandoc executable.",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Preview one pkgdown article without publishing the site
#'
#' @param article Article name such as `"installing"` or a path such as
#'   `"vignettes/installing.Rmd"`.
#' @param pkg Package root.
#' @param destination Local output folder. Defaults to a temporary preview
#'   folder so source branches do not accumulate generated HTML.
#' @param preview Open the rendered article in a browser?
#' @param clean Delete the preview folder before rendering?
#' @param lazy Passed to `pkgdown::build_article()`.
#' @param quiet Passed to `pkgdown::build_article()`.
#'
#' @return The rendered article HTML path, invisibly.
#'
#' @keywords internal
#'
pkgdown_preview_article = function(
    article,
    pkg = ".",
    destination = file.path(tempdir(), "EJAM-pkgdown-preview"),
    preview = interactive(),
    clean = FALSE,
    lazy = FALSE,
    quiet = FALSE
) {
  if (!requireNamespace("pkgdown", quietly = TRUE)) {
    stop("Package 'pkgdown' is required to preview pkgdown articles.", call. = FALSE)
  }
  pkgdown_configure_pandoc()

  article_name <- tools::file_path_sans_ext(basename(article))
  pkg <- normalizePath(pkg, mustWork = TRUE)
  destination <- normalizePath(destination, mustWork = FALSE)

  if (clean && dir.exists(destination)) {
    unlink(destination, recursive = TRUE)
  }
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)

  oldwd <- getwd()
  on.exit(setwd(oldwd), add = TRUE)
  setwd(pkg)

  pkgdown::build_article(
    article_name,
    pkg = pkg,
    lazy = lazy,
    new_process = FALSE,
    override = list(destination = destination),
    quiet = quiet
  )

  html_path <- file.path(destination, "articles", paste0(article_name, ".html"))
  if (preview && file.exists(html_path)) {
    utils::browseURL(html_path)
  }

  invisible(normalizePath(html_path, mustWork = FALSE))
}

#' Preview the pkgdown site locally without publishing it
#'
#' @param pkg Package root.
#' @param destination Local output folder. Defaults to a temporary preview
#'   folder so source branches do not accumulate generated HTML.
#' @param pkgdown_dev_mode Use `"release"` for the main site or `"devel"` for
#'   the development site under `dev/`.
#' @param preview Open the rendered site in a browser?
#' @param clean Delete the preview folder before rendering?
#' @param lazy Passed to `pkgdown::build_site()`.
#' @param quiet Passed to `pkgdown::build_site()`.
#'
#' @return The rendered site index path, invisibly.
#'
#' @keywords internal
#'
pkgdown_preview_site = function(
    pkg = ".",
    destination = file.path(tempdir(), "EJAM-pkgdown-preview"),
    pkgdown_dev_mode = c("release", "devel"),
    preview = interactive(),
    clean = FALSE,
    lazy = TRUE,
    quiet = FALSE
) {
  if (!requireNamespace("pkgdown", quietly = TRUE)) {
    stop("Package 'pkgdown' is required to preview the pkgdown site.", call. = FALSE)
  }
  pkgdown_configure_pandoc()

  pkgdown_dev_mode <- match.arg(pkgdown_dev_mode)
  pkg <- normalizePath(pkg, mustWork = TRUE)
  destination <- normalizePath(destination, mustWork = FALSE)

  if (clean && dir.exists(destination)) {
    unlink(destination, recursive = TRUE)
  }
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)

  old_mode <- Sys.getenv("PKGDOWN_DEV_MODE", unset = NA_character_)
  on.exit({
    if (is.na(old_mode)) {
      Sys.unsetenv("PKGDOWN_DEV_MODE")
    } else {
      Sys.setenv(PKGDOWN_DEV_MODE = old_mode)
    }
  }, add = TRUE)
  Sys.setenv(PKGDOWN_DEV_MODE = pkgdown_dev_mode)

  oldwd <- getwd()
  on.exit(setwd(oldwd), add = TRUE)
  setwd(pkg)

  pkgdown::build_site(
    pkg = pkg,
    examples = FALSE,
    lazy = lazy,
    override = list(destination = destination),
    preview = FALSE,
    devel = TRUE,
    new_process = FALSE,
    install = FALSE,
    quiet = quiet
  )

  html_path <- file.path(destination, "index.html")
  if (pkgdown_dev_mode == "devel") {
    html_path <- file.path(destination, "dev", "index.html")
  }
  if (preview && file.exists(html_path)) {
    utils::browseURL(html_path)
  }

  invisible(normalizePath(html_path, mustWork = FALSE))
}

#' Package-maintainer utility - Rebuilds website of package help docs and vignettes (articles) using pkgdown
#'
#' @param doask whether to ask about each input parameter, for interactively picking settings
#'
#' @param dotests run unit tests first? uses test_ejam()
#' @param testinteractively related to unit testing
#' @param doyamlcheck report on the yaml file via dataset_pkgdown_yaml_check() ?
#' @param dodocument use `roxygen2::roxygenise()` to regenerate documentation?
#'   Usually should leave TRUE.
#' @param doinstall TRUE would mean reinstall package from local source. usually should leave FALSE and maybe do install separately before using this function; would take about 5 minutes and may need to restart R after installing - this is quirky
#' @param doloadall_not_library use devtools::load_all() ? usually should leave this TRUE
#' @param doclean_man delete all files in the /man/ folder ? useful if functions were renamed or deleted or you added a noRd roxygen tag to stop documenting them
#' @param doclean_docs delete all files in /docs/ folder, essentially ? useful if functions were renamed or deleted or you added a noRd roxygen tag to stop documenting them
#' @param dobuild_site should leave this TRUE for a local preview build, not
#'   for publishing the public site. Publishing is handled by GitHub Actions.
#'
#' @examples
#'   # EJAM:::pkgdown_update(doask = TRUE)
#'
#' @return NULL
#'
#' @keywords internal
#'
pkgdown_update = function(
    doask              = FALSE,
    dotests            = FALSE,
    testinteractively  = FALSE, ## maybe we want to do this interactively even if ask=F ?
    doyamlcheck        = TRUE, ## dataset_pkgdown_yaml_check() does siterep but also check internal v exported, listed in pkgdown reference TOC etc.
    dodocument         = TRUE,  ## in case we just edited help, exports, or func names,
    ##   since doinstall=T via this script omits document()
    doinstall          = FALSE,  ## but skips document() and vignettes
    doloadall_not_library = TRUE, ## (happens after install, if that is being done here)
    doclean_man  = FALSE,   ## file.remove(list.files('./man', full.names = TRUE))
    doclean_docs  = FALSE,  ## pkgdown::clean_site('.', force=T) # deletes html etc in docs or relevant folder
    dobuild_site      = TRUE     ## use build_site() or stop?

) {

  ############################################################# # ############################################################# #
  ############################################################# # ############################################################# #
  # # >---------------------  ####

  # setup ####

  if (!interactive()) {doask <- FALSE}
  golem::detach_all_attached()
  pkgdown_configure_pandoc()
  ############################################################# #

  # ask what to do ####

  if (doask && interactive() && rstudioapi::isAvailable()
      && missing("dotests")
  ) {dotests <- utils::askYesNo("Do you want to run tests 1st?")}
  if (is.na(dotests)) {stop('stopped')}

  if (doask && interactive() && rstudioapi::isAvailable() &&
      dotests
      && missing("testinteractively")
  ) {testinteractively <- utils::askYesNo("Do you want to answer questions about the tests to run?")}
  if (is.na(testinteractively)) {stop('stopped')}

  if (doask && interactive()  && rstudioapi::isAvailable()
      && missing("doyamlcheck")
  ) {doyamlcheck <- utils::askYesNo("Use dataset_pkgdown_yaml_check() to see which functions are missing in function reference etc.? Note it will run load_all() first so that pkgdown::pkgdown_sitrep() can check the latest source versions of docs not just installed version")}
  if (is.na(doyamlcheck)) {stop('stopped')}

  if (doask && interactive()  && rstudioapi::isAvailable()
      && missing("dodocument")
  ) {dodocument <- utils::askYesNo("Regenerate documentation now with roxygen2::roxygenise()?")}
  if (is.na(dodocument)) {stop('stopped')}

  if (doask && interactive()  && rstudioapi::isAvailable()
      && missing("doinstall")
  ) {doinstall <- utils::askYesNo("Do you want to re-install the package? This will not rerun roxygen2::roxygenise() unless dodocument is also TRUE")}
  if (is.na(doinstall)) {stop('stopped')}

  if (doask && interactive()  && rstudioapi::isAvailable()
      && missing("doloadall_not_library")
  ) {doloadall_not_library  <- utils::askYesNo("do load_all() instead of library(EJAM) ?")}
  if (is.na(doloadall_not_library)) {stop('stopped')}

  if (doask && interactive()  && rstudioapi::isAvailable()
      && missing("doclean_man")
  ) {doclean_man <- utils::askYesNo("Do you want to delete all .Rd files to remove obsolete ones, and let roxygen recreate all?")}
  if (is.na(doclean_man)) {stop('stopped')}

  if (doask && interactive()  && rstudioapi::isAvailable()
      && missing("doclean_docs")
  ) {doclean_docs <- utils::askYesNo("Do you want to delete all docs folder (pkgdown-related) files to remove obsolete ones, and let pkgdown recreate all?")}
  if (is.na(doclean_docs)) {stop('stopped')}

  #################### #
  # # >---------------------  ####

    # if dotests, UNIT TESTS via test_ejam()####

  if (dotests) {
    cat('doing unit tests \n')
    print(Sys.time())
    test_ejam(ask = doask & interactive() & testinteractively )
    print(Sys.time())
  }
  #################### #

  cat("\n\n   ------------- STARTED -------------- \n")
  print(Sys.time())
  cat("\n\n")
  #################### #

  # checkDocFiles() ####

  print(tools::checkDocFiles(dir = "."))

  # ? check() ?
  # devtools::check()
  ##   automatically builds and checks a source package, using all known best practices.
  # devtools::check_man()
  # devtools::check_built() checks an already-built package.

  #################### #
  # insert correct app name and version and date into _pkgdown.yml
  # since it cannot contain R code inline that dynamically finds that info to use in footer of html files etc.
  cat("updating version/date/title in _pkgdown.yml, for footers of help pages, etc.\n")
  x = readLines("_pkgdown.yml")

  home_title_text = paste0('EJAM ', as.vector(desc::desc_get('Title')))
  x = gsub("^  title: .*$", paste0("  title: ", home_title_text), x)

  datefooter = as.vector(desc::desc_get('VersionDate'))
  x =  gsub("^    datefooter: .*$", paste0("    datefooter: ", datefooter), x)

  versionmsg = paste0('Version ', as.vector(desc::desc_get('Version')))
  x =  gsub("^    versionmsg: .*$", paste0("    versionmsg: ", versionmsg), x)

  writeLines(text = x, "_pkgdown.yml")

  #################### #

  # if doyamlcheck, _pkgdown.yml check ####

  if (doyamlcheck) {
    if (!requireNamespace("pkgdown", quietly = TRUE)) {
      stop("Package 'pkgdown' is required to check _pkgdown.yml.", call. = FALSE)
    }
    # first just check if any .Rd files should get deleted as obsolete
    pkg_clean_stale_rd(dry_run = TRUE, verbose=TRUE)

    #cat('Using load_all() 1st, before using dataset_pkgdown_yaml_check() ... \n')
    #devtools::load_all(quiet = T, helpers = F, export_all = T)
    #    dataset_pkgdown_yaml_check() will not work without the unexported dataset_pkgdown_yaml_check() available
    cat('Using dataset_pkgdown_yaml_check() which includes pkgdown_sitrep(), which reports status of all checks ... \n')
    missing_from_yml <- dataset_pkgdown_yaml_check()
    # that prints some results to console.
    # `pkgdown::pkgdown_sitrep()` does, among other things,
    #   confirm the URL for publishing the pkgdown site listed in _pkgdown.yml
    #   matches what is in DESCRIPTION
    #    per  EJAM::url_package(type = "docs", get_full_url = TRUE)

    if (doask && interactive()  && rstudioapi::isAvailable()) {
      cat('\n\n')
      yn <- utils::askYesNo("Halt now to edit/fix _pkgdown.yml etc. ?")
      if (is.na(yn) || isTRUE(yn)) {
        if (file.exists('_pkgdown.yml')) {rstudioapi::documentOpen('_pkgdown.yml')}
        message('stopped to fix _pkgdown.yml')
        cat('\n\n MISSING according to dataset_pkgdown_yaml_check() are the following: \n\n')
        print(dput(missing_from_yml))
        return(missing_from_yml)
        # stop('stopped to fix _pkgdown.yml')
      }
    }
  }
  #################### # #################### # #################### # #################### #
  # REDO ALL DOCUMENTATION FROM SCRATCH?

  if (dodocument || doinstall) {
    ## if doclean_man ####
    if (doclean_man ) {
      cat('deleting all .Rd (help) files in ./man folder \n')
      file.remove(list.files('./man', pattern = ".*[^figures]$", full.names = TRUE, include.dirs = FALSE)) # leave the figures directory that has a logo in it
      ## might
    }
    # notes on doclean_man:   but see  EJAM:::pkg_clean_stale_rd()
    # # MAYBE NEED TO DELETE ALL IN THE man/ FOLDER TO REMOVE OBSOLETE .Rd files like no longer documented or renamed functions ?
    # cat("You might need to do something like  \n  file.remove(list.files('./man', full.names = TRUE, include.dirs = FALSE)) \nto delete all of /man/*.* to be sure there is nothing obsolete like renamed or deleted or no-longer-documented functions. \n")
  }
  # if dodocument, README & DOCUMENT via render() & roxygenise() ####

  if (dodocument || doclean_man) {
    cat('rendering README.Rmd to .md  \n')
    print(Sys.time())
    rmarkdown::render("README.Rmd")  # renders .Rmd to create a  .md file that works in github as a webpage

    # build_rmd() would take a couple minutes as it installs the package in a temporary library
    # build_rmd() would just be a wrapper around rmarkdown::render() that 1st installs a temp copy of pkg, then renders each .Rmd in a clean R session.
    #################### # #################### # #################### # #################### #
    cat('detaching packages  \n')
    golem::detach_all_attached()

    cat('trying to do roxygen2::roxygenise() \n')
    if (!requireNamespace("roxygen2", quietly = TRUE)) {
      stop("Package 'roxygen2' is required to regenerate documentation.", call. = FALSE)
    }
    roxygen2::roxygenise()
    if (doclean_man) {
      cat('doing roxygen2::roxygenise() again now, just in case, because if doclean_man=T, it deletes all files in the man folder, \nafter which the 1st time you try to document it cannot resolve links to other topics not yet turned into .Rd files\n')
      roxygen2::roxygenise()
      }
  }
  #################### # #################### # #################### # #################### #

  # if doinstall, INSTALL via install() ####

  if (doinstall) {

    cat('doing install()  \n')  # there may be problems with this step being done from this function?
    print(Sys.time())
    system.time({

      # 4+ minutes for install()

      # Usually just use devtools::load_all()  during development, not re-install every time you edit source.

      # BUT, using a local install from source will ensure anything that uses the INSTALLED version will work!

      # note, If you want to build/install using RStudio buttons, not the function install(), need to
      #   1st confirm you already turned off traditional vignette-building...  see   help(vignette_roclet, package = "roxygen2")
      #   That button includes a step that is similar to roxygen2::roxygenise().

      if (!requireNamespace("pak", quietly = TRUE)) {
        stop("Package 'pak' is required to install the package from pkgdown_update().", call. = FALSE)
      }
      pak::local_install(root = ".", dependencies = TRUE, upgrade = FALSE)
      #################### #
      cat('detaching packages - RESTART R IF THIS FAILS  \n') # when using devtools had gotten Error: lazy-load database '....EJAM/R/EJAM.rdb' is corrupt
      golem::detach_all_attached()
      # rstudioapi::restartSession() might be needed. or just relaunch R seems to help.
    })
  }
  #################### # #################### # #################### # #################### #

  # if doloadall_not_library, LOAD ALL FROM SOURCE via load_all() ####

  print(Sys.time())
  if (doloadall_not_library) {
    cat('detaching packages, then doing load_all() \n')
    golem::detach_all_attached()
    if (!requireNamespace("devtools", quietly = TRUE)) {
      stop("Package 'devtools' is required to load source files from pkgdown_update().", call. = FALSE)
    }
    devtools::load_all() # doing load_all() without having done library() first might fail to do some of what is needed?
  } else {
    cat('doing library(EJAM) \n')
    x = try( library(EJAM) ) # library() stops with error where require() would only warn
    if (inherits(x, "try-error")) {stop("cannot do library(EJAM) ... try restarting R")}
    rm(x)
  }

  #################### # #################### # #################### # #################### #

  ## 2 options for how to keep site updated, from pkgdown intro https://pkgdown.r-lib.org/articles/pkgdown.html
  #
  # A) If you’re using GitHub, we recommend setting up pkgdown and GitHub actions
  # (e.g., https://github.com/r-lib/actions/tree/v2-branch/examples#build-pkgdown-site )
  # to automatically build and publish your site:
  #  Run this ONCE EVER to have github actions re-publish your site regularly:
  #
  #   usethis::use_pkgdown_github_pages()  # only ONCE
  #
  # B) But, if not using GitHub (or if GitHub Actions have trouble rendering vignettes to html
  #   due to lacking access to large dataset files etc.)
  #   then you'll have to run this manually EVERY TIME you want to update the site:

  #   pkgdown::build_site()

  # # >---------------------  ####
  # if dobuild_site, ** BUILD SITE (HTML FILES) ####

  if (dobuild_site) {
    if (!requireNamespace("pkgdown", quietly = TRUE)) {
      stop("Package 'pkgdown' is required to rebuild the pkgdown site.", call. = FALSE)
    }

    ## if doclean_docs ####
    if (doclean_docs) {
      cat("Doing pkgdown::clean_site()  \n")
      # pkgdown::clean_site('.')
      pkgdown::clean_site(force = TRUE)
      # similar to doing this:  file.remove(list.files('./docs', full.names = TRUE))
    }
    # notes on doclean_docs:
    # # MAYBE NEED TO DELETE ALL IN THE docs/ FOLDER TO REMOVE OBSOLETE .html files like no longer used vignettes ?
    # cat("You might need to do \n  pkgdown::clean_site('.') \n and/or \n  file.remove(list.files('./docs', full.names = TRUE))  \nto delete all of /docs/*.*  to be sure there is nothing obsolete like renamed or deleted or no-longer-documented functions. \n")
    ########################## #
    cat("Doing build_site()  \n")
    print(Sys.time())

    pkgdown::build_site(
      examples = FALSE, lazy = TRUE,
      devel = FALSE,
      install = FALSE, new_process = FALSE
    )

    ### notes on pkgdown::build_site() ####
    #
    # https://pkgdown.r-lib.org/reference/build_site.html
    # build_site() is a convenient wrapper around six functions:
    #
    # init_site()
    # build_home()
    # build_reference() & index - ** THIS TAKES FOREVER **   (could perhaps do as bkgd job)
    # build_articles()  - THIS TRIES TO RUN THE CODE IN VIGNETTES/ARTICLES AND RENDER THEM
    # build_tutorials() - NA
    # build_news()
    # build_redirects() / sitemap/ search index
    #
    # build_site_github_pages() is for use in a github action, and would do more steps:
    #  build_site(), but then also gets metadata about package and does
    #  clean_site() and
    #  build_github_pages()

  } else {
    # pkgdown::build_site_github_pages() is meant to be used as part of github actions
    #   # https://pkgdown.r-lib.org/reference/build_site_github_pages.html
  }
  print(Sys.time())
  # # >---------------------  ####
  ################################################################## #
  # remember to push so gh actions publish it ####
  if (TRUE) {
    cat( '\n\n NOW COMMIT AND PUSH THE NEW FILES \n\n')
    cat("GitHub Actions publishes the public site to the gh-pages branch. \n")
    cat("Local files in docs/ are previews only and should not be committed from source branches. \n")
  }
  ################################################################## #
  # note on build() - how to build pkg as a single file ####
  ## Building converts a package source directory into a single bundled file.
  ## If binary = FALSE (default) this creates a tar.gz package that can be installed on any platform,
  ##    except note if the pkg has source code [that needs to be compiled, meaning C?] they must have a full development environment (Rtools, etc.?).
  ## If binary = TRUE, the package will have a platform specific extension (e.g. .zip for windows),
  ##    and will only be installable on the current platform, e.g., Windows only, (but no development envt needed, even if pkg had C, which needs to be compiled platform-specific).
  ## To build a package you can use  rstudio  menu, build ...
  ##     or in RStudio console,
  ##  build(".")
  ##  ?build
  ################################################################## #
  return(NULL)
  # # >---------------------  ####
}
############################################################# # ############################################################# #
