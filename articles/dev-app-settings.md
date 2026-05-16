# Defaults and Custom Settings for the Web App

## NOTES ON GLOBAL DEFAULTS, SHINY INPUTS, BOOKMARKS, AND FUNCTION PARAMETERS

This document provides technical notes on how defaults and custom
settings are defined for the EJAM web app.

Most of what you might want to do is shown in documentation showing
examples of using the
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
function. This article is only needed if you want even more detail.
First reading the
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
reference info is recommended before reading any of the details below.

### HOW SETTINGS GET PASSED TO THE WEB APP

Many defaults are defined in files like `global_defaults_*.R`. They can
be changed there, but also can be passed to
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
as parameters, to override those global default settings for the
duration of the app. Using
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
parameters allows experienced analysts to customize how the web app
works without having to edit any files. It can be used on a laptop, for
example interactively with custom settings. For example, one can change
the radius, the type of sites to analyze, default name of the analysis,
report title/logo, etc., or to override caps such as limits on file
upload size or number of points:

``` r
ejamapp(
  radius=3.14,
  default_max_miles=31,
  default_max_mb_upload=100
)
```

These custom parameters are “advanced” features for knowledgeable users,
and not all the possible changes to these have been tested, so anyone
using them should be careful to understand the details of how this work
and confirm it is doing what is expected.

*For example, the radius is defined like this:*

1.  if a user in RStudio launches the app with something like
    `ejamapp(radius_default=3.1)`, the setting `radius_default` is
    defined, and will override what it says in `global_defaults_shiny.R`

2.  the files `global_defaults_*.R` are where the settings like
    `radius_default` are defined and stored as appOptions.

3.  that option/setting is checked in the advanced tab UI, to provide
    the initially selected value of `input$radius_default` in a
    bookmarkable input control found in the advanced tab. In this case
    the option and input used the same exact name, “radius_default” but
    that is not always the case for other settings.

4.  in the advanced tab, `input$radius_default` can then be adjusted by
    a user or just left alone. It provides the initially selected value
    of `input$radius_now` (which is for the slider UI, but happens to be
    defined in the server not ui in this case).

5.  the radius slider bar will change the value of `input$radius_now`
    when a user moves the radius slider bar in the UI.

6.  the value of `input$radius_now` is what the app uses in calculations
    when the start analysis button is clicked.

*A setting can be named differently in three places:*

Sometimes there are two or three separate names that affect the same
setting. You only need to know about the first one unless you are
editing URL-encoded bookmarks or editing source code!

1.  The global default constant that is the initial value of x, and is
    normally defined in a `global_defaults_*.R` file installed with the
    EJAM package, but also can be provided as a parameter to
    [`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md).

2.  for the subset of settings that can be adjusted in the Advanced tab
    (not all can), there is a second variable: the input\$ one can
    adjust in that tab.

3.  the name of the input\$ finally used in the main part of the web
    app.

The first of these three cannot be saved as a bookmark, but the second
or third can be bookmarked since it is a shiny app input\$ variable.

*Steps in EJAM shiny app launch, and the use of params/ defaults/
advanced tab/ bookmarked inputs/etc.:*

#### app.R and isPublic=T

If the app is on a server or one uses the RStudio button “Run”, app.R is
used. app.R is normally how the app is launched if it is a hosted shiny
app on a server. app.R mostly just does library(EJAM) and
ejamapp(isPublic = TRUE). isPublic is special because it is checked by
the global_defaults_shiny_public.R file and some settings depend on
isPublic being T or F.

#### ejamapp() parameters

If the app is launched directly via
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
by a user in RStudio console, it skips app.R and a user can provide
arguments as parameters in ejamapp(…). See
[`?ejamapp`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)

#### global_defaults\_\*.R files

Many defaults/ settings used by the web app are defined in the
global_defaults\_ files (global_defaults_package.R,
global_defaults_shiny.R, global_defaults_shiny_public.R). Some settings
are needed even if the shiny app is never launched, so they are stored
for the package as soon as the package is attached, in a list object
called `global_defaults_package` in the global environment, e.g.,
`global_defaults_package$report_title`. (When the app is launched, those
and many other global_defaults from the files `global_defaults_*.R`,
including radius_default, will be stored in the shiny app). Note the
parameter isPublic is special because it is checked by the
global_defaults_shiny_public.R file and some settings depend on isPublic
being T or F.

#### any ejamapp() parameters will override global_defaults\_\*.R settings

Just before launching the app,
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
calls
[`get_global_defaults_or_user_options()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_global_defaults_or_user_options.md)
which gets the global defaults and then overrides/replaces them with any
user-specified versions of those options given as arguments in
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md).

#### app launch

[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
launches the app – it uses a function called
[`golem::with_golem_options()`](https://thinkr-open.github.io/golem/reference/with_golem_options.html),
which defines the `app` object using
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html), but
then stores all the global defaults and any user-provided parameters as
`app$appOptions$golem_options`, just before launching the app. Those
options can be retrieved in app or server later, via
`EJAM:::global_or_param()` which relies on
[`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html).

#### global env?

Then app_ui() and app_server() can check for defaults/params using
`EJAM:::global_or_param("radius_default")` which uses
[`golem::get_golem_options()`](https://thinkr-open.github.io/golem/reference/get_golem_options.html)
to check for a named option stored in `app$appOptions$golem_options`.
Usually these are used as initial/default values for input\$ variables
in the app. However, note if an expected setting is not found (ie not
set by user in ejamapp() and not set in any global_defaults\_ file)
[`global_or_param()`](https://public-environmental-data-partners.github.io/EJAM/reference/global_or_param.md)
also looks in global env, as a last resort!! That might be a problem if
ui or server looks for a setting that we failed to provide in
global_defaults files and that variable name happens to be in the global
env !

#### Advanced Tab

SOME BUT NOT ALL global_defaults\_ settings are in the Advanced Tab (in
app_ui) where they typically provide the default for an input\$ but that
default can be overridden there by someone using the app’s Advanced Tab,
so what ui or server ends up using could be an input\$ that is
adjustable in the Advanced Tab and therefore can be bookmarked (since
inputs can be bookmarked unless specifically excluded from that).

To view the Advanced tab in the web app, click the About tab and then
the Show advanced button on that page. If that button is not visible,
use ejamapp(default_can_show_advanced_settings=TRUE). To show the
advanced tab at launch, use
ejamapp(default_show_advanced_settings=TRUE).

#### web app reactives and interactive inputs

The shiny app uses some settings as initial values for parameters that
can get changed by the user via sliders, radio buttons, text boxes,
dropdowns, etc. and some selections/inputs can get changed by reactive
observers, etc.

#### Bookmarks (URL or server-based) for saved input\$ state

If the app is launched by a bookmark (e.g.URL-encoded bookmark), any
inputs encoded in the URL will override the above and the app will
change to a state where the inputs are as specified by the bookmark.

Bookmarks have limitations though: Notably, uploaded files can only be
bookmarked if enableBookmarking=“server” not enableBookmarking=“url”.
Also, bookmarks normally just save the state of UI inputs, not other
reactive values (unless the server code specifies otherwise by using the
[`shiny::onBookmark()`](https://rdrr.io/pkg/shiny/man/onBookmark.html)
and
[`shiny::onRestore()`](https://rdrr.io/pkg/shiny/man/onBookmark.html)
functions to make bookmarks store other information, beyond just
inputs). Some important global defaults affect the app but not by
providing initial values for inputs in the shiny app, so some useful
information including some that is controlled by global defaults or user
parameters in ejamapp() cannot be bookmarked because it is stored in
reactives but not as shiny app inputs.

### ————–

### EXAMPLES OF USING CUSTOM SETTINGS

#### Launch local app (the R user’s computer) with custom settings

See the examples in the documentation of the function
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)

One such example:

``` r
ejamapp(
  default_standard_analysis_title="Custom NAICS Analysis",
  default_upload_dropdown="dropdown",
  default_selected_type_of_site_category="NAICS",
  default_naics_digits_shown="detailed",
  default_naics="562211",
  radius_default=3.1,
  default_show_advanced_settings=FALSE
)
```

#### Launch hosted app (online, URL) with custom settings

If the web app is running locally or hosted on a server, launching it
via URL-encoded bookmark can provide it any of the input\$ variables as
a starting state.

This approach cannot provide settings that are not input\$ reactives,
like some of the defaults in global_defaults\_ that are not turned into
inputs in the app, such as “app_logo_aboutpage” set in
global_defaults_package.R and used in app_ui.R as the src parameter for
img().

Also note that url-encoded bookmarked inputs can launch the app and pass
various input\$ settings to the app, which would override the default
values of those input\$ settings provided by the global_defaults\_\*.R
and/or
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md)
parameters handled by the utility function
get_global_defaults_or_user_options().

**Example that will launch app with a custom title and radius**

Note this tries to specify the NAICS method, but at least initially the
draft code handling this could not specify the NAICS code itself or
start analysis via URL bookmark:

Here is an example using the URL of one copy of the hosted app:

Locally hosted app example

``` r
# In 1 R session, launch locally with advanced tab disabled
myport <- 5432
ejamapp(isPublic=TRUE, options = list(port=myport))

# Then you can open a second R session and in that new R session
# paste/use the code below to relaunch the app
# with a parameter that enables the advanced tab:

params <- c('ui_show_advanced_settings=1')
urlbase <- paste0("http://127.0.0.1:", myport, "/?_inputs_&")
urlx <- URLencode(paste0(urlbase, paste0(params, collapse = "&")))
browseURL(urlx)
```

Using a custom URL to go to a web app with custom settings

``` r
urlbase <- "https://ejam.policyinnovation.info/?_inputs_&"

myparams <- c(
  standard_analysis_title="Custom NAICS Analysis",
  default_ss_choose_method="dropdown", 
  ss_choose_method_drop="NAICS", 
  naics_digits_shown="detailed", 
  # ss_select_naics=313,  
  radius_default=3.1,
  ui_show_advanced_settings=1
)

params <- c('standard_analysis_title="Custom NAICS Analysis"',
            'ss_choose_method="dropdown"',   # like ejamapp( default_upload_dropdown="dropdown" )
            'ss_choose_method_drop="NAICS"', # see ?ejamapp()
            'naics_digits_shown="detailed"', # like ejamapp( default_naics_digits_shown = "detailed")
            # 'ss_select_naics=313',           # like ejamapp(default_naics=313)
            'radius_default=3.1',             # like ejamapp(radius_default = 3.1)
            'ui_show_advanced_settings=1')

urlx <- URLencode(paste0(urlbase, paste0(params, collapse = "&")))
browseURL(urlx)

# URL tried, with fips picked
# http://127.0.0.1:4200/?_inputs_&standard_analysis_title=%22Custom%20COUNTIES%20Analysis%22&pickermoduleid-all_regions_button=%22TRUE%22&pickermoduleid-all_states_button=%22TRUE%22&ui_show_advanced_settings=1&ss_choose_method=%22dropdown%22&fipspicker_done_button=2&ss_choose_method_drop=%22FIPS_PLACE%22&pickermoduleid-fips_type2pick=%22Counties%22&pickermoduleid-counties_picked=%2202110%22
```

### ————–

### COMPILED LISTS OF ALL SETTINGS (FUNCTION PARAMETERS, GLOBAL_DEFAULTS\_, AND SHINY INPUT\$ VARS)

#### \> global_defaults_xyz - compiled full list

``` r
gdefs = EJAM:::get_global_defaults_or_user_options()
#> Checking for index of Census blocks called 'localtree' ...localtree already exists.
#> isPublic =  FALSE
gdefnames = sort(unique(names(gdefs)))
cbind(global_defaults = gdefnames)
#>        global_defaults                                
#>   [1,] "aboutpage_text"                               
#>   [2,] "app_logo"                                     
#>   [3,] "app_logo_aboutpage"                           
#>   [4,] "app_logo_html"                                
#>   [5,] "app_title"                                    
#>   [6,] "app_version"                                  
#>   [7,] "app_version_header_text"                      
#>   [8,] "app_version_short"                            
#>   [9,] "bookmarking_allowed"                          
#>  [10,] "default_add_naics_subcategories"              
#>  [11,] "default_allow_median_in_barplot_indicators"   
#>  [12,] "default_avoidorphans"                         
#>  [13,] "default_bysite_webtable_colnames"             
#>  [14,] "default_calculate_ratios"                     
#>  [15,] "default_can_show_advanced_settings"           
#>  [16,] "default_choices_for_type_of_site_category"    
#>  [17,] "default_choices_for_type_of_site_upload"      
#>  [18,] "default_circleweight"                         
#>  [19,] "default_cities_picked"                        
#>  [20,] "default_counties_picked"                      
#>  [21,] "default_download_city_fips_bounds"            
#>  [22,] "default_download_noncity_fips_bounds"         
#>  [23,] "default_epa_program_selected"                 
#>  [24,] "default_extra_demog"                          
#>  [25,] "default_extratable_hide_missing_rows_for"     
#>  [26,] "default_extratable_list_of_sections"          
#>  [27,] "default_extratable_show_ratios_in_report"     
#>  [28,] "default_extratable_title"                     
#>  [29,] "default_extratable_title_top_row"             
#>  [30,] "default_hide_about_tab"                       
#>  [31,] "default_hide_plot_barplot_tab"                
#>  [32,] "default_hide_plot_histo_tab"                  
#>  [33,] "default_hide_written_report"                  
#>  [34,] "default_hyperlink_colnames"                   
#>  [35,] "default_include_averages"                     
#>  [36,] "default_include_ejindexes"                    
#>  [37,] "default_include_extraindicators"              
#>  [38,] "default_mact"                                 
#>  [39,] "default_max_mb_upload"                        
#>  [40,] "default_max_miles"                            
#>  [41,] "default_max_pts_map"                          
#>  [42,] "default_max_pts_run"                          
#>  [43,] "default_max_pts_select"                       
#>  [44,] "default_max_pts_showtable"                    
#>  [45,] "default_max_pts_upload"                       
#>  [46,] "default_max_shapes_map"                       
#>  [47,] "default_maxradius"                            
#>  [48,] "default_naics"                                
#>  [49,] "default_naics_digits_shown"                   
#>  [50,] "default_need_proximityscore"                  
#>  [51,] "default_ok2plot"                              
#>  [52,] "default_plotkind_1pager"                      
#>  [53,] "default_print_uploaded_points_to_log"         
#>  [54,] "default_reports"                              
#>  [55,] "default_shiny.testmode"                       
#>  [56,] "default_show_advanced_settings"               
#>  [57,] "default_show_full_header_footer"              
#>  [58,] "default_show_ratios_in_report"                
#>  [59,] "default_shp_oktypes_1"                        
#>  [60,] "default_sic"                                  
#>  [61,] "default_standard_analysis_title"              
#>  [62,] "default_states_picked"                        
#>  [63,] "default_subgroups_type"                       
#>  [64,] "default_testing"                              
#>  [65,] "default_upload_dropdown"                      
#>  [66,] "default.an_thresh_comp1"                      
#>  [67,] "default.an_thresh_comp2"                      
#>  [68,] "default.an_threshgroup1"                      
#>  [69,] "default.an_threshgroup2"                      
#>  [70,] "default.an_threshnames1"                      
#>  [71,] "default.an_threshnames2"                      
#>  [72,] "ejamapi_is_down"                              
#>  [73,] "epa_program_help_msg"                         
#>  [74,] "escape_html"                                  
#>  [75,] "fips_help_msg"                                
#>  [76,] "fipspicker_all_counties_button_defaultchecked"
#>  [77,] "fipspicker_all_counties_button_defaultshow"   
#>  [78,] "fipspicker_all_regions_button_defaultchecked" 
#>  [79,] "fipspicker_all_regions_button_defaultshow"    
#>  [80,] "fipspicker_all_states_button_defaultchecked"  
#>  [81,] "fipspicker_all_states_button_defaultshow"     
#>  [82,] "fipspicker_fips_type2pick_choices_default"    
#>  [83,] "fipspicker_fips_type2pick_default"            
#>  [84,] "fipspicker_maxOptions_default_cities_picked"  
#>  [85,] "fipspicker_maxOptions_default_counties_picked"
#>  [86,] "fipspicker_maxOptions_default_states_picked"  
#>  [87,] "frs_help_msg"                                 
#>  [88,] "html_footer_fmt"                              
#>  [89,] "html_header_fmt"                              
#>  [90,] "latlon_help_msg"                              
#>  [91,] "marker_cluster_cutoff"                        
#>  [92,] "max_radius_default"                           
#>  [93,] "maxmax_mb_upload"                             
#>  [94,] "maxmax_miles"                                 
#>  [95,] "maxmax_pts_map"                               
#>  [96,] "maxmax_pts_run"                               
#>  [97,] "maxmax_pts_select"                            
#>  [98,] "maxmax_pts_showtable"                         
#>  [99,] "maxmax_pts_upload"                            
#> [100,] "maxmax_shapes_map"                            
#> [101,] "minmax_mb_upload"                             
#> [102,] "minradius"                                    
#> [103,] "minradius_shapefile"                          
#> [104,] "radius_default"                               
#> [105,] "radius_default_shapefile"                     
#> [106,] "report_logo"                                  
#> [107,] "report_logo_dir"                              
#> [108,] "report_logo_file"                             
#> [109,] "report_title"                                 
#> [110,] "report_title_multisite"                       
#> [111,] "sanitize_numeric"                             
#> [112,] "sanitize_text"                                
#> [113,] "shp_help_msg"                                 
#> [114,] "sitereport_download_buttons_colname"          
#> [115,] "sitereport_download_buttons_show"             
#> [116,] "stepradius"                                   
#> [117,] "tabshown_default"                             
#> [118,] "use_shapefile_from_any"
```

#### \> function params - compiled full list

``` r
params = formals(ejamit) 
# params = c(formals(getblocksnearby), formals(getblocksnearbyviaQuadTree), formals(get_blockpoints_in_shape), formals(getblocksnearby_from_fips), formals(ejamit), formals(doaggregate))
paramnames = sort(unique(names(params)))
cbind(params = paramnames)
#>       params                        
#>  [1,] "..."                         
#>  [2,] "avoidorphans"                
#>  [3,] "calctype_maxbg"              
#>  [4,] "calctype_minbg"              
#>  [5,] "calculate_ratios"            
#>  [6,] "calculatedcols"              
#>  [7,] "called_by_ejamit"            
#>  [8,] "countcols"                   
#>  [9,] "download_city_fips_bounds"   
#> [10,] "download_noncity_fips_bounds"
#> [11,] "extra_demog"                 
#> [12,] "fips"                        
#> [13,] "in_shiny"                    
#> [14,] "include_ejindexes"           
#> [15,] "infer_sitepoints"            
#> [16,] "maxradius"                   
#> [17,] "need_blockwt"                
#> [18,] "need_proximityscore"         
#> [19,] "progress_all"                
#> [20,] "quadtree"                    
#> [21,] "quiet"                       
#> [22,] "radius"                      
#> [23,] "radius_donut_lower_edge"     
#> [24,] "reports"                     
#> [25,] "shapefile"                   
#> [26,] "showdrinkingwater"           
#> [27,] "showpctowned"                
#> [28,] "silentinteractive"           
#> [29,] "sitepoints"                  
#> [30,] "subgroups_type"              
#> [31,] "testing"                     
#> [32,] "threshgroups"                
#> [33,] "threshnames"                 
#> [34,] "thresholds"                  
#> [35,] "updateProgress"              
#> [36,] "updateProgress_getblocks"    
#> [37,] "wtdmeancols"
```

#### \> shiny inputs - compiled full list

Compilation of input\$ variables used in the shiny app

``` r
# getwd() must be the source pkg root folder
getwd()
lines_with_inputnames = trimws(grep("input\\$", gsub("^(.*)(input\\$.*\\))(.*)", "\\2", readLines("./R/app_server.R") ), value=T))
x = gsub("^(.*)(input\\$.*)", "\\2", lines_with_inputnames)
x = gsub("]|)|,|}", " ", x)
x = gsub("(input\\$)([^ ]*)(.*)", "\\1\\2", x)
# cbind(x, lines_with_inputnames)
inputnames = sort(unique(x)); rm(x,lines_with_inputnames)
inputnames = grep("\\.$|\\$$", inputnames, value = TRUE, invert = TRUE)
# cbind(inputnames)
# cbind(part_of_a_named_list = inputnames[grepl("\\$.*\\$", inputnames)])
inputnames =  inputnames[!grepl("\\$.*\\$", inputnames)] # they all also showed up without the extra $xyz part

# What names are used in the shiny app input$ reactives?

cbind(shiny_inputs = inputnames)
inputnames = gsub("^input\\$", "", inputnames)
dput(inputnames)
```

``` r

inputnames = c("add_naics_subcategories", "all_tabs", "allow_median_in_barplot_indicators", 
"an_map_clusters", "an_thresh_comp2", "an_threshgroup1", "an_threshgroup2", 
"an_threshnames2", "analysis_title", "avoidorphans", "back_to_site_sel", 
"back_to_site_sel2", "bt_get_results", "bysite_webtable_colnames", 
"calculate_ratios", "can_show_advanced_settings", "checkbox1", 
"coauthor_emails", "coauthor_names", "conclusion1", "conclusion2", 
"conclusion3", "Custom_title_for_bar_plot_of_indicators", "default_ss_choose_method", 
"demog_high_at_what_share_of_sites", "demog_how_elevated", "envt_high_at_what_share_of_sites", 
"envt_how_elevated", "epa_program_help", "extra_demog", "extratable_hide_missing_rows_for", 
"extratable_show_ratios_in_report", "extratable_title", "extratable_title_top_row", 
"facilities_studied", "facilities_studied_enter", "fips_help", 
"fipspicker_done_button", "format1pager", "frs_help", "fundingsource", 
"go", "in_areas_where_enter", "in_the_x_zone", "in_the_x_zone_enter", 
"include_ejindexes", "latlon_help", "latlontypedin_submit_button", 
"max_mb_upload", "max_miles", "max_pts_map", "max_pts_run", "max_pts_select", 
"max_pts_upload", "max_shapes_map", "maxradius", "naics_digits_shown", 
"need_proximityscore", "ok2plot", "plotkind_1pager", "radius_default", 
"radius_default_shapefile", "radius_now", "radius_units", "results_tabs", 
"return_to_results", "rg_author_email", "rg_author_name", "rg_enter_miles", 
"rg_enter_sites", "rg_zonetype", "risks_are_x", "shiny.testmode", 
"show_advanced_settings", "show_data_preview", "show_ratios_in_report", 
"shp_help", "sitereport_download_buttons_show", "source_of_latlons", 
"ss_choose_method", "ss_choose_method_drop", "ss_choose_method_upload", 
"ss_select_mact", "ss_select_naics", "ss_select_program", "ss_select_sic", 
"ss_upload_fips", "ss_upload_frs", "ss_upload_latlon", "ss_upload_program", 
"ss_upload_shp", "standard_analysis_title", "subgroups_type", 
"summ_bar_data", "summ_bar_ind", "summ_bar_stat", "summ_hist_bins", 
"summ_hist_data", "summ_hist_distn", "summ_hist_ind", "testing", 
"ui_hide_advanced_settings", "ui_show_advanced_settings", "y"
)
```

#### \> ALL OVERLAPS/ DIFFS (compiled func params, global defaults, shiny inputs)

``` r

gdefnames_noprefix = gsub("default_", "", gdefnames)

cat("How many are named the same way in shiny inputs, global_defaults_, and function parameters?\n\n")

length(
  intersect(inputnames, gdefnames_noprefix) # about 28
  )
length(
  intersect(paramnames, gdefnames_noprefix)
  )
length(
  intersect(paramnames, inputnames)
  )
# in all 3 lists
print(
  intersect(paramnames, intersect(inputnames, gdefnames_noprefix))
)

cat("Unique names in shiny inputs, as named \n")
length(
  setdiff(inputnames, c(paramnames, gdefnames_noprefix))
)

cat("Unique names in global_defaults_ (not function parameters or inputs, as named) \n")
length(
  setdiff(gdefnames_noprefix, c(paramnames, inputnames))
)

cat("Unique names in function parameters \n")
length(
  setdiff(paramnames, c(gdefnames_noprefix, inputnames))
)
```

### ————–

### ANNOTATED LISTS OF SOME SETTINGS

#### \> function params - grouped by function

Function parameters whose defaults are or could be included in advanced
tab, and allowed by
[`ejamapp()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapp.md).

``` r

EJAM:::args2(getblocksnearby)
#> 
#> 
#> An attempt to print a view of function defaults with one per row of text: 
#> 
#> getblocksnearby(
#>   sitepoints,
#>   radius = 3,
#>   maxradius = 31.07,
#>   radius_donut_lower_edge = 0,
#>   avoidorphans = FALSE,
#>   quadtree = NULL,
#>   quaddatatable = NULL,
#>   quiet = FALSE,
#>   parallel = FALSE,
#>   use_unadjusted_distance = TRUE,
#>   ...
#> )
#> 
#> 
#> What str() shows (minus the attributes)  
#> 
#> function (sitepoints, radius = 3, maxradius = 31.07, radius_donut_lower_edge = 0, 
#>     avoidorphans = FALSE, quadtree = NULL, quaddatatable = NULL, quiet = FALSE, 
#>     parallel = FALSE, use_unadjusted_distance = TRUE, ...)  
#> NULL

EJAM:::args2(getblocksnearbyviaQuadTree)
#> 
#> 
#> An attempt to print a view of function defaults with one per row of text: 
#> 
#> getblocksnearbyviaQuadTree(
#>   sitepoints,
#>   radius = 3,
#>   radius_donut_lower_edge = 0,
#>   maxradius = 31.07,
#>   avoidorphans = FALSE,
#>   report_progress_every_n = 500,
#>   quiet = FALSE,
#>   use_unadjusted_distance = FALSE,
#>   retain_unadjusted_distance = TRUE,
#>   quadtree,
#>   updateProgress = NULL
#> )
#> 
#> 
#> What str() shows (minus the attributes)  
#> 
#> function (sitepoints, radius = 3, radius_donut_lower_edge = 0, maxradius = 31.07, 
#>     avoidorphans = FALSE, report_progress_every_n = 500, quiet = FALSE, 
#>     use_unadjusted_distance = FALSE, retain_unadjusted_distance = TRUE, 
#>     quadtree, updateProgress = NULL)  
#> NULL

EJAM:::args2(get_blockpoints_in_shape)
#> 
#> 
#> An attempt to print a view of function defaults with one per row of text: 
#> 
#> get_blockpoints_in_shape(
#>   polys,
#>   addedbuffermiles = 0,
#>   blocksnearby = NULL,
#>   dissolved = FALSE,
#>   safety_margin_ratio = 1.1,
#>   crs = 4269,
#>   updateProgress = NULL,
#>   oldway = TRUE
#> )
#> 
#> 
#> What str() shows (minus the attributes)  
#> 
#> function (polys, addedbuffermiles = 0, blocksnearby = NULL, dissolved = FALSE, 
#>     safety_margin_ratio = 1.1, crs = 4269, updateProgress = NULL, oldway = TRUE)  
#> NULL

EJAM:::args2(getblocksnearby_from_fips)
#> 
#> 
#> An attempt to print a view of function defaults with one per row of text: 
#> 
#> getblocksnearby_from_fips(
#>   fips,
#>   in_shiny = FALSE,
#>   need_blockwt = TRUE,
#>   return_shp = FALSE,
#>   allow_multiple_fips_types = TRUE,
#>   radius = 0
#> )
#> 
#> 
#> What str() shows (minus the attributes)  
#> 
#> function (fips, in_shiny = FALSE, need_blockwt = TRUE, return_shp = FALSE, 
#>     allow_multiple_fips_types = TRUE, radius = 0)  
#> NULL

# sitepoints can be a param in ejamapp()
# shapefile  can be a param in ejamapp()
# fips

# radius_donut_lower_edge
# quiet = FALSE
```

#### \> function params - annotated list of most

``` r
# > cbind(formals(ejamit))
EJAM:::args2(ejamit)
#> 
#> 
#> An attempt to print a view of function defaults with one per row of text: 
#> 
#> ejamit(
#>   sitepoints = NULL,
#>   radius = 3,
#>   radius_donut_lower_edge = 0,
#>   maxradius = 31.07,
#>   avoidorphans = FALSE,
#>   quadtree = NULL,
#>   fips = NULL,
#>   shapefile = NULL,
#>   countcols = NULL,
#>   wtdmeancols = NULL,
#>   calculatedcols = NULL,
#>   calctype_maxbg = NULL,
#>   calctype_minbg = NULL,
#>   subgroups_type = "nh",
#>   include_ejindexes = TRUE,
#>   calculate_ratios = TRUE,
#>   extra_demog = TRUE,
#>   need_proximityscore = FALSE,
#>   infer_sitepoints = FALSE,
#>   need_blockwt = TRUE,
#>   thresholds = list(80, 80),
#>   threshnames = list(c(names_ej_pctile, names_ej_state_pctile), c(names_ej_supp_pctile, names_ej_supp_state_pctile)),
#>   threshgroups = list("EJ-US-or-ST", "Supp-US-or-ST"),
#>   reports = EJAM:::global_or_param("default_reports"),
#>   updateProgress = NULL,
#>   updateProgress_getblocks = NULL,
#>   progress_all = NULL,
#>   in_shiny = FALSE,
#>   quiet = TRUE,
#>   silentinteractive = FALSE,
#>   called_by_ejamit = TRUE,
#>   testing = FALSE,
#>   showdrinkingwater = TRUE,
#>   showpctowned = TRUE,
#>   download_city_fips_bounds = TRUE,
#>   download_noncity_fips_bounds = FALSE,
#>   ...
#> )
#> 
#> 
#> What str() shows (minus the attributes)  
#> 
#> function (sitepoints = NULL, radius = 3, radius_donut_lower_edge = 0, maxradius = 31.07, 
#>     avoidorphans = FALSE, quadtree = NULL, fips = NULL, shapefile = NULL, 
#>     countcols = NULL, wtdmeancols = NULL, calculatedcols = NULL, calctype_maxbg = NULL, 
#>     calctype_minbg = NULL, subgroups_type = "nh", include_ejindexes = TRUE, 
#>     calculate_ratios = TRUE, extra_demog = TRUE, need_proximityscore = FALSE, 
#>     infer_sitepoints = FALSE, need_blockwt = TRUE, thresholds = list(80, 
#>         80), threshnames = list(c(names_ej_pctile, names_ej_state_pctile), 
#>         c(names_ej_supp_pctile, names_ej_supp_state_pctile)), threshgroups = list("EJ-US-or-ST", 
#>         "Supp-US-or-ST"), reports = EJAM:::global_or_param("default_reports"), 
#>     updateProgress = NULL, updateProgress_getblocks = NULL, progress_all = NULL, 
#>     in_shiny = FALSE, quiet = TRUE, silentinteractive = FALSE, called_by_ejamit = TRUE, 
#>     testing = FALSE, showdrinkingwater = TRUE, showpctowned = TRUE, download_city_fips_bounds = TRUE, 
#>     download_noncity_fips_bounds = FALSE, ...)  
#> NULL

# sitepoints               NULL            -- Now can be passed to ejamapp()
# shapefile                NULL           ----   shapefile now can be  passed to ejamapp()
# fips                     NULL            ----   fips  will be enabled as param

# radius                   3   for getblocksnearby(), shiny radius_default is in global_defaults_
# radius_donut_lower_edge  0         na
# maxradius                31.07     for getblocksnearby(), shiny default is set in global
# avoidorphans             FALSE     for getblocksnearby(), shiny default is set in global
# quadtree                 NULL      na

# countcols                NULL      for doaggregate() ** shiny default NOT specified here
# popmeancols              NULL      for doaggregate() ** shiny default NOT specified here
# calculatedcols           NULL      for doaggregate() ** shiny default NOT specified here
# calctype_maxbg           NULL      for doaggregate() ** shiny default NOT specified here
# calctype_minbg           NULL      for doaggregate() ** shiny default NOT specified here

# subgroups_type           "nh"      for doaggregate(), shiny default is set in global
# include_ejindexes        TRUE      for doaggregate(), shiny default is set in global
# calculate_ratios         TRUE      for doaggregate(), shiny default is set in global
# extra_demog              TRUE      for doaggregate(), shiny default is set in global
# need_proximityscore      FALSE     for doaggregate(), shiny default is set in global
# infer_sitepoints         FALSE     for doaggregate() ** shiny default NOT specified here
# need_blockwt             TRUE      for getblocksnearby_from_fips(), shiny default not specified here, but by function defaults

# thresholds          expression  for batch.summarize() - set in global_ but named differently
# threshnames         expression  for batch.summarize() - set in global_ but named differently
# threshgroups        expression  for batch.summarize() - set in global_ but named differently

# updateProgress           NULL      ** shiny default NOT specified here
# updateProgress_getblocks NULL      ** shiny default NOT specified here
# in_shiny                 FALSE     for ejamit(), build_community_report(), and related functions
# quiet                    TRUE      for getblocksnearby() and batch.summarize(), na

# testing                  FALSE    for doaggregate(), shiny default is set in global
# silentinteractive        FALSE    for doaggregate() etc. na
# called_by_ejamit         TRUE     for doaggregate(), na
# showdrinkingwater        TRUE     for doaggregate(), na
# showpctowned             TRUE     for doaggregate(), na
# download_city_fips_bounds = TRUE,
# download_noncity_fips_bounds = FALSE,
# ...                      ?   for getblocksnearby(), like use_unadjusted_distance ** shiny default NOT specified here
```

#### \> shiny inputs - categorized (partial)

EJAM shiny app inputs that can be URL-encoded in a bookmark to reopen
the app with those settings Note the URL cuts off at about 4096
characters

##### inputs: tabs and nav and help buttons

``` r

all_tabs="See Results"   # or # all_tabs="Advanced Settings"
results_tabs="Community Report"
details_subtabs="Site-by-Site Table"

show_advanced_settings="TRUE" 
can_show_advanced_settings="TRUE"

# buttons:
ui_show_advanced_settings=1 #button
ui_hide_advanced_settings=0 #button
show_data_preview=0
back_to_site_sel2=0
return_to_results=0
latlon_help=0
shp_help=0
fips_help=0
frs_help=0
epa_program_help=0
```

##### inputs: start analysis button

``` r
bt_get_results=0
```

##### inputs: site selection (buttons/dropdowns)

``` r
default_ss_choose_method="upload" # or "dropdown"
ss_choose_method="upload"         # or "dropdown"
ss_choose_method_upload="latlon"   # see global_defaults_*.R for options
ss_choose_method_drop="FIPS_PLACE" # see global_defaults_*.R for options
ss_upload_shp=null
ss_upload_fips=null
ss_upload_frs=null
ss_upload_program=null
ss_select_program="CAMDBS"
ss_select_naics="313"  # see default_naics
ss_select_sic="2015"   # see default_sic
ss_select_mact="AA" # see default_mact 
naics_digits_shown="basic"
add_naics_subcategories="TRUE"

shinyjs-resettable-ss_upload_latlon={}
shinyjs-resettable-ss_upload_shp={}
shinyjs-resettable-ss_upload_frs={}
shinyjs-resettable-ss_upload_program={}
shinyjs-resettable-ss_upload_fips={}

pickermoduleid-fips_type2pick="Counties"
pickermoduleid-states_picked=null
pickermoduleid-counties_picked=null
pickermoduleid-cities_picked=null
pickermoduleid-regions_picked=["1","2","3","4","5","6","7","8","9","10"]
pickermoduleid-all_regions_button=true
pickermoduleid-all_states_button=true
pickermoduleid-all_counties_button=false
pickermoduleid-all_cities_button=false
pickermoduleid-reset_button=0
fipspicker_done_button=0
```

##### inputs: radius and caps

``` r
radius_now=3.1  # input from slider but not the way to bookmark /url-encode the radius
radius_default=3.1  # works as parameter to ejamapp() or as bookmarked input$ 
radius_default_shapefile=0
max_miles=10
maxradius=31.06856
max_pts_upload=5000
max_pts_select=5000
max_pts_map=5000
max_pts_showtable=1000
max_pts_run=10000
max_shapes_map=159
max_mb_upload=50
```

##### inputs: more ejamit() parameters, summary report and excel output settings, etc.

``` r
standard_analysis_title="CUSTOM Analysis" # shown on webpage of app and on reports
analysis_title="testname"
Custom_title_for_bar_plot_of_indicators=""
include_ejindexes="TRUE"
calculate_ratios=true
include_averages=true
show_ratios_in_report="TRUE"
extratable_show_ratios_in_report="TRUE"
more3="a"
avoidorphans="FALSE"
need_proximityscore="FALSE"
plotkind_1pager="bar"
format1pager="html"
ok2plot=true
allow_median_in_barplot_indicators="FALSE"
summ_hist_distn="People" # histograms
summ_hist_data="pctile"
summ_hist_bins=10

extra_demog="TRUE"
include_extraindicators=true
extratable_title=""
extratable_title_top_row="ADDITIONAL INFORMATION"
extratable_list_of_sections="pctpoor"
# extratable_hide_missing_rows_for=["pcthisp","pctnhba","pctnhaa","pctnhaiana","pctnhnhpia","pctnhotheralone","pctnhmulti","pctnhwa","pctlan_ie","pctlan_api","pctlan_other","pctlan_english","pctlan_spanish","pctlan_french",
# "pctlan_rus_pol_slav","p_chinese","p_korean","pctlan_other_ie","pctlan_vietnamese","pctlan_other_asian","pctlan_arabic","pctlan_nonenglish",
# "pctspanish_li","pctie_li","pctapi_li","pctother_li","pctmale","pctfemale","pctdisability","lowlifex","rateheartdisease","rateasthma","ratecancer","pctunder5","pctunder18","pctover64","occupiedunits","lifexyears",
# "percapincome","pctownedunits","pctpoor","sitecount_avg","sitecount_unique","sitecount_max","distance_min_avgperson","distance_min","count.NPL","count.TSDF","num_waterdis","num_airpoll","num_brownfield","num_tri","num_school",
# "num_hospital","num_church","yesno_tribal","yesno_airnonatt","yesno_impwaters","yesno_cejstdis","yesno_iradis","pctflood","pctfire","pctfire30","pctflood30","yesno_houseburden","yesno_transdis","yesno_fooddesert","pctnobroadband",
# "pctnohealthinsurance","pop","nonmins","age25up","hhlds","unemployedbase","pre1960","builtunits","povknownratio"]  # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base

# thresholds - counting how many of a certain indicator type are at/above some threshold
# see help docs on ejamapp() for examples of using these (but they are named a bit differently as parameters there)
an_thresh_comp1=80
an_thresh_comp2=80
an_threshgroup1="EJ-US-or-ST"
an_threshgroup2="Supp-US-or-ST"
an_threshnames1=["pctile.EJ.DISPARITY.dpm.eo","pctile.EJ.DISPARITY.drinking.eo","pctile.EJ.DISPARITY.no2.eo","pctile.EJ.DISPARITY.o3.eo","pctile.EJ.DISPARITY.pctpre1960.eo","pctile.EJ.DISPARITY.pm.eo","pctile.EJ.DISPARITY.proximity.npdes.eo",
                 "pctile.EJ.DISPARITY.proximity.npl.eo","pctile.EJ.DISPARITY.proximity.rmp.eo","pctile.EJ.DISPARITY.proximity.tsdf.eo","pctile.EJ.DISPARITY.rsei.eo","pctile.EJ.DISPARITY.traffic.score.eo","pctile.EJ.DISPARITY.ust.eo",
                 "state.pctile.EJ.DISPARITY.dpm.eo","state.pctile.EJ.DISPARITY.drinking.eo","state.pctile.EJ.DISPARITY.no2.eo","state.pctile.EJ.DISPARITY.o3.eo","state.pctile.EJ.DISPARITY.pctpre1960.eo","state.pctile.EJ.DISPARITY.pm.eo","state.pctile.EJ.DISPARITY.proximity.npdes.eo",
                 "state.pctile.EJ.DISPARITY.proximity.npl.eo","state.pctile.EJ.DISPARITY.proximity.rmp.eo","state.pctile.EJ.DISPARITY.proximity.tsdf.eo","state.pctile.EJ.DISPARITY.rsei.eo","state.pctile.EJ.DISPARITY.traffic.score.eo","state.pctile.EJ.DISPARITY.ust.eo"]
an_threshnames2=["pctile.EJ.DISPARITY.dpm.supp","pctile.EJ.DISPARITY.drinking.supp","pctile.EJ.DISPARITY.no2.supp","pctile.EJ.DISPARITY.o3.supp","pctile.EJ.DISPARITY.pctpre1960.supp","pctile.EJ.DISPARITY.pm.supp","pctile.EJ.DISPARITY.proximity.npdes.supp",
                 "pctile.EJ.DISPARITY.proximity.npl.supp","pctile.EJ.DISPARITY.proximity.rmp.supp","pctile.EJ.DISPARITY.proximity.tsdf.supp","pctile.EJ.DISPARITY.rsei.supp","pctile.EJ.DISPARITY.traffic.score.supp","pctile.EJ.DISPARITY.ust.supp","state.pctile.EJ.DISPARITY.dpm.supp",
                 "state.pctile.EJ.DISPARITY.drinking.supp","state.pctile.EJ.DISPARITY.no2.supp","state.pctile.EJ.DISPARITY.o3.supp","state.pctile.EJ.DISPARITY.pctpre1960.supp","state.pctile.EJ.DISPARITY.pm.supp","state.pctile.EJ.DISPARITY.proximity.npdes.supp",
                 "state.pctile.EJ.DISPARITY.proximity.npl.supp","state.pctile.EJ.DISPARITY.proximity.rmp.supp","state.pctile.EJ.DISPARITY.proximity.tsdf.supp","state.pctile.EJ.DISPARITY.rsei.supp","state.pctile.EJ.DISPARITY.traffic.score.supp","state.pctile.EJ.DISPARITY.ust.supp"]
```

##### inputs: maps

``` r
an_leaf_map_zoom=5
an_leaf_map_bounds={"north":45.61403741135093,"east":-68.02734375000001,"south":28.18824364185031,"west":-123.2666015625}
an_leaf_map_center={"lng":-95.64786455000001,"lat":37.40467238129763}
an_leaf_map_groups="circles"
circleweight_in=4
```

##### inputs: test mode

``` r
testing="FALSE"
shiny.testmode="FALSE"
print_uploaded_points_to_log=true
```

##### inputs: draft / reserved for a long word/pdf report

``` r

# authors

rg_author_name="FirstName LastName"
rg_author_email="author@email.org"
rg_add_coauthors=false
coauthor_names=""
coauthor_emails=""
fundingsource=""

# methods & data

acs_version=""
ejscreen_version=""
subgroups_type="nh"

## sites selected for analysis

prefix_filenames=""
in_the_x_zone="area"
facilities_studied="rule"
facilities_studied_enter=""
rg_enter_sites="facilities in the _____ source category"
source_of_latlons=""
in_areas_where_enter=""
in_the_x_zone_enter="in "
rg_zonetype="zone_is_named_x"
within_x_miles_of="near the"
in_areas_where="in areas with"
risks_are_x="risk is at or above 1 per million (lifetime individual cancer risk due to inhalation of air toxics from this source category)"

# results

demog_how_elevated=""
envt_how_elevated=""
demog_high_at_what_share_of_sites="some of these sites, just as it varies nationwide"
envt_high_at_what_share_of_sites="some of these sites, just as it varies nationwide"
conclusion1=""
conclusion2=""
conclusion3=""
```

### ————–
