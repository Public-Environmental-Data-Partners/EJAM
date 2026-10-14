#' @title Convert units of distance or area
#'
#' @description `convert_units` converts distance or area from specified units to other specified units.
#'
#' @details
#' This function takes a number, or vector of numbers, representing distance/length or area
#' in one type of specified units, such as miles, and returns the corresponding number(s)
#' converted to some other units, such as kilometers. Units can be specified in various ways.
#' All inputs must be in the same units. All outputs must be in a single set of units as well.
#'
#' NOTE: For some purposes, Census Bureau does this:
#'
#' "The ANSI standard for converting square kilometers into square miles was used
#' ( 1 square mile = 2.58998811 square kilometers)."
#' see <https://www.census.gov/geo/reference/state-area.html>
#' but the conversions in this function use 2.5899881034 not 2.58998811 sqkm/sqmi.
#' The difference is only 6.6 per billion (roughly 1 in 152 million), which is less than one tenth of a square kilometer out the entire USA.
#'
#' @param x A number or vector of numbers to be converted.
#' @param from A string specifying original units of input parameter. Default is 'km' which is kilometers.
#'   Note all must be in the same units.
#'   Units can be specified as any of the aliases found in the code for [fixnames_aliases()]
#'
#'   Note that m2 is for square meters not square miles.
#' @param towhat A string specifying new units to convert to. Default is 'mi' which is miles.
#' @return Returns a number or vector of numbers then length of the input x,
#'   with each element corresponding to an input element converted to new units.
#' @examples
#' convert_units(1, 'mi', 'km')
#' convert_units(c(1e6, 1), 'sqm', 'sqkm')
#'
#' @export
#'
convert_units <- function(x, from='km', towhat='mi') {

  ###################################################################### #
  from_final   <- fixnames_aliases(from,   na_if_no_match = TRUE, ignore.case = TRUE)
  towhat_final <- fixnames_aliases(towhat, na_if_no_match = TRUE, ignore.case = TRUE)
  ###################################################################### #

  ###################################################################### #
  if (any(is.na(from_final)))   {stop(paste(paste0(from[is.na(from_final)],     collapse = ","), 'aliases not found'))}
  if (any(is.na(towhat_final))) {stop(paste(paste0(towhat[is.na(towhat_final)], collapse = ","), 'aliases not found'))}

  ## alias_list is in fixnames_aliases()
  # names(alias_list)
  ## #  "sqkm" "sqm"  "sqcm" "sqmm" "km"   "m"    "cm"   "mm"   "sqmi" "sqyd" "sqft" "sqin" "mi"   "yd"   "ft"   "in"

  multipliers <- structure(list(
    from = c("mm", "cm", "m", "km", "sqmm", "sqcm", "sqm", "sqkm", "in", "ft", "yd", "mi", "sqin", "sqft", "sqyd", "sqmi"),

    mm = c(1, 10, 1000, 1e+06, NA, NA, NA, NA, 25.4, 304.8, 914.4, 1609344, NA, NA, NA, NA),
    cm = c(0.1, 1, 100, 1e+05, NA, NA, NA, NA, 2.54, 30.48, 91.44, 160934.4, NA, NA, NA, NA),
    m = c(0.001, 0.01, 1, 1000, NA, NA, NA, NA, 0.0254, 0.3048, 0.9144, 1609.344, NA, NA, NA, NA),
    km = c(1e-06, 1e-05, 0.001, 1, NA, NA, NA, NA, 2.54e-05, 0.0003048, 0.0009144, 1.609344, NA, NA, NA, NA),
    sqmm = c(NA, NA, NA, NA, 1, 100, 1e+06, 1e+12, NA, NA, NA, NA, 645.16, 92903.04, 836127.36, 2.589988e+12),
    sqcm = c(NA, NA, NA, NA, 0.01, 1, 10000, 1e+10, NA, NA, NA, NA, 6.4516, 929.0304, 8361.2736, 25899881103),
    sqm = c(NA, NA, NA, NA, 1e-06, 1e-04, 1, 1e+06, NA, NA, NA, NA, 0.00064516, 0.09290304, 0.83612736, 2589988.11034),
    sqkm = c(NA, NA, NA, NA, 1e-12, 1e-10, 1e-06, 1, NA, NA, NA, NA, 6.4516e-10, 9.290304e-08, 8.3612736e-07, 2.5899881034),
    `in` = c(0.0393700787402, 0.393700787402, 39.3700787402, 39370.0787402, NA, NA, NA, NA, 1, 12, 36, 63360, NA, NA, NA, NA),
    ft = c(0.00328083989501, 0.0328083989501, 3.28083989501, 3280.83989501, NA, NA, NA, NA, 0.083333333, 1, 3, 5280, NA, NA, NA, NA),
    yd = c(0.00109361329834, 0.0109361329834, 1.09361329834, 1093.61329834, NA, NA, NA, NA, 0.027777778, 0.333333333, 1, 1760, NA, NA, NA, NA),
    mi = c(6.21371192237, 6.21371192237e-06, 0.000621371192237, 0.621371192237, NA, NA, NA, NA, 1.57828e-05, 0.000189394, 0.000568182, 1, NA, NA, NA, NA),
    sqin = c(NA, NA, NA, NA, 0.0015500031, 0.15500031, 1550.0031, 1550003100, NA, NA, NA, NA,                                    1,     1/((12)^2), 1/((12*3)^2),  1/((12*3*1760)^2) ),
    sqft = c(NA, NA, NA, NA, 1.07639104167e-05, 0.00107639104167, 10.7639104167, 10763910.4167, NA, NA, NA, NA,         (       12)^2,  1,          1/((   3)^2),  1/((   3*1760)^2) ),
    sqyd = c(NA, NA, NA, NA, 1.1959852573e-06, 0.00011959852573, 1.1959852573, 1195985.2573, NA, NA, NA, NA,            (     3*12)^2, (     3)^2,  1,             1/((     1760)^2) ),
    sqmi = c(NA, NA, NA, NA, 3.86102158542e-13, 3.861021585e-11, 3.86102158542e-07, 0.386102158542, NA, NA, NA, NA,     (1760*3*12)^2, (1760*3)^2,    ((1760)^2),  1                 )
  ),
  names = c("from", "mm", "cm", "m", "km", "sqmm", "sqcm", "sqm", "sqkm", "in", "ft", "yd", "mi", "sqin", "sqft", "sqyd", "sqmi"),
  row.names = c(NA, 16L), class = "data.frame"
  )
  ## multipliers
  #    from        mm        cm         m        km         sqmm         sqcm          sqm         sqkm           in           ft           yd           mi         sqin         sqft         sqyd         sqmi
  # 1    mm       1.0      0.10    0.0010 0.0000010           NA           NA           NA           NA 3.937008e-02 3.280840e-03 1.093613e-03 6.213712e+00           NA           NA           NA           NA
  # 2    cm      10.0      1.00    0.0100 0.0000100           NA           NA           NA           NA 3.937008e-01 3.280840e-02 1.093613e-02 6.213712e-06           NA           NA           NA           NA
  # 3     m    1000.0    100.00    1.0000 0.0010000           NA           NA           NA           NA 3.937008e+01 3.280840e+00 1.093613e+00 6.213712e-04           NA           NA           NA           NA
  # 4    km 1000000.0 100000.00 1000.0000 1.0000000           NA           NA           NA           NA 3.937008e+04 3.280840e+03 1.093613e+03 6.213712e-01           NA           NA           NA           NA
  # 5  sqmm        NA        NA        NA        NA 1.000000e+00 1.000000e-02 1.000000e-06 1.000000e-12           NA           NA           NA           NA 1.550003e-03 1.076391e-05 1.195985e-06 3.861022e-13
  # 6  sqcm        NA        NA        NA        NA 1.000000e+02 1.000000e+00 1.000000e-04 1.000000e-10           NA           NA           NA           NA 1.550003e-01 1.076391e-03 1.195985e-04 3.861022e-11
  # 7   sqm        NA        NA        NA        NA 1.000000e+06 1.000000e+04 1.000000e+00 1.000000e-06           NA           NA           NA           NA 1.550003e+03 1.076391e+01 1.195985e+00 3.861022e-07
  # 8  sqkm        NA        NA        NA        NA 1.000000e+12 1.000000e+10 1.000000e+06 1.000000e+00           NA           NA           NA           NA 1.550003e+09 1.076391e+07 1.195985e+06 3.861022e-01
  # 9    in      25.4      2.54    0.0254 0.0000254           NA           NA           NA           NA 1.000000e+00 8.333333e-02 2.777778e-02 1.578280e-05           NA           NA           NA           NA
  # 10   ft     304.8     30.48    0.3048 0.0003048           NA           NA           NA           NA 1.200000e+01 1.000000e+00 3.333333e-01 1.893940e-04           NA           NA           NA           NA
  # 11   yd     914.4     91.44    0.9144 0.0009144           NA           NA           NA           NA 3.600000e+01 3.000000e+00 1.000000e+00 5.681820e-04           NA           NA           NA           NA
  # 12   mi 1609344.0 160934.40 1609.3440 1.6093440           NA           NA           NA           NA 6.336000e+04 5.280000e+03 1.760000e+03 1.000000e+00           NA           NA           NA           NA
  # 13 sqin        NA        NA        NA        NA 6.451600e+02 6.451600e+00 6.451600e-04 6.451600e-10           NA           NA           NA           NA 1.000000e+00 1.440000e+02 1.296000e+03 4.014490e+09
  # 14 sqft        NA        NA        NA        NA 9.290304e+04 9.290304e+02 9.290304e-02 9.290304e-08           NA           NA           NA           NA 6.944444e-03 1.000000e+00 9.000000e+00 2.787840e+07
  # 15 sqyd        NA        NA        NA        NA 8.361274e+05 8.361274e+03 8.361274e-01 8.361274e-07           NA           NA           NA           NA 7.716049e-04 1.111111e-01 1.000000e+00 3.097600e+06
  # 16 sqmi        NA        NA        NA        NA 2.589988e+12 2.589988e+10 2.589988e+06 2.589988e+00           NA           NA           NA           NA 2.490977e-10 3.587006e-08 3.228306e-07 1.000000e+00

  return( x * multipliers[ match(from_final, multipliers$from), towhat_final] )
}
