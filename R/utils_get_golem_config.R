
#' Read App Config
#' 
#' Utility from golem package. Checks golem-config.yml
#'
#' @param value Value to retrieve from the config file.
#' @param config GOLEM_CONFIG_ACTIVE value. If unset, R_CONFIG_ACTIVE.
#' If unset, "default".
#' @param use_parent Logical, scan the parent directory for config file.
#' @param file Location of the config file
#'
#' @noRd
#' 
get_golem_config <- function(
  value,
  config = Sys.getenv(
    "GOLEM_CONFIG_ACTIVE",
    Sys.getenv(
      "R_CONFIG_ACTIVE",
      "default"
    )
  ),
  use_parent = TRUE,
  # Modify this if your config file is somewhere else
  file = app_sys("golem-config.yml") 
  #  source/EJAM/inst/filename = installed/EJAM/filename
) {
  config::get(
    value = value,
    config = config,
    file = file,
    use_parent = use_parent
  )
}
# 
#   config file to use, like "golem-config.yml"   
# can be found in EJAM/inst/ referred to as if in root 
# can use  config :: get  to read whatever value you asked about 
 # you can do  config::get("app_prod", file="golem-config.yaml") 
