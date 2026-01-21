# Validate FRS Registry ID table uploaded (just checks colname, mostly)

Check for proper colname (or what seems to be a valid alias)

## Usage

``` r
frs_is_valid(frs_upload)
```

## Arguments

- frs_upload:

  upload frs registry IDs table converted to data frame (or table in
  [data.table](https://r-datatable.com) format gets handled too) with
  those ids in a column whose name is among allowed aliases that get
  tried here: the colname with the FRS regids must be one of
  REGISTRY_ID, RegistryID, regid, siteid, checked in that order of
  preference.

## Value

boolean value (valid or not valid)

## Details

note it checks aliases (REGISTRY_ID, RegistryID, regid, siteid) in that
order and once a valid name is found then even if it fails to actually
contain valid ids, the func does not go back and try the rest of the
possible aliases, so if the two cols were regid and siteid and only
siteid had valid registry ID values, this func would fail to figure that
out and would say they were invalid.
