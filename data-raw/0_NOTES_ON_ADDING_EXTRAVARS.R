########## #
# "OTHER" INDICATORS WE WANT TO SEE IN OUTPUTS/RESULTS
# global_defaults_*.R define  default_extratable_list_of_sections

vars = as.vector(unlist(default_extratable_list_of_sections))

########## #
# INDICATORS ALREADY BEING CALCULATED AS RESULTS

out = ejamit(testpoints_10, radius = 2)
varsout = names(out$results_overall)

########## #
# INDICATORS MISSING -- NOT CALCULATED YET  - NEED FORMULA OR METADATA OR LISTS OF NAMES TO SHOW, UPDATES/FIXES

vars_missing = setdiff(vars, varsout)

vars_missing
#  "p_chinese" "p_korean"
#   "count.NPL" "count.TSDF" "num_waterdis"  "num_airpoll" "num_brownfield" "num_tri"
#   "num_school" "num_hospital"  "num_church"
# "yesno_tribal" "yesno_airnonatt" "yesno_impwaters" "yesno_cejstdis"   "yesno_iradis"
# "pctflood"  "pctfire"
# "yesno_houseburden"  "yesno_transdis"  "yesno_fooddesert"
# "pctnobroadband"  "pctnohealthinsurance"
# "nonmins"
# "count.ej.80up" "count.ej.80up.supp"
# "count.ej.80up2.eo" "count.ej.80up2.supp" "state.count.ej.80up" "state.count.ej.80up.supp"

########## #
# INDICATORS NOT IN DATASET blockgroupstats, so probably cannot calculate (with some exceptions)

vars_missing_fixable = intersect(vars_missing, names(blockgroupstats))
vars_missing_fixable

vars_missing_cannotfix = setdiff(vars_missing, names(blockgroupstats))
vars_missing_cannotfix

all.equal(
  sort(union(vars_missing_cannotfix, vars_missing_fixable)),
  sort(vars_missing)
) # TRUE


not_in_blockgroupstats <- c(
  'p_chinese', 'p_korean',
  'pctflood', 'pctfire',
  'nonmins',

  # 'count.ej.80up',      # in blockgroupstats but typically in outputs of ejamit as out$results_summarized$cols$Number.of.EJ.US.or.ST.at.above.threshold.of.80
  # 'count.ej.80up.supp', # in blockgroupstats but typically in outputs of ejamit as out$results_summarized$cols$Number.of.Supp.US.or.ST.at.above.threshold.of.80
  'count.ej.80up2.eo',
  'count.ej.80up2.supp',
  'state.count.ej.80up',
  'state.count.ej.80up.supp'
)
# out$results_summarized$cols$Number.of.EJ.US.or.ST.at.above.threshold.of.80
# out$results_summarized$cols$Number.of.Supp.US.or.ST.at.above.threshold.of.80

all.equal(sort(not_in_blockgroupstats) , sort(vars_missing_cannotfix))
# TRUE

#   not in blockgroupstats but calculated elsewhere, so they are in outputs:
c(
  'sitecount_avg',
  'sitecount_unique',
  'sitecount_max',
  'distance_min_avgperson',
  'distance_min'
)
########## #

## helper to check the map_headernames metadata about the missing ones

checkon = function(varnames) {

  x = EJAM:::get_global_defaults_or_user_options()
  default_extratable_list_of_sections = x$default_extratable_list_of_sections
  extravars = as.vector(unlist(default_extratable_list_of_sections))

  varsout = names(testoutput_ejamit_10pts_1miles$results_overall)

  vars_missing = setdiff(extravars, varsout)

  vars_missing_fixable = intersect(vars_missing, names(blockgroupstats))
  vars_missing_cannotfix = setdiff(vars_missing, names(blockgroupstats))

  if (missing(varnames)) {varnames = c(vars_missing_fixable, vars_missing_cannotfix)}
  print(
    cbind(
      varlist = varinfo(varnames, "varlist"),
      rname = varnames,
      in.bgstats = varnames %in% names(blockgroupstats),
      in.outputs.already = varnames %in% varsout,
      missing.fixable = varnames %in% vars_missing_fixable,
      missing.unfixable = varnames %in% vars_missing_cannotfix,
      calctype = EJAM:::calctype(  varnames),
      wt       = EJAM:::calcweight(varnames)
    )
  )
}

checkon()

#                         varlist       rname in.bgstats in.outputs.already missing.fixable missing.unfixable      calctype           wt

# pct_chinese    names_d_language pct_chinese      FALSE              FALSE           FALSE              TRUE       wtdmean lan_universe
# pct_korean     names_d_language  pct_korean      FALSE              FALSE           FALSE              TRUE       wtdmean lan_universe

# pctflood          names_climate    pctflood      FALSE              FALSE           FALSE              TRUE       wtdmean          pop
# pctfire           names_climate     pctfire      FALSE              FALSE           FALSE              TRUE       wtdmean          pop

# nonmins     names_d_other_count     nonmins      FALSE              FALSE           FALSE              TRUE sum of counts

