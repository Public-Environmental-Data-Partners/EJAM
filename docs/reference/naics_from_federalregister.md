# NAICS - Try to extract which NAICS could be affected by a rule published in the Federal Register by reading the NAICS listed near the top of the preamble - DRAFT WORK IN PROGRESS

NAICS - Try to extract which NAICS could be affected by a rule published
in the Federal Register by reading the NAICS listed near the top of the
preamble - DRAFT WORK IN PROGRESS

## Usage

``` r
naics_from_federalregister(naics_text_copy_from_fr)
```

## Arguments

- naics_text_copy_from_fr:

  text copied from the Federal Register notice, which often lists NAICS
  codes and industry names that are affected by the rule. This is often
  in a section near the top of the preamble, but formatting is likely
  inconsistent across FR notices.
