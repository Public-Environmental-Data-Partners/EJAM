
##  will NOT actually use this since it will now be done within middle of datacreate_usastats.R since it has to use D/E pctiles and then bgej is used to finish creating usastats,statestats with EJ pctiles!
#
# ############################################################## #
# # EJ INDEXES -  bgej is needed also ####
#
# message("before doing this, must have done update of blockgroupstats and also usastats and statestats !!")
#
# # can calculate these using calc_bgej() but that requires having made usastats and statestats for percentiles lookups, etc.
# # and can specify colnames of envt indicators here if they change from defaults in this function
#
# bgej <- calc_bgej(bgstats = blockgroupstats) # or use new blockgroupstats
#
# # This file is not stored in the package. It goes in the ejamdata repository. and probably as .arrow not .rda
# save(bgej, file = file.path(mydir, "bgej.rda"))
# message("saved interim file in ", mydir)
# ############################################################## #
