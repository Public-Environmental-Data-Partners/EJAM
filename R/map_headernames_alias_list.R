
map_headernames_alias_list <- function() {

  list(
    # "friendly" was phased out as an alias because it was confusing here.
    rname = c("r", "rnames"),
    longname = c("long", "longnames", "full", "description"),
    shortlabel = c("short", "shortname", "shortnames", "shortlabels", "labels", "label"),
    acsname = c("acs", "acsnames"),
    apiname = c("api", "apinames"),
    csvname = c("csv", "csvnames"),
    ejscreen_names = c("ejscreen", "ejscreen_name", "ejscreen_current", "ejscreen_dataset"),
    ejscreen_ftp_names = c("ejscreen_ftp", "ejscreen_ftp_name", "ftp", "ftpname"),
    ejscreen_apinames_old = c("ejscreen_api_old", "old_ejscreen_api", "old_api", "old_apiname"),
    ejam_apinames = c("ejam_api", "ejamapi", "new_api", "new_apiname"),
    ejscreen_csv = c("ejcsv", "ejscreen_csvname", "ejscreencsv"),
    ejscreen_gdb = c("gdb", "gdbfield", "ejscreengdb"),
    ejscreen_app = c("app", "ejscreenapp", "webapp"),
    ejscreen_api = c("ejapi", "ejscreenapi"),
    ejscreen_pctile = c("ejpctile", "ejscreenpctile"),
    ejscreen_bin = c("ejbin", "ejscreenbin"),
    ejscreen_text = c("ejtext", "ejscreentext"),
    oldname = c("original", "old", "oldnames")
  )
}
#################################################################### #
