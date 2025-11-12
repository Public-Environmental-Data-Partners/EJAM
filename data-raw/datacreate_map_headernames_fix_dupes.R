# FIX DUPES IN map_headernames

# one big cause is that many vars are listed
# under both   "names_d_subgroups_avg" and "names_d_subgroups_nh_avg"


mh <- map_headernames
dropcols = c('names_friendly', 'csv_description', 'acs_description', 'api_description', 'oldname', 'oldname_is_what', 'reportlabel', 'apisection', 'sort_within_varlistEJSCREENREPORT', 'topic_root_term', 'sortvarlistEJSCREENREPORT', 'sort_within_varlistEJSCREENREPORT', 'sort_within_varlist', 'csvname2.2', 'csvname', 'acs2017_2021v2.2', 'jsondoc_zone', 'jsondoc_shortzone', 'jsondoc_sort_zone', 'longmatch', 'csv_descriptions_name', 'csv_example', 'api_example', 'ejscreenreport', 'ejscreensort', 'shortmatch', 'pct_as_fraction_ejscreenit', 'pct_as_fraction_ejamit', 'pct_as_fraction_blockgroupstats', 'units', 'raw_pctile_avg_basedonrname', 'errornote', 'agree', 'api_synonym')
mh = mh[, !(names(mh) %in% dropcols)]

x <- mh[mh$rname %in% mh$rname[(duplicated(mh$rname))], ]
x <- x[order(x$rname), ]
x$varlist <- varinfo(x$rname)$varlist
#dput(unique(x$varlist))
dupes_in_mh_varlists <- unique(x$varlist)
#dupes_in_maphead_varlists = c("names_d_subgroups_avg", "names_d_subgroups_count", "names_d_subgroups",
#                              "names_d_subgroups_pctile", "names_d_subgroups_ratio_to_avg",
#                              "names_d_subgroups_ratio_to_state_avg", "names_d_subgroups_state_avg",
#                              "names_d_subgroups_state_pctile")
dupes_in_mh_varnames <- sapply(dupes_in_mh_varlists, get)

dupes_in_mh_varlists

x


inconsistent = function(varname = "hisp", x = map_headernames) {
  v1 <- t(x[x$rname == varname, ])
  print(varname)
  v1[rownames(v1) %in% varname | apply(v1, 1, function(z)  length(unique(z)) > 1 ) , ]
}

inconsistent(dupes_in_mh_varnames[1], x = x)


# formulas_ejscreen_acs[formulas_ejscreen_acs$in_mh, -3]
