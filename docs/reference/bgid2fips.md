# bgid2fips (DATA) Census FIPS codes of blockgroups

bgid2fips (DATA) Census FIPS codes of blockgroups

## Details

For documentation on EJSCREEN, see [EJSCREEN
documentation](https://web.archive.org/web/20250118193121/https://www.epa.gov/ejscreen)

bgid2fips is a table of all census blockgroups, with their FIPS codes.

It also has a column called `blockid` that can join it to other block
datasets.

      dataload_dynamic('bgid2fips')

      names(bgid2fips)
      dim(bgid2fips)
