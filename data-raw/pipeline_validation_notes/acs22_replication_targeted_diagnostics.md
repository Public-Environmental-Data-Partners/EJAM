# ACS22 Replication Targeted Diagnostics

Created: 2026-05-26 19:54:25.422507

This is a one-time diagnostic note. It does not change annual pipeline behavior.
The ordering here follows the current debugging priority: raw scores first, percentile lookup behavior second, EJ indexes last.

## Inputs

- EPA 2024 EJScreen v2.32 ACS22 reference folder: `s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2022/epa_original_reference/2024_2.32_August_UseMe`
- EJAM 2025 tool reference: `v2.32.8.001` package data
- EJAM 2026 pipeline ACS22 folder: `s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2022`

## 1. Raw Score Inventory

### Raw score differences with substantive size or NA/zero mismatches

| comparison | varlist | column | rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | names_e | drinking | 242336 | 0 | 19208 | 0 | 163948 | 183156 | 19208 | 0.00000000000000000000 | 0.000000000000000000000 | 010010208031 |  | 0 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_criticalservice | pctnohealthinsurance | 242336 | 237245 | 3450 | 0 | 4675 | 3388 | 3450 | 0.98999999999999999112 | 0.054737500000000001432 | 010010201001 | 0.08 | 0.0823023130715438 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_health_count | disability | 242336 | 29 | 0 | 0 | 1996 | 1996 | 0 | 1.00000000000000000000 | 0.000119668999999999996 | 060376024043 | 215 | 214 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_e | proximity.npdes | 242336 | 29 | 1897 | 1897 | 18484 | 18484 | 0 | 0.00000524521000000000 | 0.000000000606197000000 | 010010201001 | 264.347574841757 | 264.347574841757 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_health_count | disab_universe | 242336 | 23 | 0 | 0 | 1807 | 1807 | 0 | 1.00000000000000000000 | 0.000094909500000000003 | 040131166212 | 3001 | 3000 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_community | percapincome | 242336 | 0 | 0 | 2418 | 234 | 1 | 2418 | 0.00000000000000000000 | 0.000000000000000000000 | 010039900000 | -666666666 |  |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_d | pctunemployed | 242336 | 0 | 424 | 2589 | 54571 | 52406 | 2165 | 0.00000000000000102696 | 0.000000000000000151557 | 010010201002 | 0.025210084033613 | 0.0252100840336134 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_health_count | disability | 242336 | 29 | 0 | 0 | 1996 | 1996 | 0 | 1.00000000000000000000 | 0.000119668999999999996 | 060376024043 | 215 | 214 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_e | proximity.npdes | 242336 | 29 | 1897 | 1897 | 18484 | 18484 | 0 | 0.00000524521000000000 | 0.000000000606197000000 | 010010201001 | 264.347574841757 | 264.347574841757 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_health_count | disab_universe | 242336 | 23 | 0 | 0 | 1807 | 1807 | 0 | 1.00000000000000000000 | 0.000094909500000000003 | 040131166212 | 3001 | 3000 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_e | drinking | 242336 | 0 | 19208 | 0 | 163948 | 183156 | 19208 | 0.00000000000051159100 | 0.000000000000000417556 | 010010208031 |  | 0 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_d | pctunemployed | 242336 | 0 | 424 | 2589 | 54571 | 52406 | 2165 | 0.00000000000000102696 | 0.000000000000000151557 | 010010201002 | 0.025210084033613 | 0.0252100840336134 |

### Four demographic index raw-score fields

The blockgroup raw-score fields are shown separately because many exact floating-point differences are harmless. `diff_gt_tolerance == 0` means the field is not a substantive raw-score replication problem at the 1e-6 threshold.

| comparison | column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | max_abs_diff | mean_abs_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index | 0 | 0 | 0 | 0 | 2421 | 2421 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index.State | 0 | 0 | 0 | 0 | 2423 | 2423 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp | 0 | 0 | 0 | 0 | 1 | 1 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp.State | 0 | 0 | 0 | 0 | 208 | 208 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index | 216639 | 0 | 0 | 0 | 2421 | 2421 | 0.0000000000000150990 | 0.00000000000000281573 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index.State | 180548 | 0 | 0 | 0 | 2423 | 2423 | 0.0000000000000319744 | 0.00000000000000240977 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index.Supp | 242334 | 0 | 0 | 0 | 1 | 1 | 0.0000000000001718630 | 0.00000000000007983610 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index.Supp.State | 212498 | 0 | 0 | 0 | 208 | 208 | 0.0000000000001243450 | 0.00000000000000295834 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index | 216639 | 0 | 0 | 0 | 2421 | 2421 | 0.0000000000000150990 | 0.00000000000000281573 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index.State | 180548 | 0 | 0 | 0 | 2423 | 2423 | 0.0000000000000319744 | 0.00000000000000240977 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp | 242334 | 0 | 0 | 0 | 1 | 1 | 0.0000000000001718630 | 0.00000000000007983610 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp.State | 212498 | 0 | 0 | 0 | 208 | 208 | 0.0000000000001243450 | 0.00000000000000295834 |

### Raw value pattern diagnostics for the main non-replicated fields

| comparison | column | rows_compared | ref_na_candidate_na | ref_na_candidate_zero | ref_na_candidate_nonzero | ref_zero_candidate_na | ref_zero_candidate_zero | ref_zero_candidate_nonzero | both_non_na_equal | both_non_na_diff_gt_tolerance | max_abs_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM vs EPA | drinking | 242336 | 0 | 19208 | 0 | 0 | 163948 | 0 | 223128 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | drinking | 242336 | 0 | 19208 | 0 | 0 | 163948 | 0 | 223128 | 0 | 0.00000000000051159100 |
| 2026 pipeline vs 2025 EJAM | drinking | 242336 | 0 | 0 | 0 | 0 | 183156 | 0 | 242336 | 0 | 0.00000000000051159100 |
| 2025 EJAM vs EPA | pctunemployed | 242336 | 424 | 0 | 0 | 0 | 54571 | 0 | 241912 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | pctunemployed | 242336 | 424 | 0 | 0 | 2165 | 52406 | 0 | 239747 | 0 | 0.00000000000000102696 |
| 2026 pipeline vs 2025 EJAM | pctunemployed | 242336 | 424 | 0 | 0 | 2165 | 52406 | 0 | 239747 | 0 | 0.00000000000000102696 |
| 2026 pipeline vs 2025 EJAM | pctnohealthinsurance | 242336 | 0 | 1819 | 1631 | 0 | 1569 | 3106 | 1641 | 237245 | 0.98999999999999999112 |
| 2026 pipeline vs 2025 EJAM | percapincome | 242336 | 0 | 0 | 0 | 233 | 1 | 0 | 239918 | 0 | 0.00000000000000000000 |
| 2025 EJAM vs EPA | disab_universe | 242336 | 0 | 0 | 0 | 0 | 1807 | 0 | 242336 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | disab_universe | 242336 | 0 | 0 | 0 | 0 | 1807 | 0 | 242313 | 23 | 1.00000000000000000000 |
| 2026 pipeline vs 2025 EJAM | disab_universe | 242336 | 0 | 0 | 0 | 0 | 1807 | 0 | 242313 | 23 | 1.00000000000000000000 |
| 2025 EJAM vs EPA | disability | 242336 | 0 | 0 | 0 | 0 | 1996 | 0 | 242336 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | disability | 242336 | 0 | 0 | 0 | 0 | 1996 | 0 | 242307 | 29 | 1.00000000000000000000 |
| 2026 pipeline vs 2025 EJAM | disability | 242336 | 0 | 0 | 0 | 0 | 1996 | 0 | 242307 | 29 | 1.00000000000000000000 |

### Drinking-water raw-score NA/zero pattern by state or territory

| comparison | region | rows | ref_na_candidate_zero | ref_zero_candidate_na | na_mismatch | diff_gt_tolerance |
| --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM vs EPA | PR | 2555 | 2555 | 0 | 2555 | 0 |
| 2025 EJAM vs EPA | MI | 8386 | 1283 | 0 | 1283 | 0 |
| 2025 EJAM vs EPA | OH | 9472 | 1031 | 0 | 1031 | 0 |
| 2025 EJAM vs EPA | FL | 13388 | 991 | 0 | 991 | 0 |
| 2025 EJAM vs EPA | VA | 5963 | 990 | 0 | 990 | 0 |
| 2025 EJAM vs EPA | GA | 7446 | 952 | 0 | 952 | 0 |
| 2025 EJAM vs EPA | NY | 16070 | 930 | 0 | 930 | 0 |
| 2025 EJAM vs EPA | PA | 10173 | 653 | 0 | 653 | 0 |
| 2025 EJAM vs EPA | IN | 5290 | 641 | 0 | 641 | 0 |
| 2025 EJAM vs EPA | LA | 4294 | 609 | 0 | 609 | 0 |
| 2025 EJAM vs EPA | WI | 4692 | 606 | 0 | 606 | 0 |
| 2025 EJAM vs EPA | NC | 7111 | 596 | 0 | 596 | 0 |
| 2025 EJAM vs EPA | MN | 4706 | 540 | 0 | 540 | 0 |
| 2025 EJAM vs EPA | SC | 3408 | 511 | 0 | 511 | 0 |
| 2025 EJAM vs EPA | CA | 25607 | 508 | 0 | 508 | 0 |
| 2025 EJAM vs EPA | MD | 4079 | 494 | 0 | 494 | 0 |
| 2025 EJAM vs EPA | AL | 3925 | 442 | 0 | 442 | 0 |
| 2025 EJAM vs EPA | MO | 5031 | 402 | 0 | 402 | 0 |
| 2025 EJAM vs EPA | IL | 9898 | 353 | 0 | 353 | 0 |
| 2025 EJAM vs EPA | OK | 3374 | 337 | 0 | 337 | 0 |
| 2026 pipeline vs EPA | PR | 2555 | 2555 | 0 | 2555 | 0 |
| 2026 pipeline vs EPA | MI | 8386 | 1283 | 0 | 1283 | 0 |
| 2026 pipeline vs EPA | OH | 9472 | 1031 | 0 | 1031 | 0 |
| 2026 pipeline vs EPA | FL | 13388 | 991 | 0 | 991 | 0 |
| 2026 pipeline vs EPA | VA | 5963 | 990 | 0 | 990 | 0 |
| 2026 pipeline vs EPA | GA | 7446 | 952 | 0 | 952 | 0 |
| 2026 pipeline vs EPA | NY | 16070 | 930 | 0 | 930 | 0 |
| 2026 pipeline vs EPA | PA | 10173 | 653 | 0 | 653 | 0 |
| 2026 pipeline vs EPA | IN | 5290 | 641 | 0 | 641 | 0 |
| 2026 pipeline vs EPA | LA | 4294 | 609 | 0 | 609 | 0 |
| 2026 pipeline vs EPA | WI | 4692 | 606 | 0 | 606 | 0 |
| 2026 pipeline vs EPA | NC | 7111 | 596 | 0 | 596 | 0 |
| 2026 pipeline vs EPA | MN | 4706 | 540 | 0 | 540 | 0 |
| 2026 pipeline vs EPA | SC | 3408 | 511 | 0 | 511 | 0 |
| 2026 pipeline vs EPA | CA | 25607 | 508 | 0 | 508 | 0 |
| 2026 pipeline vs EPA | MD | 4079 | 494 | 0 | 494 | 0 |
| 2026 pipeline vs EPA | AL | 3925 | 442 | 0 | 442 | 0 |
| 2026 pipeline vs EPA | MO | 5031 | 402 | 0 | 402 | 0 |
| 2026 pipeline vs EPA | IL | 9898 | 353 | 0 | 353 | 0 |
| 2026 pipeline vs EPA | OK | 3374 | 337 | 0 | 337 | 0 |
| 2026 pipeline vs 2025 EJAM | AK | 504 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | AL | 3925 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | AR | 2294 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | AZ | 4773 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | CA | 25607 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | CO | 4058 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | CT | 2717 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | DC | 571 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | DE | 706 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | FL | 13388 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | GA | 7446 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | HI | 1083 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | IA | 2703 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | ID | 1284 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | IL | 9898 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | IN | 5290 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | KS | 2461 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | KY | 3581 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | LA | 4294 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | MA | 5116 | 0 | 0 | 0 | 0 |

## 2. Percentile Lookup Tables

### Raw-score lookup columns with substantive differences or NA/zero mismatches

| comparison | varlist | column | rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_d | Demog.Index.Supp | 5304 | 5303 | 0 | 0 | 57 | 1 | 0 | 2.7923900000 | 0.2232030000000 | AK\|0 | 0 | 0.385545010846291 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_d | Demog.Index | 5304 | 5230 | 0 | 0 | 76 | 74 | 0 | 3.5026300000 | 0.2491100000000 | AK\|1 | 0.240585372647978 | 0.18537762419872 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_e | drinking | 5304 | 817 | 102 | 0 | 3779 | 3993 | 102 | 84.0771000000 | 0.1947770000000 | AK\|36 | 0.025524695385474 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_d_subgroups | pctnhwa | 5304 | 1 | 0 | 0 | 210 | 209 | 0 | 0.0316869000 | 0.0000059741400 | AK\|1 | 0.00531427081805888 | 0.00531427081805889 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_e | proximity.npdes | 5304 | 1 | 102 | 102 | 379 | 379 | 0 | 0.0000038147 | 0.0000000011311 | AL\|1 | 1.41282813e-06 | 1.4128281298e-06 |
| 2026 pipeline statestats vs EPA state lookup | names_d | Demog.Index.Supp | 5304 | 5303 | 0 | 0 | 57 | 1 | 0 | 2.7923900000 | 0.2232030000000 | AK\|0 | 0 | 0.385545010846291 |
| 2026 pipeline statestats vs EPA state lookup | names_d | Demog.Index | 5304 | 5230 | 0 | 0 | 76 | 74 | 0 | 3.5026300000 | 0.2491100000000 | AK\|1 | 0.240585372647978 | 0.18537762419872 |
| 2026 pipeline statestats vs EPA state lookup | names_e | drinking | 5304 | 817 | 102 | 0 | 3779 | 3993 | 102 | 84.0771000000 | 0.1947770000000 | AK\|36 | 0.025524695385474 | 0 |
| 2026 pipeline statestats vs EPA state lookup | names_e | proximity.npdes | 5304 | 1 | 102 | 102 | 379 | 379 | 0 | 0.0000038147 | 0.0000000011311 | AL\|1 | 1.41282813e-06 | 1.4128281298e-06 |
| 2026 pipeline usastats vs 2025 EJAM usastats | names_e | drinking | 102 | 16 | 0 | 0 | 74 | 76 | 0 | 2.7112300000 | 0.1410000000000 | USA\|74 | 0.050391561230801 | 0 |
| 2026 pipeline usastats vs 2025 EJAM usastats | names_e | proximity.npdes | 102 | 1 | 0 | 0 | 8 | 8 | 0 | 0.0000038147 | 0.0000000376663 | USA\|10 | 0.003104158243576 | 0.00310415824357621 |
| 2026 pipeline usastats vs EPA national lookup | names_e | drinking | 102 | 16 | 0 | 0 | 74 | 76 | 0 | 2.7112300000 | 0.1410000000000 | USA\|74 | 0.050391561230801 | 0 |
| 2026 pipeline usastats vs EPA national lookup | names_e | proximity.npdes | 102 | 1 | 0 | 0 | 8 | 8 | 0 | 0.0000038147 | 0.0000000376663 | USA\|10 | 0.003104158243576 | 0.00310415824357621 |

### State lookup demographic-index naming/compatibility crosswalk

| label | ref_column | candidate_column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EPA state Demog.Index vs old legacy Demog.Index | Demog.Index | Demog.Index | 0 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000000000 | 0.00000000000000000000 |  |  |  |
| EPA state Demog.Index vs new legacy Demog.Index | Demog.Index | Demog.Index | 5230 | 5230 | 0 | 0 | 76 | 74 | 0 | 3.5026299999999999102 | 0.24910999999999999810 | AK\|1 | 0.240585372647978 | 0.18537762419872 |
| EPA state Demog.Index vs new explicit Demog.Index.State | Demog.Index | Demog.Index.State | 3948 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000199411 | AK\|1 | 0.240585372647978 | 0.240585372647977 |
| EPA state Demog.Index.Supp vs old legacy Demog.Index.Supp | Demog.Index.Supp | Demog.Index.Supp | 0 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000000000000 | 0.00000000000000000000 |  |  |  |
| EPA state Demog.Index.Supp vs new legacy Demog.Index.Supp | Demog.Index.Supp | Demog.Index.Supp | 5303 | 5303 | 0 | 0 | 57 | 1 | 0 | 2.7923900000000001498 | 0.22320300000000001250 | AK\|0 | 0 | 0.385545010846291 |
| EPA state Demog.Index.Supp vs new explicit Demog.Index.Supp.State | Demog.Index.Supp | Demog.Index.Supp.State | 4537 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001243450 | 0.00000000000000258504 | AK\|1 | 0.41873096170812 | 0.418730961708119 |
| Old legacy Demog.Index vs new legacy Demog.Index | Demog.Index | Demog.Index | 5230 | 5230 | 0 | 0 | 76 | 74 | 0 | 3.5026299999999999102 | 0.24910999999999999810 | AK\|1 | 0.240585372647978 | 0.18537762419872 |
| Old legacy Demog.Index vs new explicit Demog.Index.State | Demog.Index | Demog.Index.State | 3948 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000199411 | AK\|1 | 0.240585372647978 | 0.240585372647977 |
| Old legacy Demog.Index.Supp vs new legacy Demog.Index.Supp | Demog.Index.Supp | Demog.Index.Supp | 5303 | 5303 | 0 | 0 | 57 | 1 | 0 | 2.7923900000000001498 | 0.22320300000000001250 | AK\|0 | 0 | 0.385545010846291 |
| Old legacy Demog.Index.Supp vs new explicit Demog.Index.Supp.State | Demog.Index.Supp | Demog.Index.Supp.State | 4537 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001243450 | 0.00000000000000258504 | AK\|1 | 0.41873096170812 | 0.418730961708119 |

### Current-code statestats recomputation check

This recomputes `calc_ejscreen_stats()` locally from the saved ACS2022 `blockgroupstats` without saving outputs. It checks whether the current code would still write the stale/different legacy demographic-index lookup columns. `diff_gt_tolerance == 0` for `Demog.Index` and `Demog.Index.Supp` here means the current code path is compatible; the already-saved S3 ACS2022 `statestats.csv` should be regenerated before treating its demographic-index differences as a code problem.

| column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| drinking | 939 | 817 | 102 | 0 | 3779 | 3993 | 102 | 84.0771000000000015007 | 0.19477700000000000569 | AK\|36 | 0.025524695385474 | 0 |
| Demog.Index | 4933 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000173869 | AK\|1 | 0.240585372647978 | 0.240585372647977 |
| Demog.Index.Supp | 5013 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001243450 | 0.00000000000000230851 | AK\|1 | 0.41873096170812 | 0.418730961708119 |

### Drinking lookup NA/zero pattern

| comparison | column | rows_compared | ref_na_candidate_na | ref_na_candidate_zero | ref_na_candidate_nonzero | ref_zero_candidate_na | ref_zero_candidate_zero | ref_zero_candidate_nonzero | both_non_na_equal | both_non_na_diff_gt_tolerance | max_abs_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM usastats vs EPA national lookup | drinking | 102 | 0 | 0 | 0 | 0 | 74 | 0 | 102 | 0 | 0.00000 |
| 2026 pipeline usastats vs EPA national lookup | drinking | 102 | 0 | 0 | 0 | 0 | 74 | 0 | 86 | 16 | 2.71123 |
| 2026 pipeline usastats vs 2025 EJAM usastats | drinking | 102 | 0 | 0 | 0 | 0 | 74 | 0 | 86 | 16 | 2.71123 |
| 2025 EJAM statestats vs EPA state lookup | drinking | 5304 | 102 | 0 | 0 | 0 | 3779 | 0 | 5202 | 0 | 0.00000 |
| 2026 pipeline statestats vs EPA state lookup | drinking | 5304 | 0 | 102 | 0 | 0 | 3779 | 0 | 4385 | 817 | 84.07710 |
| 2026 pipeline statestats vs 2025 EJAM statestats | drinking | 5304 | 0 | 102 | 0 | 0 | 3779 | 0 | 4385 | 817 | 84.07710 |

### Drinking lookup NA/zero pattern by state lookup region

| comparison | region | rows | ref_na_candidate_zero | ref_zero_candidate_na | na_mismatch | diff_gt_tolerance |
| --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM statestats vs EPA state lookup | AK | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | AL | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | AR | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | AZ | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | CA | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | CO | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | CT | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | DC | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | DE | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | FL | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | GA | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | HI | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | IA | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | ID | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | IL | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | IN | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | KS | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | KY | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | LA | 102 | 0 | 0 | 0 | 0 |
| 2025 EJAM statestats vs EPA state lookup | MA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | PR | 102 | 102 | 0 | 102 | 0 |
| 2026 pipeline statestats vs EPA state lookup | WV | 102 | 0 | 0 | 0 | 80 |
| 2026 pipeline statestats vs EPA state lookup | ID | 102 | 0 | 0 | 0 | 51 |
| 2026 pipeline statestats vs EPA state lookup | AK | 102 | 0 | 0 | 0 | 38 |
| 2026 pipeline statestats vs EPA state lookup | LA | 102 | 0 | 0 | 0 | 35 |
| 2026 pipeline statestats vs EPA state lookup | OK | 102 | 0 | 0 | 0 | 35 |
| 2026 pipeline statestats vs EPA state lookup | FL | 102 | 0 | 0 | 0 | 27 |
| 2026 pipeline statestats vs EPA state lookup | AL | 102 | 0 | 0 | 0 | 24 |
| 2026 pipeline statestats vs EPA state lookup | ME | 102 | 0 | 0 | 0 | 24 |
| 2026 pipeline statestats vs EPA state lookup | MS | 102 | 0 | 0 | 0 | 23 |
| 2026 pipeline statestats vs EPA state lookup | VT | 102 | 0 | 0 | 0 | 23 |
| 2026 pipeline statestats vs EPA state lookup | AR | 102 | 0 | 0 | 0 | 22 |
| 2026 pipeline statestats vs EPA state lookup | TN | 102 | 0 | 0 | 0 | 22 |
| 2026 pipeline statestats vs EPA state lookup | NM | 102 | 0 | 0 | 0 | 20 |
| 2026 pipeline statestats vs EPA state lookup | OR | 102 | 0 | 0 | 0 | 18 |
| 2026 pipeline statestats vs EPA state lookup | WI | 102 | 0 | 0 | 0 | 18 |
| 2026 pipeline statestats vs EPA state lookup | KS | 102 | 0 | 0 | 0 | 17 |
| 2026 pipeline statestats vs EPA state lookup | TX | 102 | 0 | 0 | 0 | 17 |
| 2026 pipeline statestats vs EPA state lookup | MA | 102 | 0 | 0 | 0 | 16 |
| 2026 pipeline statestats vs EPA state lookup | MT | 102 | 0 | 0 | 0 | 16 |
| 2026 pipeline statestats vs 2025 EJAM statestats | PR | 102 | 102 | 0 | 102 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | WV | 102 | 0 | 0 | 0 | 80 |
| 2026 pipeline statestats vs 2025 EJAM statestats | ID | 102 | 0 | 0 | 0 | 51 |
| 2026 pipeline statestats vs 2025 EJAM statestats | AK | 102 | 0 | 0 | 0 | 38 |
| 2026 pipeline statestats vs 2025 EJAM statestats | LA | 102 | 0 | 0 | 0 | 35 |
| 2026 pipeline statestats vs 2025 EJAM statestats | OK | 102 | 0 | 0 | 0 | 35 |
| 2026 pipeline statestats vs 2025 EJAM statestats | FL | 102 | 0 | 0 | 0 | 27 |
| 2026 pipeline statestats vs 2025 EJAM statestats | AL | 102 | 0 | 0 | 0 | 24 |
| 2026 pipeline statestats vs 2025 EJAM statestats | ME | 102 | 0 | 0 | 0 | 24 |
| 2026 pipeline statestats vs 2025 EJAM statestats | MS | 102 | 0 | 0 | 0 | 23 |
| 2026 pipeline statestats vs 2025 EJAM statestats | VT | 102 | 0 | 0 | 0 | 23 |
| 2026 pipeline statestats vs 2025 EJAM statestats | AR | 102 | 0 | 0 | 0 | 22 |
| 2026 pipeline statestats vs 2025 EJAM statestats | TN | 102 | 0 | 0 | 0 | 22 |
| 2026 pipeline statestats vs 2025 EJAM statestats | NM | 102 | 0 | 0 | 0 | 20 |
| 2026 pipeline statestats vs 2025 EJAM statestats | OR | 102 | 0 | 0 | 0 | 18 |
| 2026 pipeline statestats vs 2025 EJAM statestats | WI | 102 | 0 | 0 | 0 | 18 |
| 2026 pipeline statestats vs 2025 EJAM statestats | KS | 102 | 0 | 0 | 0 | 17 |
| 2026 pipeline statestats vs 2025 EJAM statestats | TX | 102 | 0 | 0 | 0 | 17 |
| 2026 pipeline statestats vs 2025 EJAM statestats | MA | 102 | 0 | 0 | 0 | 16 |
| 2026 pipeline statestats vs 2025 EJAM statestats | MT | 102 | 0 | 0 | 0 | 16 |

### Drinking raw-vs-lookup state link

This joins the state-level raw-score missing-to-zero pattern to the state lookup-table differences. It helps distinguish the PR all-missing lookup case from non-PR cutoff shifts caused by treating EPA-missing raw drinking rows as zero.

| region | raw_rows | raw_ref_na_pipeline_zero | raw_na_mismatch | raw_diff_gt_tolerance | lookup_rows | lookup_ref_na_pipeline_zero | lookup_na_mismatch | lookup_diff_gt_tolerance |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PR | 2555 | 2555 | 2555 | 0 | 102 | 102 | 102 | 0 |
| WV | 1639 | 234 | 234 | 0 | 102 | 0 | 0 | 80 |
| ID | 1284 | 78 | 78 | 0 | 102 | 0 | 0 | 51 |
| AK | 504 | 61 | 61 | 0 | 102 | 0 | 0 | 38 |
| LA | 4294 | 609 | 609 | 0 | 102 | 0 | 0 | 35 |
| OK | 3374 | 337 | 337 | 0 | 102 | 0 | 0 | 35 |
| FL | 13388 | 991 | 991 | 0 | 102 | 0 | 0 | 27 |
| AL | 3925 | 442 | 442 | 0 | 102 | 0 | 0 | 24 |
| ME | 1184 | 302 | 302 | 0 | 102 | 0 | 0 | 24 |
| MS | 2445 | 123 | 123 | 0 | 102 | 0 | 0 | 23 |
| VT | 552 | 100 | 100 | 0 | 102 | 0 | 0 | 23 |
| TN | 4562 | 86 | 86 | 0 | 102 | 0 | 0 | 22 |
| AR | 2294 | 7 | 7 | 0 | 102 | 0 | 0 | 22 |
| NM | 1614 | 65 | 65 | 0 | 102 | 0 | 0 | 20 |
| WI | 4692 | 606 | 606 | 0 | 102 | 0 | 0 | 18 |
| OR | 2970 | 165 | 165 | 0 | 102 | 0 | 0 | 18 |
| TX | 18638 | 234 | 234 | 0 | 102 | 0 | 0 | 17 |
| KS | 2461 | 39 | 39 | 0 | 102 | 0 | 0 | 17 |
| NJ | 6599 | 262 | 262 | 0 | 102 | 0 | 0 | 16 |
| MA | 5116 | 207 | 207 | 0 | 102 | 0 | 0 | 16 |
| MT | 900 | 85 | 85 | 0 | 102 | 0 | 0 | 16 |
| WY | 457 | 23 | 23 | 0 | 102 | 0 | 0 | 16 |
| OH | 9472 | 1031 | 1031 | 0 | 102 | 0 | 0 | 15 |
| NC | 7111 | 596 | 596 | 0 | 102 | 0 | 0 | 14 |
| CT | 2717 | 166 | 166 | 0 | 102 | 0 | 0 | 14 |
| UT | 2020 | 14 | 14 | 0 | 102 | 0 | 0 | 14 |
| NY | 16070 | 930 | 930 | 0 | 102 | 0 | 0 | 13 |
| DE | 706 | 78 | 78 | 0 | 102 | 0 | 0 | 13 |
| GA | 7446 | 952 | 952 | 0 | 102 | 0 | 0 | 12 |
| NH | 997 | 69 | 69 | 0 | 102 | 0 | 0 | 12 |
| MI | 8386 | 1283 | 1283 | 0 | 102 | 0 | 0 | 11 |
| PA | 10173 | 653 | 653 | 0 | 102 | 0 | 0 | 11 |
| IN | 5290 | 641 | 641 | 0 | 102 | 0 | 0 | 11 |
| CO | 4058 | 226 | 226 | 0 | 102 | 0 | 0 | 11 |
| AZ | 4773 | 106 | 106 | 0 | 102 | 0 | 0 | 11 |
| ND | 632 | 49 | 49 | 0 | 102 | 0 | 0 | 10 |
| SC | 3408 | 511 | 511 | 0 | 102 | 0 | 0 | 9 |
| WA | 5311 | 85 | 85 | 0 | 102 | 0 | 0 | 9 |
| KY | 3581 | 29 | 29 | 0 | 102 | 0 | 0 | 9 |
| MN | 4706 | 540 | 540 | 0 | 102 | 0 | 0 | 8 |

### National export percentile fields

This checks looked-up national percentile fields in the EPA national blockgroup output against the pipeline `ejscreen_export`. It is separate from the lookup-table cutoff comparisons above.

| comparison | column | rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026 pipeline ejscreen_export vs EPA national BG export | P_DWATER | 242336 | 50047 | 19208 | 0 | 163948 | 183156 | 19208 | 3.000000000000000000 | 0.324392000000000013671 | 010010208031 |  | 0 |
| 2026 pipeline ejscreen_export vs EPA national BG export | D5_DWATER | 242336 | 50046 | 19208 | 0 | 163949 | 183157 | 19208 | 9.124990000000000379 | 0.535565999999999986514 | 010010201001 | 226.69057711585 | 226.69057711586 |
| 2026 pipeline ejscreen_export vs EPA national BG export | D2_DWATER | 242336 | 49825 | 19208 | 0 | 164195 | 183403 | 19208 | 10.980499999999999261 | 0.418196000000000012164 | 010010201001 | 136.629084421248 | 136.629084421248 |
| 2026 pipeline ejscreen_export vs EPA national BG export | P_D2_DWATER | 242336 | 44629 | 19208 | 0 | 164195 | 183403 | 19208 | 3.000000000000000000 | 0.276500000000000023537 | 010010201001 | 90 | 91 |
| 2026 pipeline ejscreen_export vs EPA national BG export | P_D5_DWATER | 242336 | 44452 | 19208 | 0 | 163949 | 183157 | 19208 | 3.000000000000000000 | 0.278722999999999998533 | 010010202001 | 92 | 93 |
| 2026 pipeline ejscreen_export vs EPA national BG export | DISABILITY | 242336 | 29 | 0 | 0 | 1996 | 1996 | 0 | 1.000000000000000000 | 0.000119668999999999996 | 060376024043 | 215 | 214 |
| 2026 pipeline ejscreen_export vs EPA national BG export | P_DISABILITYPCT | 242336 | 4 | 0 | 0 | 2420 | 2420 | 0 | 1.000000000000000000 | 0.000016506000000000001 | 060730007001 | 16 | 15 |
| 2026 pipeline ejscreen_export vs EPA national BG export | DWATER | 242336 | 0 | 19208 | 0 | 163948 | 183156 | 19208 | 0.000000000000511591 | 0.000000000000000417556 | 010010208031 |  | 0 |

### State-demographic export raw-field crosswalk

The EPA state-percentile BG file uses some column names differently from the national BG file. This crosswalk compares the EPA state-demographic raw fields to the pipeline's explicit `*ST` export fields, rather than comparing the same names blindly.

| label | ref_column | candidate_column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EPA statepct DEMOGIDX_2 vs pipeline DEMOGIDX_2ST | DEMOGIDX_2 | DEMOGIDX_2ST | 181332 | 0 | 0 | 0 | 2423 | 2423 | 0 | 0.0000000000000328626 | 0.00000000000000241172 | 010010201001 | 1.36295872299704 | 1.36295872299704 |
| EPA statepct DEMOGIDX_5 vs pipeline DEMOGIDX_5ST | DEMOGIDX_5 | DEMOGIDX_5ST | 213559 | 0 | 0 | 0 | 208 | 208 | 0 | 0.0000000000001243450 | 0.00000000000000295991 | 010010201001 | 2.24944381790889 | 2.24944381790889 |

## 3. EJ Index Consequences

EJ index diagnostics should be read after the raw and lookup diagnostics above. In the current reports, the large EJ-index differences are concentrated in drinking-related EJ index lookup columns and a small number of state proximity.npl EJ-index lookup rows. The likely upstream causes to confirm before changing code are: drinking-water missing-vs-zero behavior, state demographic-index lookup column semantics, and any EPA lookup-table rounding/tied-minimum conventions.

### EJ-index lookup columns with substantive differences or NA/zero mismatches

| comparison | varlist | column | rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_ej_supp_state | state.EJ.DISPARITY.drinking.supp | 5304 | 1399 | 102 | 0 | 3779 | 3994 | 102 | 95.87130 | 1.95964000 | AK\|100 | 348.963692037562 | 357.272351371789 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_ej_state | state.EJ.DISPARITY.drinking.eo | 5304 | 1386 | 102 | 0 | 3783 | 3998 | 102 | 68.43380 | 1.90431000 | AK\|100 | 408.041497814612 | 412.248111194145 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_ej_supp_state | state.EJ.DISPARITY.proximity.npl.supp | 5304 | 45 | 0 | 0 | 3120 | 3120 | 0 | 5.88806 | 0.00511645 | AK\|100 | 399.64151445465 | 399.641514454651 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_ej_state | state.EJ.DISPARITY.proximity.npl.eo | 5304 | 41 | 0 | 0 | 3128 | 3128 | 0 | 5.25578 | 0.00492712 | AK\|100 | 458.565996085895 | 458.565996085895 |
| 2026 pipeline usastats vs 2025 EJAM usastats | names_ej_supp | EJ.DISPARITY.drinking.supp | 102 | 28 | 0 | 0 | 74 | 76 | 0 | 67.49770 | 2.53252000 | USA\|100 | 541.412935597475 | 547.234580066274 |
| 2026 pipeline usastats vs 2025 EJAM usastats | names_ej | EJ.DISPARITY.drinking.eo | 102 | 27 | 0 | 0 | 74 | 76 | 0 | 26.67970 | 2.06901000 | USA\|100 | 385.127445266888 | 385.127445266888 |
| 2026 pipeline usastats vs EPA national lookup | names_ej_supp | EJ.DISPARITY.drinking.supp | 102 | 28 | 0 | 0 | 74 | 76 | 0 | 67.49770 | 2.53252000 | USA\|100 | 541.412935597475 | 547.234580066274 |
| 2026 pipeline usastats vs EPA national lookup | names_ej | EJ.DISPARITY.drinking.eo | 102 | 27 | 0 | 0 | 74 | 76 | 0 | 26.67970 | 2.06901000 | USA\|100 | 385.127445266888 | 385.127445266888 |

## Working Interpretation

- `usastats` and `statestats` from EJAM v2.32.8.001 replicate the EPA lookup tables exactly on shared lookup columns, so the old package lookup tables are a valid proxy for EPA shared lookup behavior.
- The raw blockgroup demographic index fields replicate at blockgroup level to floating-point tolerance. Large demographic-index lookup differences, if present, are therefore lookup-table semantics or stale-output issues rather than raw blockgroup formula failures.
- Drinking-water is the main raw-score difference against EPA: EPA has missing raw values in many block groups where EJAM stores zero. That propagates into lookup tables and drinking EJ-index columns.
- In the state drinking lookup table, PR is the all-missing special case: EPA/old have 102 missing drinking lookup rows for PR, while the current pipeline has zero-valued rows. Other state drinking lookup differences are cutoff shifts from adding zero-valued raw rows that EPA treated as missing.
- The national EPA export percentiles for the four demographic index fields match the pipeline exactly. The state-percentile EPA export file should not be compared by same-named demographic columns without a crosswalk, because the state file uses `DEMOGIDX_2`/`DEMOGIDX_5` where the pipeline uses explicit `DEMOGIDX_2ST`/`DEMOGIDX_5ST` fields.
- A current-code recomputation of `statestats` from the saved ACS2022 `blockgroupstats` makes the legacy `Demog.Index` and `Demog.Index.Supp` lookup columns match the old/EPA state-specific values to tolerance. The S3 ACS2022 `statestats.csv` demographic-index lookup difference is therefore stale saved output, not a remaining code defect.
- `pctunemployed` and disability raw differences are small or already characterized: unemployment is mostly denominator-zero NA handling, and disability count/universe differences are +/-1 apportionment rounding.
- Language and health-insurance differences are important for old-EJAM replication, but the v2.5.0 validation decision already treats those as deliberate/nonblocking for EJAM datasets.

## Decision Points Before Any Code Change

- Confirm whether ACS22 replication should preserve EPA missing `drinking` values or keep EJAM zero values where the current pipeline produces zero.
- Confirm whether current ACS22 pipeline `statestats` output was regenerated after the `Demog.Index`/`Demog.Index.State` compatibility fix; if not, rerun before considering a code change.
- Confirm whether state lookup differences should target exact EPA lookup-table replication or only acceptable downstream percentile behavior in current EJAM outputs.
- Do not change tied-zero, interpolation, rounding, Puerto Rico inclusion, or missing-value percentile behavior until the specific upstream cause is confirmed.

## Additional Findings: Raw Scores and State Percentile Precision

These checks were run after the initial inventory above, using the archived EPA national/state BG files, archived EPA lookup files, the EJAM v2.32.8.001 package data, and the current ACS22 pipeline outputs copied locally under `/private/tmp/acs22_rawdiag`.

### Raw-score status

- The large raw-score issues are now narrow and mostly characterized.
- `drinking` is the main EPA-vs-current raw mismatch: EPA has 19,208 missing `DWATER` rows where the current ACS22 pipeline `blockgroupstats` has `drinking == 0`. The current ACS22 `bg_envirodata.csv` source file is provisional and was copied from packaged `EJAM::blockgroupstats`, so this mismatch was inherited rather than newly created by the May 2026 pipeline code.
- `pctunemployed` differs only by zero-denominator handling: 2,165 rows are EPA zero and current pipeline `NA`; finite nonmissing values match to floating-point tolerance.
- `disability` and `disab_universe` differ only by +/-1 count in a few dozen rows.
- `proximity.npdes` differences are only tiny floating-point drift in 29 Louisiana rows, max about `5.25e-06` on very large values.
- All four demographic index raw fields replicate to tolerance. The many exact floating-point differences in `Demog.Index`, `Demog.Index.Supp`, `Demog.Index.State`, and `Demog.Index.Supp.State` are about `1e-13` or smaller and are not substantive raw-score problems.

### Drinking-water lookup and EJ-index implications

- Old `bgej.arrow` from the `ejamdata` release `v2.32.8.001` matches EPA drinking-water EJ index missingness and values for shared drinking EJ-index fields. For EPA rows where `DWATER` is missing, old `bgej` drinking EJ-index values are also missing.
- If current ACS22 `blockgroupstats$drinking` is changed in memory to `NA` for the EPA missing `DWATER` rows, the recomputed raw `usastats$drinking` and `statestats$drinking` lookup cutoffs match the old/EPA lookup tables. This confirms the raw drinking lookup-table mismatch is driven by missing-vs-zero treatment, not by the percentile lookup function.
- That in-memory `drinking := NA` test does not fully eliminate all downstream drinking EJ-index differences, because some remaining differences are per-blockgroup percentile assignment issues at tied or rounded lookup cutoffs.

### EPA per-blockgroup percentile assignment is not fully recoverable from rounded public CSV values

The current evidence does **not** support changing EJAM globally to an upper-bound tied-percentile rule.

Using the EPA raw values and EPA lookup tables directly:

| scope | indicator | EPA nonmissing rows | lower-tie mismatches | upper-tie mismatches | max mismatch under lower rule | max mismatch under upper rule |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| national BG percentiles | `DWATER` | 223,128 | 0 | 29,892 | 0 | 5 |
| state BG percentiles | `DWATER` | 223,128 | 10 | 33,476 | 1 | 42 |
| state BG percentiles | `PNPL` | 241,389 | 99 | 104 | 2 | 3 |

Interpretation:

- EPA national drinking-water blockgroup percentiles match the existing lower-tie rule exactly when EPA raw values are looked up in the EPA national lookup table.
- EPA state drinking-water percentiles also match the lower-tie rule almost perfectly: only 10 rows mismatch.
- A simple upper-tie rule would make replication much worse, especially for `DWATER`.
- The small remaining state percentile mismatches appear to be precision/rounding artifacts in the published EPA CSVs, not a broad tied-percentile convention.

Example:

- For NY, the EPA state lookup table has `DWATER == 10` for percentiles 56 through 98.
- For BGs `360050051002` and `360050051003`, the published EPA state-percentile BG file shows `DWATER == 10` and `P_DWATER == 98`.
- Looking up the published value `10` in the published lookup table with the current lower-tie rule gives 56, not 98.
- Across the whole EPA state-percentile file, however, only 10 `DWATER` rows behave this way, so this is best treated as an EPA public-file precision artifact unless more evidence says otherwise.

### State `proximity.npl` residual differences

The largest residual state `proximity.npl` EJ-index differences are concentrated in Nebraska and are also consistent with precision around tied-looking cutoff values.

- EPA/old `PNPL` values around 11 sometimes retain tiny binary floating differences such as `10.999999999999998`.
- The current ACS22 pipeline `blockgroupstats` value for those rows is often exactly `11`.
- The EPA state lookup table has Nebraska `PNPL` cutoff rows:
  - percentile 91: `9.3299646968707446`
  - percentiles 92 through 97: displayed/stored as `11`
  - percentile 98: `11.10845108784458`
- EPA per-blockgroup state percentiles for some Nebraska rows are 93 or 94 while a direct lookup from the published raw/lookup values gives 91 or 92.
- This again points to EPA internal precision or prior intermediate values that are not fully preserved in the public CSVs.

### `bgej` replication context

The `bgej` dataset should not be skipped in ACS22 replication diagnostics. The old `bgej.arrow` asset from the `ejamdata` release `v2.32.8.001` was included in the comparisons.

- EJAM v2.32.8.001 `bgej.arrow` exactly matches EPA v2.32 national BG EJ-index fields on shared national EJ-index columns.
- EJAM v2.32.8.001 `bgej.arrow` exactly matches EPA v2.32 state-percentile BG EJ-index fields on shared state EJ-index columns.
- Current ACS22 pipeline `bgej` vs old `bgej.arrow` has only 6 columns with differences above `1e-6`:
  - `EJ.DISPARITY.drinking.eo`
  - `EJ.DISPARITY.drinking.supp`
  - `state.EJ.DISPARITY.drinking.eo`
  - `state.EJ.DISPARITY.drinking.supp`
  - `state.EJ.DISPARITY.proximity.npl.eo`
  - `state.EJ.DISPARITY.proximity.npl.supp`
- All other current-vs-old `bgej` differences are floating-point noise below the `1e-6` validation tolerance.
- The current-vs-old drinking EJ-index differences follow from the `drinking` missing-vs-zero raw-score issue and then from downstream per-BG percentile assignment.
- The current-vs-old state `proximity.npl` EJ-index differences are small in count but can be sizable for individual BGs because a 1- or 2-percentile shift is multiplied by a state demographic index.

### Current working interpretation

- For raw scores, the only large ACS22 EPA replication issue still needing a policy decision is `drinking` missing-vs-zero.
- For lookup tables, setting EPA-missing drinking rows to `NA` is enough to replicate old/EPA raw drinking lookup cutoffs.
- For per-blockgroup percentile/EJ-index replication, exact EPA replication may require EPA-provided per-BG percentile fields as the reference, because the public raw and lookup CSVs do not contain enough precision to reproduce every state percentile assignment exactly.
- No tied-zero, upper-tie, rounding, interpolation, PR-inclusion, or missing-value behavior should be changed yet based on these diagnostics.
