# Get lat lon, Registry ID, and NAICS, for given FRS Program System ID

Get lat lon, Registry ID, and NAICS, for given FRS Program System ID

## Usage

``` r
latlon_from_programid(programname, programid)
```

## Arguments

- programname:

  name of EPA program that the programid is from: "RCRAINFO" is the
  programname and "XJW000000174" is the programid if the full record was
  RCRAINFO:XJW000000174

- programid:

  like "XJW000000174" "RCRAINFO" is the programname and "XJW000000174"
  is the programid if the full record was RCRAINFO:XJW000000174

## Value

table in [data.table](https://r-datatable.com) format with lat lon
REGISTRY_ID program pgm_sys_id

## Details

The ID is the identification number, such as the permit number, assigned
by an information management system that represents a facility site,
waste site, operable unit, or other feature tracked by that
Environmental Information System.

see
[epa_programs](https://public-environmental-data-partners.github.io/EJAM/reference/epa_programs.md)
for a list of programs and their acronyms and a count of FRS facilities
under each. Also see a simple list of names like this:
as.vector(epa_programs) or sort(unique(frs_by_programid\$program))

There are roughly 3.5 million records in
[frs_by_programid](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_programid.md)
but only about 2.7 million unique pgm_sys_id values because the same
number may be used under different program types, like RCRAINFO AND
EGRID.

These are two distinct facilities both using the number 1:

latlon_from_programid('EGRID', 1) latlon_from_programid('ICIS', 1)

Also note the FRS API:
<https://www.epa.gov/frs/facility-registry-service-frs-api>
<https://www.epa.gov/frs/frs-rest-services>

## Examples

``` r
 ids = c("00603DSCFPRD459", "00603MCRNTRD11K", "00605VNMRBMONTA" )
 latlon_from_programid("TRIS", ids)

 latlon_from_programid('EGRID', 1)
 latlon_from_programid('ICIS', 1)

 # ambiguous to only use the number! 354362 is used by two programs here:
 frs_by_programid[match(testinput_program_sys_id, frs_by_programid$pgm_sys_id), ]
 frs_by_programid[frs_by_programid$pgm_sys_id %in% testinput_program_sys_id, ]
```
