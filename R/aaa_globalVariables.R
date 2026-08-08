# to silence check() NOTE about  Undefined global functions or variables

########################################### #
########################################### #

## probably belong in globalVariables:

########################################### #
########################################### #
# from_varlist_add
{
  from_varlist_add =  sort(  c(
    # dput(sort(unique(map_headernames$varlist[nchar(map_headernames$varlist) > 0])))

    "custom", "ejscreen_arcgis_service_field", "ejscreen_schema_extra",
    "names_age", "names_age_avg", "names_age_count", "names_age_pctile",
    "names_age_ratio_to_avg", "names_age_ratio_to_state_avg",
    "names_age_state_avg", "names_age_state_pctile", "names_climate",
    "names_climate_avg", "names_climate_pctile", "names_climate_ratio_to_avg",
    "names_climate_ratio_to_state_avg", "names_climate_state_avg",
    "names_climate_state_pctile", "names_community", "names_community_avg",
    "names_community_count", "names_community_pctile",
    "names_community_ratio_to_avg", "names_community_ratio_to_state_avg",
    "names_community_state_avg", "names_community_state_pctile", "names_countabove",
    "names_criticalservice", "names_criticalservice_avg", "names_criticalservice_count",
    "names_criticalservice_pctile", "names_criticalservice_ratio_to_avg",
    "names_criticalservice_ratio_to_state_avg", "names_criticalservice_state_avg",
    "names_criticalservice_state_pctile", "names_d", "names_d_avg",
    "names_d_count", "names_d_demogindexstate", "names_d_extra",
    "names_d_extra_avg", "names_d_extra_count", "names_d_extra_pctile",
    "names_d_extra_ratio_to_avg", "names_d_extra_ratio_to_state_avg",
    "names_d_extra_state_avg", "names_d_extra_state_pctile",
    "names_d_language", "names_d_language_avg", "names_d_language_count",
    "names_d_language_pctile", "names_d_language_ratio_to_avg",
    "names_d_language_ratio_to_state_avg", "names_d_language_state_avg",
    "names_d_language_state_pctile", "names_d_languageli",
    "names_d_languageli_avg", "names_d_languageli_count",
    "names_d_languageli_pctile", "names_d_languageli_ratio_to_avg",
    "names_d_languageli_ratio_to_state_avg", "names_d_languageli_state_avg",
    "names_d_languageli_state_pctile", "names_d_other_count",
    "names_d_pctile", "names_d_ratio_to_avg", "names_d_ratio_to_state_avg",
    "names_d_state_avg", "names_d_state_pctile", "names_d_subgroups",
    "names_d_subgroups_alone", "names_d_subgroups_alone_avg", "names_d_subgroups_alone_count",
    "names_d_subgroups_alone_pctile", "names_d_subgroups_alone_ratio_to_avg",
    "names_d_subgroups_alone_ratio_to_state_avg", "names_d_subgroups_alone_state_avg",
    "names_d_subgroups_alone_state_pctile", "names_d_subgroups_avg",
    "names_d_subgroups_count", "names_d_subgroups_nh", "names_d_subgroups_nh_avg",
    "names_d_subgroups_nh_count", "names_d_subgroups_nh_pctile",
    "names_d_subgroups_nh_ratio_to_avg", "names_d_subgroups_nh_ratio_to_state_avg",
    "names_d_subgroups_nh_state_avg", "names_d_subgroups_nh_state_pctile",
    "names_d_subgroups_pctile", "names_d_subgroups_ratio_to_avg",
    "names_d_subgroups_ratio_to_state_avg", "names_d_subgroups_state_avg",
    "names_d_subgroups_state_pctile", "names_e", "names_e_avg", "names_e_other",
    "names_e_pctile", "names_e_ratio_to_avg", "names_e_ratio_to_state_avg",
    "names_e_state_avg", "names_e_state_pctile", "names_ej", "names_ej_pctile",
    "names_ej_state", "names_ej_state_pctile", "names_ej_supp", "names_ej_supp_pctile",
    "names_ej_supp_state", "names_ej_supp_state_pctile", "names_featuresinarea",
    "names_flag", "names_geo", "names_health", "names_health_avg",
    "names_health_count", "names_health_pctile", "names_health_ratio_to_avg",
    "names_health_ratio_to_state_avg", "names_health_state_avg",
    "names_health_state_pctile", "names_misc", "names_sitesinarea"
  )
  )
}
########################################### #
# from_datasets
{
  from_datasets  <- c(

    # dput(EJAM:::pkg_data()$Item)
    # Get more info with pkg_data(simple = FALSE)
    #
    # ignoring sortbysize because simple=TRUE

    "NAICS", "SIC", "avg.in.us", "bg_cenpop2020", "bgpts", "blockgroupstats",
    "censusplaces", "counties_shapefile", "custom", "ejamdata_version", "ejampackages",
    "epa_programs", "epa_programs_defined", "formulas_ejscreen_acs",
    "formulas_ejscreen_acs_disability",
    "formulas_ejscreen_demog_index", "frsprogramcodes", "high_pctiles_tied_with_min",
    "islandareas", "lat_alias", "lon_alias", "mact_table", "map_headernames",
    "meters_per_mile", "modelDoaggregate", "modelEjamit", "modelEjamitByAnalysisType",
    "naics_counts", "naicstable", "names_age", "names_age_avg",
    "names_age_count", "names_age_pctile", "names_age_ratio_to_avg",
    "names_age_ratio_to_state_avg", "names_age_state_avg",
    "names_age_state_pctile", "names_all", "names_all_r", "names_climate",
    "names_climate_avg", "names_climate_pctile", "names_climate_ratio_to_avg",
    "names_climate_ratio_to_state_avg", "names_climate_state_avg",
    "names_climate_state_pctile", "names_community", "names_community_avg",
    "names_community_count", "names_community_pctile",
    "names_community_ratio_to_avg", "names_community_ratio_to_state_avg",
    "names_community_state_avg", "names_community_state_pctile",
    "names_countabove", "names_criticalservice", "names_criticalservice_avg",
    "names_criticalservice_pctile", "names_criticalservice_ratio_to_avg",
    "names_criticalservice_ratio_to_state_avg", "names_criticalservice_state_avg",
    "names_criticalservice_state_pctile", "names_d", "names_d_avg",
    "names_d_count", "names_d_demogindexstate", "names_d_extra",
    "names_d_extra_avg", "names_d_extra_count", "names_d_extra_pctile",
    "names_d_extra_ratio_to_avg", "names_d_extra_ratio_to_state_avg",
    "names_d_extra_state_avg", "names_d_extra_state_pctile",
    "names_d_language", "names_d_language_avg", "names_d_language_count",
    "names_d_language_pctile", "names_d_language_ratio_to_avg",
    "names_d_language_ratio_to_state_avg", "names_d_language_state_avg",
    "names_d_language_state_pctile", "names_d_languageli",
    "names_d_languageli_avg", "names_d_languageli_count",
    "names_d_languageli_pctile", "names_d_languageli_ratio_to_avg",
    "names_d_languageli_ratio_to_state_avg", "names_d_languageli_state_avg",
    "names_d_languageli_state_pctile", "names_d_other_count",
    "names_d_pctile", "names_d_ratio_to_avg", "names_d_ratio_to_state_avg",
    "names_d_state_avg", "names_d_state_pctile", "names_d_subgroups",
    "names_d_subgroups_alone", "names_d_subgroups_alone_avg", "names_d_subgroups_alone_count",
    "names_d_subgroups_alone_pctile", "names_d_subgroups_alone_ratio_to_avg",
    "names_d_subgroups_alone_ratio_to_state_avg", "names_d_subgroups_alone_state_avg",
    "names_d_subgroups_alone_state_pctile", "names_d_subgroups_avg",
    "names_d_subgroups_count", "names_d_subgroups_nh", "names_d_subgroups_nh_avg",
    "names_d_subgroups_nh_count", "names_d_subgroups_nh_pctile",
    "names_d_subgroups_nh_ratio_to_avg", "names_d_subgroups_nh_ratio_to_state_avg",
    "names_d_subgroups_nh_state_avg", "names_d_subgroups_nh_state_pctile",
    "names_d_subgroups_pctile", "names_d_subgroups_ratio_to_avg",
    "names_d_subgroups_ratio_to_state_avg", "names_d_subgroups_state_avg",
    "names_d_subgroups_state_pctile", "names_e", "names_e_avg", "names_e_other",
    "names_e_pctile", "names_e_ratio_to_avg", "names_e_ratio_to_state_avg",
    "names_e_state_avg", "names_e_state_pctile", "names_ej", "names_ej_pctile",
    "names_ej_state", "names_ej_state_pctile", "names_ej_supp", "names_ej_supp_pctile",
    "names_ej_supp_state", "names_ej_supp_state_pctile", "names_featuresinarea",
    "names_flag", "names_geo", "names_health", "names_health_avg",
    "names_health_count", "names_health_pctile", "names_health_ratio_to_avg",
    "names_health_ratio_to_state_avg", "names_health_state_avg",
    "names_health_state_pctile", "names_misc", "names_pct_as_fraction_blockgroupstats",
    "names_pct_as_fraction_ejamit", "names_sitesinarea", "names_these",
    "names_these_avg", "names_these_ratio_to_avg", "names_these_ratio_to_state_avg",
    "names_these_state_avg", "names_wts", "namez", "sictable", "stateinfo",
    "stateinfo2", "states_shapefile", "statestats", "tables_ejscreen_acs",
    "testinput_address_2", "testinput_address_9", "testinput_address_parts",
    "testinput_address_table", "testinput_address_table_9", "testinput_address_table_goodnames",
    "testinput_address_table_withfull", "testinput_fips_blockgroups",
    "testinput_fips_cities", "testinput_fips_counties", "testinput_fips_mix",
    "testinput_fips_states", "testinput_fips_tracts", "testinput_mact",
    "testinput_naics", "testinput_program_name", "testinput_program_sys_id",
    "testinput_regid", "testinput_registry_id", "testinput_shapes_2",
    "testinput_sic", "testoutput_doaggregate_1000pts_1miles", "testoutput_doaggregate_100pts_1miles",
    "testoutput_doaggregate_10pts_1miles", "testoutput_ejamit_1000pts_1miles",
    "testoutput_ejamit_100pts_1miles", "testoutput_ejamit_10pts_1miles",
    "testoutput_ejamit_fips_cities", "testoutput_ejamit_fips_counties",
    "testoutput_ejamit_shapes_2", "testoutput_getblocksnearby_1000pts_1miles",
    "testoutput_getblocksnearby_100pts_1miles", "testoutput_getblocksnearby_10pts_1miles",
    "testpoints_10", "testpoints_100", "testpoints_1000", "testpoints_10000",
    "testpoints_100_dt", "testpoints_5", "testpoints_50", "testpoints_500",
    "testpoints_bad", "testpoints_overlap3", "testshapes_2", "usastats",
    "x_anyother"
  )
}
from_datasets_add = sort(setdiff(from_datasets, from_varlist_add))
########################################### #
# from_check_var
{
  from_check_var =  c(
    "..Rnames", "..acs_vars", "..allvarnames", "..availvars",
    "..bg_join_cols_bysite", "..bg_join_cols_overall",
    "..calculatedcols_inbgstats", "..cnames", "..colorvarname", "..cols",
    "..cols_kept", "..cols_returned", "..colsneeded", "..column_names",
    "..countcols_inbgstats", "..demogvarname", "..ejnames_raw",
    "..enviro_vars", "..fallback_cols", "..frompoints_id_colname",
    "..mycolname", "..myindicators", "..myvar", "..myvars_state_ej",
    "..myvars_to_use", "..myvars_us_ej", "..names_d", "..names_d_avg",
    "..names_d_pctile", "..names_d_ratio_to_avg",
    "..names_d_ratio_to_state_avg", "..names_d_state_avg",
    "..names_d_state_pctile", "..names_d_subgroups_ratio_to_avg",
    "..names_e", "..names_e_avg", "..names_e_pctile",
    "..names_e_ratio_to_avg", "..names_e_ratio_to_state_avg",
    "..names_e_state_avg", "..names_e_state_pctile", "..names_these",
    "..names_these_avg", "..names_these_ratio_to_avg",
    "..names_these_ratio_to_state_avg", "..names_these_state_avg",
    "..neededvars", "..otheravailable", "..output_vars",
    "..pctvars", "..popmeancols_inbgstats", "..rationames", "..score_colname",
    "..scorewts_colname", "..sharednames", "..topoints_id_colname",
    "..usefulcolumns", "..v", "..varname", "..vars", "..vnames_ST",
    "..vnames_e", "AIR_PROGRAM_CODE_SUBPARTS", "BLOCK_X", "BLOCK_Y",
    "BLOCK_Z", "Color", "Countyname", "Depends", "FAC_X", "FAC_Y",
    "FAC_Z", "FIPS", "GEOID", "Group", "LAT_RAD", "LONG_RAD",
    "Locations", "N", "NAME", "OBJECTID", "PGM_SYS_ACRNMS",
    "PRIMARY_NAME", "Package", "Priority", "REGISTRY_ID", "Ratio",
    "V1", "aboutpage_texts", "acs_bgfips", "acs_tractfips",
    "acs_version_global", "analyzed_pop", "arcgis_address", "area", "area_fallback",
    "arealand", "areawater", "avg.pctdisability", "avg.pctlingiso",
    "avg.pctlowinc", "avg.pctlowlifex", "avg.pctlths", "avg.pctmin",
    "bg_suffix", "bgej", "bgid2fips", "bgid2fips_arrow", "bgpop",
    "bgwt", "block_radius_miles_round_temp", "blockcount_near_site",
    "blockfips", "blockid2fips", "blockid2fips_arrow", "blocklat",
    "blocklon", "blockpoints", "blockpop", "blockscore", "blockwts",
    "color", "coslat_x_earth", "count_city_matched",
    "count_city_state_matched", "countyfips", "countyname",
    "countyname_ST", "custom_index", "disab_universe", "disability",
    "distance", "distance.km", "distance_avg", "distance_min",
    "distance_min_avgperson", "distance_unadjusted", "drinking",
    "ejam_uniq_id", "ejscreen_indicator", "ejscreen_version_global", "eparegion", "estimate",
    "extratable_stuff", "failed", "failed_byfile", "failed_bygroup",
    "fips", "flagged", "flagged_byfile", "flagged_bygroup", "frs",
    "frs_arrow", "frs_by_mact", "frs_by_mact_arrow", "frs_by_naics",
    "frs_by_programid", "frs_by_programid_arrow", "frs_by_sic",
    "frs_index", "global_defaults_package", "global_defaults_shiny",
    "global_defaults_shiny_public", "group", "healthinsurance_universe",
    "help_texts", "html_fmts", "i", "i.ST", "i.arealand", "i.areawater",
    "i.bgfips", "i.bgid", "i.pop", "id_among_subset", "id_overall",
    "in_how_many_states", "indicator", "indicator_label", "invalid_msg",
    "kind", "lat_RAD", "literalvarname", "localtree", "logfilename",
    "lon_RAD", "long", "lowlifex", "meters_per_mile", "minutes_bygroup",
    "moe", "name", "nohealthinsurance", "oldname", "overall", "passed",
    "pctdisability", "pctdisability_rate", "pctlingiso", "pctlowinc",
    "pctunemployed", "PCTILE", "i.pctunemployed",
    "pctlths", "pctmin", "pctnohealthinsurance", "pctownedunits",
    "placename", "pointid", "pop2020", "pop_nearby", "program",
    "proximityscore", "quaddata", "query", "radius", "radius.miles",
    "radius_donut_lower_edge", "ratio", "rname", "rnames",
    "sanitize_functions", "scores", "scorewts", "sd.pctdisability",
    "sd.pctlingiso", "sd.pctlowinc", "sd.pctlowlifex", "sd.pctlths",
    "sd.pctmin", "seconds_byfile", "seconds_byfile_predicted",
    "seconds_bygroup", "seconds_extra", "sitecount", "sitecount_avg",
    "sitecount_max", "sitepoints", "st1", "state_avg", "state_pctile",
    "statefips", "statename", "subpart", "testgroup", "total",
    "tract_disab_universe", "tract_disability",
    "tract_healthinsurance_universe", "tract_nohealthinsurance",
    "tract_pctdisability_rate", "tractfips", "tractpop", "untested_cant",
    "untested_skipped", "unsupported_block_rows", "unsupported_blockgroups",
    "unsupported_blocks", "urlx", "usa_summary", "use_unadjusted_distance",
    "valid", "value", "warned", "wtdmean_within", "x", "x_hi", "x_low",
    "x_val", "y_val", "z_hi", "z_low", "z_val"
  )
}
from_check_var_add = sort(setdiff(from_check_var, union(from_varlist_add, from_datasets_add)))
########################################### #
# from_islandareas_pipeline
{
  from_islandareas_pipeline = c(
    "aa", "age", "age25up", "aiana", "ba", "block", "block group",
    "broadband_universe",
    "built1940to1949", "built1950to1959", "builtpre1940", "builtunits",
    "county", "female", "GEO_ID", "hisp", "ISLANDAREAS_AA",
    "ISLANDAREAS_AGE25UP", "ISLANDAREAS_AIANA", "ISLANDAREAS_BA",
    "ISLANDAREAS_BROADBAND_UNIVERSE", "ISLANDAREAS_BROADBAND_WITH",
    "ISLANDAREAS_BUILTUNITS", "ISLANDAREAS_DISAB_UNIVERSE",
    "ISLANDAREAS_DISABILITY", "ISLANDAREAS_FEMALE",
    "ISLANDAREAS_HEALTH_UNIVERSE", "ISLANDAREAS_HH_POOR",
    "ISLANDAREAS_HH_POV_UNIVERSE", "ISLANDAREAS_HISP",
    "ISLANDAREAS_LABORFORCE", "ISLANDAREAS_LAN_ENGLISH",
    "ISLANDAREAS_LAN_UNIVERSE", "ISLANDAREAS_LINGISO", "ISLANDAREAS_LTHS",
    "ISLANDAREAS_MALE", "ISLANDAREAS_MULTI", "ISLANDAREAS_NHAA",
    "ISLANDAREAS_NHAIANA", "ISLANDAREAS_NHBA", "ISLANDAREAS_NHMULTI",
    "ISLANDAREAS_NHNHPIA", "ISLANDAREAS_NHOTHERALONE",
    "ISLANDAREAS_NHPIA", "ISLANDAREAS_NHWA", "ISLANDAREAS_NOHEALTH",
    "ISLANDAREAS_NONHISP", "ISLANDAREAS_OCCUPIEDUNITS",
    "ISLANDAREAS_OTHERALONE", "ISLANDAREAS_OVER64",
    "ISLANDAREAS_OWNEDUNITS", "ISLANDAREAS_PERCAPINCOME",
    "ISLANDAREAS_POP", "ISLANDAREAS_POV2PLUS", "ISLANDAREAS_POVKNOWN",
    "ISLANDAREAS_PRE1960", "islandareas_source", "ISLANDAREAS_UNDER18",
    "ISLANDAREAS_UNDER5", "ISLANDAREAS_UNEMPLOYED",
    "ISLANDAREAS_UNEMPLOYEDBASE", "ISLANDAREAS_WA", "label",
    "laborforce_universe", "lan_english", "lan_nonenglish", "lan_universe",
    "lingiso", "lowinc", "lths", "male", "mins", "multi", "nhaa",
    "nhaiana", "nhba", "nhmulti", "nhnhpia", "nhotheralone", "nhpia",
    "nhwa", "nobroadband", "nonhisp", "nonmins", "occupiedunits",
    "otheralone", "over17", "over64", "ownedunits", "pctaa", "pctaiana",
    "pctba", "pctfemale", "pcthisp", "pctlan_english",
    "pctlan_nonenglish", "pctmale", "pctmulti", "pctnhaa", "pctnhaiana",
    "pctnhba", "pctnhmulti", "pctnhnhpia", "pctnhotheralone", "pctnhpia",
    "pctnhwa", "pctnobroadband", "pctotheralone", "pctover17", "pctover64",
    "pctpoor", "pctpre1960", "pctunder18", "pctunder5", "pctwa",
    "percapincome", "poor", "pov2plus", "poverty_household_universe",
    "povknownratio", "pre1960", "state", "SUMLEVEL", "tract", "under18",
    "under5", "unemployed", "unemployedbase", "wa"
  )
}
from_islandareas_pipeline_add = sort(setdiff(
  from_islandareas_pipeline,
  union(from_varlist_add, union(from_datasets_add, from_check_var_add))
))
########################################### #
# from_misc
{
  from_misc =   c(
    ".",
    "ST",
    "REGION",
    "bgfips",
    "pop",
    "lat",
    "lon",
    "meters_per_mile",
    "compare_id",
    "differing_rows",
    "bgfips",
    "blockid", "bgid", "blockwt", "block_radius_miles",
    "lat",     "lon"
  )
}
from_misc_add = sort(setdiff(from_misc, union(from_varlist_add, union(from_datasets_add, from_check_var_add))))
########################################### #
########################################### #

########################################### #
# Names R CMD check reported as "no visible binding for global variable".
# All are column names used in data.table / dplyr non-standard evaluation, so
# they are not really undefined - the checker just cannot see them. Grouped
# here, rather than mixed into the lists above, so it stays obvious that they
# came from a specific check run and can be re-derived from one.
#
# stat_lorenz was in this NOTE too but is deliberately NOT listed: it is a
# function from gglorenz, not a column, so listing it would have hidden a
# genuinely undeclared dependency. It is now called as gglorenz::stat_lorenz()
# with gglorenz added to Suggests.
from_rcmdcheck_add <- c(
  "..display_cols", "CNTY_NAME", "STATE_NAME", "ST_ABBREV", "bysite",
  "diff_gt_tolerance", "diff_gt_tolerance_non_island", "difference_stage",
  "difference_stage_order", "differing_rows_non_island", "intptlat", "intptlon",
  "max_rel_diff", "max_rel_diff_non_island", "max_rel_diff_non_island_pct",
  "max_rel_diff_pct", "mean_rel_diff", "mean_rel_diff_non_island",
  "mean_rel_diff_non_island_pct", "mean_rel_diff_pct", "na_mismatch",
  "na_mismatch_non_island", "site_fips", "varlist"
)
########################################### #

if (getRversion() >= "2.15.1") {
  utils::globalVariables(
    sort(
      unique(
        c(
          from_misc_add,
          from_varlist_add,
          from_datasets_add,
          from_check_var_add,
          from_islandareas_pipeline_add,
          from_rcmdcheck_add
        )
      )
    )
  )
}
########################################### #
#
# cbind(from_misc_add)
# cbind(from_varlist_add)
# cbind(from_datasets_add)
# cbind(from_check_var_add)

# cbind(from_misc_add)

# from_misc_add
# [1,] "bgfips"
# [2,] "bgid"
# [3,] "block_radius_miles"
# [4,] "blockid"
# [5,] "blockwt"
# [6,] "lat"
# [7,] "lon"
# [8,] "pop"
# [9,] "REGION"
# [10,] "ST"


# > cbind(from_varlist_add)

# from_varlist_add


# [1,] "custom"
# [2,] "ejscreen_arcgis_service_field"
# [3,] "ejscreen_schema_extra"
# [4,] "names_age"
# [5,] "names_age_count"
# [6,] "names_climate"
# [7,] "names_climate_avg"
# [8,] "names_climate_pctile"
# [9,] "names_climate_state_avg"
# [10,] "names_climate_state_pctile"
# [11,] "names_community"
# [12,] "names_community_count"
# [13,] "names_countabove"
# [14,] "names_criticalservice"
# [15,] "names_criticalservice_avg"
# [16,] "names_criticalservice_count"
# [17,] "names_criticalservice_pctile"
# [18,] "names_criticalservice_state_avg"
# [19,] "names_criticalservice_state_pctile"
# [20,] "names_d"
# [21,] "names_d_avg"
# [22,] "names_d_count"
# [23,] "names_d_demogindexstate"
# [24,] "names_d_extra"
# [25,] "names_d_extra_count"
# [26,] "names_d_language"
# [27,] "names_d_language_count"
# [28,] "names_d_languageli"
# [29,] "names_d_languageli_count"
# [30,] "names_d_other_count"
# [31,] "names_d_pctile"
# [32,] "names_d_ratio_to_avg"
# [33,] "names_d_ratio_to_state_avg"
# [34,] "names_d_state_avg"
# [35,] "names_d_state_pctile"
# [36,] "names_d_subgroups"
# [37,] "names_d_subgroups_alone"
# [38,] "names_d_subgroups_alone_avg"
# [39,] "names_d_subgroups_alone_count"
# [40,] "names_d_subgroups_alone_pctile"
# [41,] "names_d_subgroups_alone_ratio_to_avg"
# [42,] "names_d_subgroups_alone_ratio_to_state_avg"
# [43,] "names_d_subgroups_alone_state_avg"
# [44,] "names_d_subgroups_alone_state_pctile"
# [45,] "names_d_subgroups_avg"
# [46,] "names_d_subgroups_count"
# [47,] "names_d_subgroups_nh"
# [48,] "names_d_subgroups_nh_avg"
# [49,] "names_d_subgroups_nh_count"
# [50,] "names_d_subgroups_nh_pctile"
# [51,] "names_d_subgroups_nh_ratio_to_avg"
# [52,] "names_d_subgroups_nh_ratio_to_state_avg"
# [53,] "names_d_subgroups_nh_state_avg"
# [54,] "names_d_subgroups_nh_state_pctile"
# [55,] "names_d_subgroups_pctile"
# [56,] "names_d_subgroups_ratio_to_avg"
# [57,] "names_d_subgroups_ratio_to_state_avg"
# [58,] "names_d_subgroups_state_avg"
# [59,] "names_d_subgroups_state_pctile"
# [60,] "names_e"
# [61,] "names_e_avg"
# [62,] "names_e_other"
# [63,] "names_e_pctile"
# [64,] "names_e_ratio_to_avg"
# [65,] "names_e_ratio_to_state_avg"
# [66,] "names_e_state_avg"
# [67,] "names_e_state_pctile"
# [68,] "names_ej"
# [69,] "names_ej_pctile"
# [70,] "names_ej_state"
# [71,] "names_ej_state_pctile"
# [72,] "names_ej_supp"
# [73,] "names_ej_supp_pctile"
# [74,] "names_ej_supp_state"
# [75,] "names_ej_supp_state_pctile"
# [76,] "names_featuresinarea"
# [77,] "names_flag"
# [78,] "names_geo"
# [79,] "names_health"
# [80,] "names_health_avg"
# [81,] "names_health_count"
# [82,] "names_health_pctile"
# [83,] "names_health_ratio_to_avg"
# [84,] "names_health_ratio_to_state_avg"
# [85,] "names_health_state_avg"
# [86,] "names_health_state_pctile"
# [87,] "names_misc"
# [88,] "names_sitesinarea"

# > cbind(from_datasets_add)

# from_datasets_add

# [1,] "avg.in.us"
# [2,] "bg_cenpop2020"
# [3,] "bgpts"
# [4,] "blockgroupstats"
# [5,] "censusplaces"
# [6,] "ejamdata_version"
# [7,] "ejampackages"
# [8,] "epa_programs"
# [9,] "epa_programs_defined"
# [10,] "formulas_ejscreen_acs"
# [11,] "formulas_ejscreen_acs_disability"
# [12,] "formulas_ejscreen_demog_index"
# [13,] "frsprogramcodes"
# [14,] "high_pctiles_tied_with_min"
# [17,] "islandareas"
# [18,] "lat_alias"
# [19,] "lon_alias"
# [20,] "mact_table"
# [21,] "map_headernames"
# [22,] "meters_per_mile"
# [23,] "modelDoaggregate"
# [24,] "modelEjamit"
# [25,] "modelEjamitByAnalysisType"
# [26,] "NAICS"
# [27,] "naics_counts"
# [28,] "naicstable"
# [29,] "names_all"
# [30,] "names_all_r"
# [31,] "names_pct_as_fraction_blockgroupstats"
# [32,] "names_pct_as_fraction_ejamit"
# [33,] "names_these"
# [34,] "names_these_avg"
# [35,] "names_these_ratio_to_avg"
# [36,] "names_these_ratio_to_state_avg"
# [37,] "names_these_state_avg"
# [38,] "names_wts"
# [39,] "namez"
# [40,] "SIC"
# [41,] "sictable"
# [42,] "stateinfo"
# [43,] "stateinfo2"
# [44,] "states_shapefile"
# [45,] "statestats"
# [46,] "tables_ejscreen_acs"
# [47,] "testinput_address_2"
# [48,] "testinput_address_9"
# [49,] "testinput_address_parts"
# [50,] "testinput_address_table"
# [51,] "testinput_address_table_9"
# [52,] "testinput_address_table_goodnames"
# [53,] "testinput_address_table_withfull"
# [54,] "testinput_fips_blockgroups"
# [55,] "testinput_fips_cities"
# [56,] "testinput_fips_counties"
# [57,] "testinput_fips_mix"
# [58,] "testinput_fips_states"
# [59,] "testinput_fips_tracts"
# [60,] "testinput_mact"
# [61,] "testinput_naics"
# [62,] "testinput_program_name"
# [63,] "testinput_program_sys_id"
# [64,] "testinput_regid"
# [65,] "testinput_registry_id"
# [66,] "testinput_shapes_2"
# [67,] "testinput_sic"
# [68,] "testoutput_doaggregate_1000pts_1miles"
# [69,] "testoutput_doaggregate_100pts_1miles"
# [70,] "testoutput_doaggregate_10pts_1miles"
# [71,] "testoutput_ejamit_1000pts_1miles"
# [72,] "testoutput_ejamit_100pts_1miles"
# [73,] "testoutput_ejamit_10pts_1miles"
# [74,] "testoutput_ejamit_fips_cities"
# [75,] "testoutput_ejamit_fips_counties"
# [76,] "testoutput_ejamit_shapes_2"
# [77,] "testoutput_getblocksnearby_1000pts_1miles"
# [78,] "testoutput_getblocksnearby_100pts_1miles"
# [79,] "testoutput_getblocksnearby_10pts_1miles"
# [80,] "testpoints_10"
# [81,] "testpoints_100"
# [82,] "testpoints_100_dt"
# [83,] "testpoints_1000"
# [84,] "testpoints_10000"
# [85,] "testpoints_5"
# [86,] "testpoints_50"
# [87,] "testpoints_500"
# [88,] "testpoints_bad"
# [89,] "testpoints_overlap3"
# [90,] "testshapes_2"
# [91,] "usastats"
# [92,] "x_anyother"


# > cbind(from_check_var_add)


# from_check_var_add


# [1,] "..acs_vars"
# [2,] "..allvarnames"
# [3,] "..availvars"
# [4,] "..bg_join_cols_bysite"
# [5,] "..bg_join_cols_overall"
# [6,] "..calculatedcols_inbgstats"
# [7,] "..cnames"
# [8,] "..colorvarname"
# [9,] "..cols"
# [10,] "..cols_kept"
# [11,] "..cols_returned"
# [12,] "..colsneeded"
# [13,] "..column_names"
# [14,] "..countcols_inbgstats"
# [15,] "..demogvarname"
# [16,] "..ejnames_raw"
# [17,] "..enviro_vars"
# [18,] "..fallback_cols"
# [19,] "..frompoints_id_colname"
# [20,] "..mycolname"
# [21,] "..myindicators"
# [22,] "..myvar"
# [23,] "..myvars_state_ej"
# [24,] "..myvars_to_use"
# [25,] "..myvars_us_ej"
# [26,] "..names_d"
# [27,] "..names_d_avg"
# [28,] "..names_d_pctile"
# [29,] "..names_d_ratio_to_avg"
# [30,] "..names_d_ratio_to_state_avg"
# [31,] "..names_d_state_avg"
# [32,] "..names_d_state_pctile"
# [33,] "..names_d_subgroups_ratio_to_avg"
# [34,] "..names_e"
# [35,] "..names_e_avg"
# [36,] "..names_e_pctile"
# [37,] "..names_e_ratio_to_avg"
# [38,] "..names_e_ratio_to_state_avg"
# [39,] "..names_e_state_avg"
# [40,] "..names_e_state_pctile"
# [41,] "..names_these"
# [42,] "..names_these_avg"
# [43,] "..names_these_ratio_to_avg"
# [44,] "..names_these_ratio_to_state_avg"
# [45,] "..names_these_state_avg"
# [46,] "..neededvars"
# [47,] "..otheravailable"
# [48,] "..output_vars"
# [49,] "..popmeancols_inbgstats"
# [50,] "..rationames"
# [51,] "..Rnames"
# [52,] "..score_colname"
# [53,] "..scorewts_colname"
# [54,] "..sharednames"
# [55,] "..topoints_id_colname"
# [56,] "..usefulcolumns"
# [57,] "..v"
# [58,] "..varname"
# [59,] "..vars"
# [60,] "..vnames_e"
# [61,] "..vnames_ST"
# [62,] "aboutpage_texts"
# [63,] "acs_bgfips"
# [64,] "acs_tractfips"
# [65,] "acs_version_global"
# [66,] "AIR_PROGRAM_CODE_SUBPARTS"
# [67,] "arcgis_address"
# [68,] "area"
# [69,] "area_fallback"
# [70,] "arealand"
# [71,] "areawater"
# [72,] "avg.pctdisability"
# [73,] "avg.pctlingiso"
# [74,] "avg.pctlowinc"
# [75,] "avg.pctlowlifex"
# [76,] "avg.pctlths"
# [77,] "avg.pctmin"
# [78,] "bg_suffix"
# [79,] "bgej"
# [80,] "bgid2fips"
# [81,] "bgid2fips_arrow"
# [82,] "bgpop"
# [83,] "bgwt"
# [84,] "block_radius_miles_round_temp"
# [85,] "BLOCK_X"
# [86,] "BLOCK_Y"
# [87,] "BLOCK_Z"
# [88,] "blockcount_near_site"
# [89,] "blockfips"
# [90,] "blockid2fips"
# [91,] "blockid2fips_arrow"
# [92,] "blocklat"
# [93,] "blocklon"
# [94,] "blockpoints"
# [95,] "blockpop"
# [96,] "blockscore"
# [97,] "blockwts"
# [98,] "color"
# [99,] "Color"
# [100,] "coslat_x_earth"
# [101,] "count_city_matched"
# [102,] "count_city_state_matched"
# [103,] "countyfips"
# [104,] "countyname"
# [105,] "Countyname"
# [106,] "countyname_ST"
# [107,] "custom_index"
# [108,] "Depends"
# [109,] "disab_universe"
# [110,] "disability"
# [111,] "distance"
# [112,] "distance_avg"
# [113,] "distance_min"
# [114,] "distance_min_avgperson"
# [115,] "distance_unadjusted"
# [116,] "distance.km"
# [117,] "drinking"
# [118,] "ejam_uniq_id"
# [119,] "ejscreen_version_global"
# [120,] "eparegion"
# [121,] "estimate"
# [122,] "extratable_stuff"
# [123,] "FAC_X"
# [124,] "FAC_Y"
# [125,] "FAC_Z"
# [126,] "failed"
# [127,] "failed_byfile"
# [128,] "failed_bygroup"
# [129,] "fips"
# [130,] "FIPS"
# [131,] "flagged"
# [132,] "flagged_byfile"
# [133,] "flagged_bygroup"
# [134,] "frs"
# [135,] "frs_arrow"
# [136,] "frs_by_mact"
# [137,] "frs_by_mact_arrow"
# [138,] "frs_by_naics"
# [139,] "frs_by_programid"
# [140,] "frs_by_programid_arrow"
# [141,] "frs_by_sic"
# [142,] "frs_index"
# [143,] "GEOID"
# [144,] "global_defaults_package"
# [145,] "global_defaults_shiny"
# [146,] "global_defaults_shiny_public"
# [147,] "group"
# [148,] "Group"
# [149,] "healthinsurance_universe"
# [150,] "help_texts"
# [151,] "html_fmts"
# [152,] "i"
# [153,] "i.arealand"
# [154,] "i.areawater"
# [155,] "i.bgfips"
# [156,] "i.bgid"
# [157,] "i.pop"
# [158,] "i.ST"
# [159,] "id_among_subset"
# [160,] "id_overall"
# [161,] "in_how_many_states"
# [162,] "indicator"
# [163,] "indicator_label"
# [164,] "invalid_msg"
# [165,] "kind"
# [166,] "lat_RAD"
# [167,] "LAT_RAD"
# [168,] "literalvarname"
# [169,] "localtree"
# [170,] "Locations"
# [171,] "logfilename"
# [172,] "lon_RAD"
# [173,] "long"
# [174,] "LONG_RAD"
# [175,] "lowlifex"
# [176,] "minutes_bygroup"
# [177,] "moe"
# [178,] "N"
# [179,] "name"
# [180,] "NAME"
# [181,] "nohealthinsurance"
# [182,] "OBJECTID"
# [183,] "oldname"
# [184,] "overall"
# [185,] "Package"
# [186,] "passed"
# [187,] "pctdisability"
# [188,] "pctdisability_rate"
# [189,] "pctlingiso"
# [190,] "pctlowinc"
# [191,] "pctlths"
# [192,] "pctmin"
# [193,] "pctnohealthinsurance"
# [194,] "pctownedunits"
# [195,] "PGM_SYS_ACRNMS"
# [196,] "placename"
# [197,] "pointid"
# [198,] "pop_nearby"
# [199,] "pop2020"
# [200,] "PRIMARY_NAME"
# [201,] "Priority"
# [202,] "program"
# [203,] "proximityscore"
# [204,] "quaddata"
# [205,] "query"
# [206,] "radius"
# [207,] "radius_donut_lower_edge"
# [208,] "radius.miles"
# [209,] "ratio"
# [210,] "Ratio"
# [211,] "REGISTRY_ID"
# [212,] "rname"
# [213,] "rnames"
# [214,] "sanitize_functions"
# [215,] "scores"
# [216,] "scorewts"
# [217,] "sd.pctdisability"
# [218,] "sd.pctlingiso"
# [219,] "sd.pctlowinc"
# [220,] "sd.pctlowlifex"
# [221,] "sd.pctlths"
# [222,] "sd.pctmin"
# [223,] "seconds_byfile"
# [224,] "seconds_byfile_predicted"
# [225,] "seconds_bygroup"
# [226,] "seconds_extra"
# [227,] "sitecount"
# [228,] "sitecount_avg"
# [229,] "sitecount_max"
# [230,] "sitepoints"
# [231,] "st1"
# [232,] "state_avg"
# [233,] "state_pctile"
# [234,] "statefips"
# [235,] "statename"
# [236,] "subpart"
# [237,] "testgroup"
# [238,] "total"
# [239,] "tract_disab_universe"
# [240,] "tract_disability"
# [241,] "tract_healthinsurance_universe"
# [242,] "tract_nohealthinsurance"
# [243,] "tract_pctdisability_rate"
# [244,] "tractfips"
# [245,] "tractpop"
# [246,] "untested_cant"
# [247,] "untested_skipped"
# [248,] "urlx"
# [249,] "usa_summary"
# [250,] "use_unadjusted_distance"
# [251,] "V1"
# [252,] "valid"
# [253,] "value"
# [254,] "warned"
# [255,] "wtdmean_within"
# [256,] "x"
# [257,] "x_hi"
# [258,] "x_low"
# [259,] "x_val"
# [260,] "y_val"
# [261,] "z_hi"
# [262,] "z_low"
# [263,] "z_val"
# >

  #
  #
  # cbind(from_check_var_add)





########################################### #
rm(
  from_misc, from_misc_add,
  from_varlist_add,
  from_datasets, from_datasets_add,
  from_check_var, from_check_var_add
)
########################################### #
