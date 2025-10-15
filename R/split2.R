
# split up into a vector of parts

split2 <- function(x, split = ",") {unlist(strsplit(x, split))}

unsplit <- function(x, split = ", ") {paste0(x, collapse = split)} # note space after comma is added


## example
#
# url9 = "https://cdxapps.epa.gov/cdx-enepa-II/public/action/eis/search/search?searchRecords=Search&searchCriteria.includeCoopAgencies=true&searchCriteria.endFRDate=06%2F30%2F2024&searchCriteria.startCommentLetterDate=&_csrf=10451669-6696-48fe-9cf3-3738171453be&searchCriteria.uniqueIdentificationNumber=&searchCriteria.endCommentLetterDate=&searchCriteria.title=&searchCritera.primaryStates=&searchCriteria.startFRDate=01%2F01%2F2024&searchCriteria.ceqNumber=&d-446779-e=1&6578706f7274=1"

# x = split2(url9, "&")

# cbind(x)

## [1,] "https://cdxapps.epa.gov/cdx-enepa-II/public/action/eis/search/search?searchRecords=Search"
## [2,] "searchCriteria.includeCoopAgencies=true"
## [3,] "searchCriteria.endFRDate=06%2F30%2F2024"
## [4,] "searchCriteria.startCommentLetterDate="
## [5,] "_csrf=10451669-6696-48fe-9cf3-3738171453be"
## [6,] "searchCriteria.uniqueIdentificationNumber="
## [7,] "searchCriteria.endCommentLetterDate="
## [8,] "searchCriteria.title="
## [9,] "searchCritera.primaryStates="
## [10,] "searchCriteria.startFRDate=01%2F01%2F2024"
## [11,] "searchCriteria.ceqNumber="
## [12,] "d-446779-e=1"
## [13,] "6578706f7274=1"

# all.equal(
#   url9,
#   unsplit(
#     split2(url9, "&"),
#     "&"
#   )
# )
