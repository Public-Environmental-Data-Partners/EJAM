# frs (DATA) EPA Facility Registry Service table of regulated sites

This is a table in [data.table](https://r-datatable.com) format, a
snapshot version of the EPA FRS. You can look up sites by REGISTRY_ID in
frs, and get their location, etc.

## Details

This dataset can be updated by a package maintainer by using
frs_update_datasets() (which is not an exported function)

The definitions of active/inactive here are not quite the same as used
in ECHO. See attributes(frs) to see date created, etc.

Also, EJSCREEN has [maps of EPA-regulated facilities of a few program types](https://ejanalysis.github.io/EJAM/articles/ejscreen-map-descriptions.html#epa-regulated-facilities)
and for a table of acronym definitions see
https://www.epa.gov/sites/default/files/2021-05/frs_program_abbreviations_and_names.xlsx
and
[epa_programs_defined](https://ejanalysis.github.io/EJAM/reference/epa_programs_defined.md)

- Count of all REGISTRY_ID rows: Approx 7 million

- Count of unique REGISTRY_ID values: Approx 4-5 million

- Clearly inactive unique IDs: Approx 1-2 million

- Assumed active unique IDs: Approx 3 million

- frs rows total: Approx 2-3 million (2.6m as of 02/2025)

- frs_by_programid rows: Approx 3-4 million (3.5m as of 02/2025)

- frs_by_naics rows: Approx 640k (541k unique regid as of 02/2025, 1858
  unique NAICS)

- frs_by_sic rows: Approx 764k (664k unique regid as of 02/2025, 2048
  unique SIC)

Classes ‘data.table’ and 'data.frame'

colnames

- \[1,\] "lat"

- \[2,\] "lon"

- \[3,\] "REGISTRY_ID" like 110000343003

- \[4,\] "PRIMARY_NAME"

- \[5,\] "NAICS" csv group of codes per site

- \[6,\] "SIC"

- \[7,\] "PGM_SYS_ACRNMS" like RCRAINFO:XJW000200113

## See also

[epa_programs](https://ejanalysis.github.io/EJAM/reference/epa_programs.md)
[epa_programs_defined](https://ejanalysis.github.io/EJAM/reference/epa_programs_defined.md)
[frs_by_programid](https://ejanalysis.github.io/EJAM/reference/frs_by_programid.md)
[frs_by_naics](https://ejanalysis.github.io/EJAM/reference/frs_by_naics.md)
[frs_by_sic](https://ejanalysis.github.io/EJAM/reference/frs_by_sic.md)
