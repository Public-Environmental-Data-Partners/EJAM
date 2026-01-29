# Examples of Input/Output Files & Data

Note: This article is a work in progress

## EXAMPLES OF FILES & TEST DATA EJAM CAN IMPORT OR OUTPUT

### Sample spreadsheets & shapefiles for trying the web app

Examples of .xlsx files and shapefiles are installed locally with EJAM,
as input files you can use to try out EJAM functions or the web app, or
to see what an input file should look like.

**Files and Datasets Installed with EJAM**

For just one topic you can see all files and data objects like this:

``` r

topic = "fips"  # or "shape" or "latlon" or "naics" or "address" etc.


# datasets / R objects
cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = T)))
#> Get more info with pkg_data(simple = FALSE)
#> 
#> ignoring sortbysize because simple=TRUE
#>      data.in.package                  
#> [1,] "testinput_fips_blockgroups"     
#> [2,] "testinput_fips_cities"          
#> [3,] "testinput_fips_counties"        
#> [4,] "testinput_fips_mix"             
#> [5,] "testinput_fips_states"          
#> [6,] "testinput_fips_tracts"          
#> [7,] "testoutput_ejamit_fips_cities"  
#> [8,] "testoutput_ejamit_fips_counties"

# files
cbind(files.in.package = sort(basename(testdata(topic, quiet = T))))
#>       files.in.package                         
#>  [1,] "cities_2.xlsx"                          
#>  [2,] "counties_in_AL_detailed.xlsx"           
#>  [3,] "counties_in_Alabama.xlsx"               
#>  [4,] "counties_in_Delaware_invalid.xlsx"      
#>  [5,] "counties_in_Delaware.xlsx"              
#>  [6,] "county_10.xlsx"                         
#>  [7,] "county_100.xlsx"                        
#>  [8,] "county_1000.xlsx"                       
#>  [9,] "county_state_300.xlsx"                  
#> [10,] "fips"                                   
#> [11,] "state_10.xlsx"                          
#> [12,] "state_50.xlsx"                          
#> [13,] "state_county_tract_10.xlsx"             
#> [14,] "testoutput_ejam2excel_fips_cities.xlsx" 
#> [15,] "testoutput_ejam2report_fips_cities.html"
#> [16,] "testoutput_ejamit_fips_counties.html"   
#> [17,] "testoutput_ejamit_fips_counties.xlsx"   
#> [18,] "tract_10.csv"                           
#> [19,] "tract_100.csv"                          
#> [20,] "tract_1000.csv"                         
#> [21,] "tract_state_285.xlsx"
```

**Local folders with sample files**

The best, simplest way to see all these files is the function called
testdata()

``` r

testdata()

# just shapefile examples:
 testdata('shape', quiet = TRUE)
```

You can try uploading these kinds of files in the web app, for example,
by finding them in these local folders where you installed the package:

- /`EJAM/testdata/latlon/testpoints_100.xlsx`
- /`EJAM/testdata/shapes/portland_shp.zip`
- etc.

To open the locally installed “testdata” folders (in Windows File
Explorer, or MacOS Finder)

``` r
browseURL(testdatafolder())
```

**Example of using a file in EJAM**

``` r
testpoint_files <- list.files(
  system.file("testdata/latlon", package = "EJAM"), 
  full.names = T
  )
testpoint_files

latlon_from_anything(testpoint_files[2]) 
```

### Sample R data objects: Examples of inputs & outputs of EJAM functions

The package has a number of data objects, installed as part of EJAM and
related packages, that are examples of inputs or intermediate data
objects that you can use to try out EJAM functions, or you may just want
to see what the outputs and inputs look like, or you could use them for
testing purposes.

For documentation on each input or output item (R object), see
[reference documentation on each
object](https://ejanalysis.github.io/EJAM/reference/index.html#test-data)

This code snippet provides a useful list of test/ sample data objects in
EJAM and related packages:

**POINT DATA (LAT/LON COORDINATES)** for testing
[`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md),
[`mapfast()`](https://ejanalysis.github.io/EJAM/reference/mapfast.md),
[`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md),
etc.

See all files and all dataset examples related to one topic:

``` r
topic = "fips"
cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = T)))
cbind(files.in.package = sort(basename(testdata(topic, quiet = T))))
```

``` r
x <- EJAM:::pkg_data(simple = FALSE)
x <- x[order(x$Package, x$Item), !grepl("size", names(x))]
```

``` r
x[grepl("^testp", x$Item), ]
#>     Package                Item
#> 115    EJAM       testpoints_10
#> 131    EJAM      testpoints_100
#> 133    EJAM   testpoints_100_dt
#> 150    EJAM     testpoints_1000
#> 163    EJAM    testpoints_10000
#> 124    EJAM        testpoints_5
#> 129    EJAM       testpoints_50
#> 145    EJAM      testpoints_500
#> 125    EJAM      testpoints_bad
#> 119    EJAM testpoints_overlap3
#>                                                        Title
#> 115 test points data.frame with columns sitenumber, lat, lon
#> 131 test points data.frame with columns sitenumber, lat, lon
#> 133 test points data.frame with columns sitenumber, lat, lon
#> 150 test points data.frame with columns sitenumber, lat, lon
#> 163 test points data.frame with columns sitenumber, lat, lon
#> 124 test points data.frame with columns sitenumber, lat, lon
#> 129 test points data.frame with columns sitenumber, lat, lon
#> 145 test points data.frame with columns sitenumber, lat, lon
#> 125       test points data.frame with columns note, lat, lon
#> 119       test points data.frame with columns note, lat, lon
```

**STREET ADDRESSES** for testing geocoding in
[`latlon_from_address()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_address.md)
etc.

``` r
x[grepl("^test_", x$Item), ]
#> [1] Package Item    Title  
#> <0 rows> (or 0-length row.names)
cat("\n\n")
```

**FACILITY REGISTRY IDs** for testing
[`latlon_from_regid()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_regid.md)
etc.

``` r
x[grepl("^test[^op_]", x$Item), ]
#>     Package                              Item
#> 32     EJAM               testinput_address_2
#> 101    EJAM               testinput_address_9
#> 102    EJAM           testinput_address_parts
#> 121    EJAM           testinput_address_table
#> 130    EJAM         testinput_address_table_9
#> 122    EJAM testinput_address_table_goodnames
#> 123    EJAM  testinput_address_table_withfull
#> 103    EJAM        testinput_fips_blockgroups
#> 33     EJAM             testinput_fips_cities
#> 34     EJAM           testinput_fips_counties
#> 35     EJAM                testinput_fips_mix
#> 36     EJAM             testinput_fips_states
#> 104    EJAM             testinput_fips_tracts
#> 37     EJAM                    testinput_mact
#> 38     EJAM                   testinput_naics
#> 39     EJAM            testinput_program_name
#> 114    EJAM          testinput_program_sys_id
#> 40     EJAM                   testinput_regid
#> 41     EJAM             testinput_registry_id
#> 136    EJAM                testinput_shapes_2
#> 42     EJAM                     testinput_sic
#> 135    EJAM                      testshapes_2
#>                                                                       Title
#> 32                            datasets for trying address-related functions
#> 101                           datasets for trying address-related functions
#> 102                           datasets for trying address-related functions
#> 121                           datasets for trying address-related functions
#> 130                           datasets for trying address-related functions
#> 122                           datasets for trying address-related functions
#> 123                           datasets for trying address-related functions
#> 103                                      testinput_fips_blockgroups dataset
#> 33                                            testinput_fips_cities dataset
#> 34                                          testinput_fips_counties dataset
#> 35                                               testinput_fips_mix dataset
#> 36                                            testinput_fips_states dataset
#> 104                                           testinput_fips_tracts dataset
#> 37                                                   testinput_mact dataset
#> 38                                                  testinput_naics dataset
#> 39                                           testinput_program_name dataset
#> 114 test data, EPA program names and program system ID numbers to try using
#> 40                 test data, EPA Facility Registry ID numbers to try using
#> 41                 test data, EPA Facility Registry ID numbers to try using
#> 136                                              testinput_shapes_2 dataset
#> 42                                                    testinput_sic dataset
#> 135                                                    testshapes_2 dataset
cat("\n\n")
```

**EXAMPLES OF OUTPUTS** from
[`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md),
[`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md),
etc., you can use as inputs to
[`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md),
[`ejam2excel()`](https://ejanalysis.github.io/EJAM/reference/ejam2excel.md),
[`ejam2ratios()`](https://ejanalysis.github.io/EJAM/reference/ejam2ratios.md),
[`ejam2barplot()`](https://ejanalysis.github.io/EJAM/reference/ejam2barplot.md),
[`doaggregate()`](https://ejanalysis.github.io/EJAM/reference/doaggregate.md),
etc.

``` r
x[grepl("^testout", x$Item), ]
#>     Package                                      Item
#> 173    EJAM     testoutput_doaggregate_1000pts_1miles
#> 166    EJAM      testoutput_doaggregate_100pts_1miles
#> 157    EJAM       testoutput_doaggregate_10pts_1miles
#> 174    EJAM          testoutput_ejamit_1000pts_1miles
#> 167    EJAM           testoutput_ejamit_100pts_1miles
#> 162    EJAM            testoutput_ejamit_10pts_1miles
#> 164    EJAM             testoutput_ejamit_fips_cities
#> 165    EJAM           testoutput_ejamit_fips_counties
#> 156    EJAM                testoutput_ejamit_shapes_2
#> 170    EJAM testoutput_getblocksnearby_1000pts_1miles
#> 155    EJAM  testoutput_getblocksnearby_100pts_1miles
#> 148    EJAM   testoutput_getblocksnearby_10pts_1miles
#>                                                                  Title
#> 173                                       test output of doaggregate()
#> 166                                       test output of doaggregate()
#> 157                                       test output of doaggregate()
#> 174                                            test output of ejamit()
#> 167                                            test output of ejamit()
#> 162                                            test output of ejamit()
#> 164                              testoutput_ejamit_fips_cities dataset
#> 165                            testoutput_ejamit_fips_counties dataset
#> 156                                 testoutput_ejamit_shapes_2 dataset
#> 170 test output of getblocksnearby(), and is an input to doaggregate()
#> 155 test output of getblocksnearby(), and is an input to doaggregate()
#> 148 test output of getblocksnearby(), and is an input to doaggregate()
cat("\n\n")
```

**LARGE DATASETS USED BY THE PACKAGE**

Note that the largest files used by the package are mostly the
block-related datasets with info about population size and location of
US blocks, the facility datasets with info about EPA-regulated sites,
and the blockgroup-related datasets with EJSCREEN indicators.

Some datasets get downloaded by the package at installation or launch or
as needed. See the article on [Updating EJAM
Datasets](https://ejanalysis.github.io/EJAM/articles/dev-update-datasets.md)
for more information on these.

Also see [reference documentation for each
dataset](https://ejanalysis.github.io/EJAM/reference/index.html#datasets-with-indicators-raw-data-means-percentiles-).
