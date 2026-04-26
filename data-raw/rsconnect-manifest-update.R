################################################################################################## #
# Note the package here is called 'EJAM' even though a repo can be called something other than 'EJAM'
# and still contain/offer an installable copy of a branch/version/release of the EJAM pkg.

################################################################################################## #

#       SCRIPT USED TO HELP REDEPLOY SHINY APP AFTER UPDATES/EDITS
#
# 1) Source the steps below (to install the pkg from github, then update the manifest file) and then
# 2) commit changes (updated manifest file) to git repo and then
# 3) either manually update deployed app via posit connect server management page,
# or just wait until it periodically updates by itself.

############################################ #

## 1st reinstall package to this machine, from specified repo and branch (needed for manifest)

# as explained at
#
# browseURL(paste0(EJAM::url_package(type = "docs"), "/articles/installing.html"))

# reponame = EJAM::url_package() # works if currently is installed
reponame = EJAM::url_package()

## If you want to uninstall the currently-installed version first:
# remove.packages("EJAM", lib = "~/Rlibs")

devtools::install_github(

  repo = reponame,

  ref = 'main',  #  or a specific tagged release

  build_vignettes = FALSE,
  build_manual = FALSE,
  dependencies = TRUE, # to ensure it checks for the packages in Suggests not just Imports
  build = FALSE,
  upgrade = "never"
)
############################################ #

## get list of files found in EJAM root directory
all_files <- rsconnect::listDeploymentFiles(getwd())

## exclude certain subfolders from being searched for dependencies
deploy_files <- all_files[-c(

  grep('_pkgown.yml',   all_files),
  # .gitattributes  ?
  grep('.github/',      all_files),
  grep('.gitignore',    all_files),
  grep('.Rbuildignore', all_files),
  grep('.Rhistory',     all_files),
  # CITATION.cff ?
  # CONTRIBUTING.md ?
  # data
  grep('.arrow',        all_files),
  grep('data-raw/',     all_files),
  # DESCRIPTION ?
  grep('docs/',         all_files),
  grep('EJAM.rproj',    all_files),
  # grep('inst/',        all_files), # maybe not needed here since package gets installed?
  # LICENSE, LICENSE.md, logo.svg ?
  grep('man/',          all_files), # ? was not in original list of what to ignore
  # NAMESPACE ?
  grep('NEWS',         all_files),
  grep('pkgdown/',      all_files),
# R
  grep('README',           all_files),
  grep('shiny_bookmarks/', all_files),
  grep('tests/',           all_files),
  grep('vignettes/',       all_files),
  grep('www/',            all_files)
)
]

print(deploy_files)

## check dependency list
x <- rsconnect::appDependencies(appFiles = deploy_files)

print(dim(x)) # roughly 214

## update manifest.json file
rsconnect::writeManifest(appFiles = deploy_files)

cat("Now commit that updated manifest file, push to github,
    and if Posit Connect server is configured to deploy a shiny app from that repo and branch then it will detect the changes and redeploy
    or you can specify the manifest.json file when deploying using Posit Connect Cloud, for example. \n")
