
map_headernames_alias_list <- function() {

  list(
    # "friendly" was phased out as an alias because it was confusing here.
    rname = c("r", "rnames"),
    longname = c("long", "longnames", "full", "description"),
    shortlabel = c("short", "shortname", "shortnames", "shortlabels", "labels", "label"),
    acsname = c("acs", "acsnames"),
    csvname = c("csv", "csvnames"),
    ejscreen_indicator = c("ejscreen", "ejscreen_name", "ejscreen_current", "ejscreen_dataset", "app", "ejscreenapp", "webapp"),
    ejscreen_ftp_names = c("ejscreen_ftp", "ejscreen_ftp_name", "ftp", "ftpname"),
    ejscreen_apinames_old = c("api", "old_api"),
    ejam_apinames = c("ejam_api", "ejamapi", "new_api", "new_apiname"),
    `pctile.` = c("pctile", "uspctile"),
    bin. = c("bin", "mapbin"),
    text. = c("text", "maptext"),
    oldname = c("original", "old", "oldnames")
  )
}
#################################################################### #
