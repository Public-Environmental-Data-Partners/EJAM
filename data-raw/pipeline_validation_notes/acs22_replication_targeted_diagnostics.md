# ACS22 Replication Targeted Diagnostics

Created: 2026-05-30 17:34:12.905534

This is a one-time diagnostic note. It does not change annual pipeline behavior.
The ordering here follows the current debugging priority: raw scores first, percentile lookup behavior second, EJ indexes last.

Important provenance distinction: 2025-vs-2024 comparisons use EJAM v2.32.8.001 package data as-is and should show the historical drinking-water NA-to-zero problem. 2026-vs-2024 comparisons should use ACS22 pipeline outputs built from corrected `bg_envirodata`, where EPA-style drinking-water `NA` values are preserved before blockgroupstats, lookup tables, bgej, and EJScreen exports are created.

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
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_e | drinking | 242336 | 0 | 0 | 19208 | 183156 | 163948 | 19208 | 0.00000000000051159100 | 0.000000000000000417556 | 010010208031 | 0 |  |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_community | percapincome | 242336 | 0 | 0 | 2418 | 234 | 1 | 2418 | 0.00000000000000000000 | 0.000000000000000000000 | 010039900000 | -666666666 |  |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | names_d | pctunemployed | 242336 | 0 | 424 | 2589 | 54571 | 52406 | 2165 | 0.00000000000000102696 | 0.000000000000000151557 | 010010201002 | 0.025210084033613 | 0.0252100840336134 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_health_count | disability | 243022 | 29 | 686 | 686 | 1996 | 1996 | 0 | 1.00000000000000000000 | 0.000119668999999999996 | 060376024043 | 215 | 214 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_e | proximity.npdes | 243022 | 29 | 2583 | 2583 | 18484 | 18484 | 0 | 0.00000524521000000000 | 0.000000000606197000000 | 010010201001 | 264.347574841757 | 264.347574841757 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_health_count | disab_universe | 243022 | 23 | 686 | 686 | 1807 | 1807 | 0 | 1.00000000000000000000 | 0.000094909500000000003 | 040131166212 | 3001 | 3000 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | names_d | pctunemployed | 243022 | 0 | 1110 | 3275 | 54571 | 52406 | 2165 | 0.00000000000000102696 | 0.000000000000000151557 | 010010201002 | 0.025210084033613 | 0.0252100840336134 |

### Four demographic index raw-score fields

The blockgroup raw-score fields are shown separately because many exact floating-point differences are harmless. `diff_gt_tolerance == 0` means the field is not a substantive raw-score replication problem at the 1e-6 threshold.

| comparison | column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | max_abs_diff | mean_abs_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index | 0 | 0 | 0 | 0 | 2421 | 2421 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index.State | 0 | 0 | 0 | 0 | 2423 | 2423 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp | 0 | 0 | 0 | 0 | 1 | 1 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp.State | 0 | 0 | 0 | 0 | 208 | 208 | 0.0000000000000000000 | 0.00000000000000000000 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index | 212811 | 0 | 0 | 0 | 2421 | 2421 | 0.0000000000000142109 | 0.00000000000000289887 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index.State | 194181 | 0 | 0 | 0 | 2423 | 2423 | 0.0000000000000333067 | 0.00000000000000250632 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index.Supp | 242334 | 0 | 0 | 0 | 1 | 1 | 0.0000000000001718630 | 0.00000000000007976570 |
| 2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats | Demog.Index.Supp.State | 213121 | 0 | 0 | 0 | 208 | 208 | 0.0000000000001341150 | 0.00000000000000301727 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index | 212811 | 0 | 686 | 686 | 2421 | 2421 | 0.0000000000000142109 | 0.00000000000000289887 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index.State | 194181 | 0 | 686 | 686 | 2423 | 2423 | 0.0000000000000333067 | 0.00000000000000250632 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp | 242334 | 0 | 686 | 686 | 1 | 1 | 0.0000000000001718630 | 0.00000000000007976570 |
| 2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG | Demog.Index.Supp.State | 213121 | 0 | 686 | 686 | 208 | 208 | 0.0000000000001341150 | 0.00000000000000301727 |

### Raw value pattern diagnostics for the main non-replicated fields

| comparison | column | rows_compared | ref_na_candidate_na | ref_na_candidate_zero | ref_na_candidate_nonzero | ref_zero_candidate_na | ref_zero_candidate_zero | ref_zero_candidate_nonzero | both_non_na_equal | both_non_na_diff_gt_tolerance | max_abs_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM vs EPA | drinking | 242336 | 0 | 19208 | 0 | 0 | 163948 | 0 | 223128 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | drinking | 243022 | 19894 | 0 | 0 | 0 | 163948 | 0 | 223128 | 0 | 0.00000000000051159100 |
| 2026 pipeline vs 2025 EJAM | drinking | 242336 | 0 | 0 | 0 | 19208 | 163948 | 0 | 223128 | 0 | 0.00000000000051159100 |
| 2025 EJAM vs EPA | pctunemployed | 242336 | 424 | 0 | 0 | 0 | 54571 | 0 | 241912 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | pctunemployed | 243022 | 1110 | 0 | 0 | 2165 | 52406 | 0 | 239747 | 0 | 0.00000000000000102696 |
| 2026 pipeline vs 2025 EJAM | pctunemployed | 242336 | 424 | 0 | 0 | 2165 | 52406 | 0 | 239747 | 0 | 0.00000000000000102696 |
| 2026 pipeline vs 2025 EJAM | pctnohealthinsurance | 242336 | 0 | 1819 | 1631 | 0 | 1569 | 3106 | 1641 | 237245 | 0.98999999999999999112 |
| 2026 pipeline vs 2025 EJAM | percapincome | 242336 | 0 | 0 | 0 | 233 | 1 | 0 | 239918 | 0 | 0.00000000000000000000 |
| 2025 EJAM vs EPA | disab_universe | 242336 | 0 | 0 | 0 | 0 | 1807 | 0 | 242336 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | disab_universe | 243022 | 686 | 0 | 0 | 0 | 1807 | 0 | 242313 | 23 | 1.00000000000000000000 |
| 2026 pipeline vs 2025 EJAM | disab_universe | 242336 | 0 | 0 | 0 | 0 | 1807 | 0 | 242313 | 23 | 1.00000000000000000000 |
| 2025 EJAM vs EPA | disability | 242336 | 0 | 0 | 0 | 0 | 1996 | 0 | 242336 | 0 | 0.00000000000000000000 |
| 2026 pipeline vs EPA | disability | 243022 | 686 | 0 | 0 | 0 | 1996 | 0 | 242307 | 29 | 1.00000000000000000000 |
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
| 2026 pipeline vs EPA | AK | 504 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | AL | 3925 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | AR | 2294 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | AS | 77 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | AZ | 4773 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | CA | 25607 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | CO | 4058 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | CT | 2717 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | DC | 571 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | DE | 706 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | FL | 13388 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | GA | 7446 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | GU | 58 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | HI | 1083 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | IA | 2703 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | ID | 1284 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | IL | 9898 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | IN | 5290 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | KS | 2461 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs EPA | KY | 3581 | 0 | 0 | 0 | 0 |
| 2026 pipeline vs 2025 EJAM | PR | 2555 | 0 | 2555 | 2555 | 0 |
| 2026 pipeline vs 2025 EJAM | MI | 8386 | 0 | 1283 | 1283 | 0 |
| 2026 pipeline vs 2025 EJAM | OH | 9472 | 0 | 1031 | 1031 | 0 |
| 2026 pipeline vs 2025 EJAM | FL | 13388 | 0 | 991 | 991 | 0 |
| 2026 pipeline vs 2025 EJAM | VA | 5963 | 0 | 990 | 990 | 0 |
| 2026 pipeline vs 2025 EJAM | GA | 7446 | 0 | 952 | 952 | 0 |
| 2026 pipeline vs 2025 EJAM | NY | 16070 | 0 | 930 | 930 | 0 |
| 2026 pipeline vs 2025 EJAM | PA | 10173 | 0 | 653 | 653 | 0 |
| 2026 pipeline vs 2025 EJAM | IN | 5290 | 0 | 641 | 641 | 0 |
| 2026 pipeline vs 2025 EJAM | LA | 4294 | 0 | 609 | 609 | 0 |
| 2026 pipeline vs 2025 EJAM | WI | 4692 | 0 | 606 | 606 | 0 |
| 2026 pipeline vs 2025 EJAM | NC | 7111 | 0 | 596 | 596 | 0 |
| 2026 pipeline vs 2025 EJAM | MN | 4706 | 0 | 540 | 540 | 0 |
| 2026 pipeline vs 2025 EJAM | SC | 3408 | 0 | 511 | 511 | 0 |
| 2026 pipeline vs 2025 EJAM | CA | 25607 | 0 | 508 | 508 | 0 |
| 2026 pipeline vs 2025 EJAM | MD | 4079 | 0 | 494 | 494 | 0 |
| 2026 pipeline vs 2025 EJAM | AL | 3925 | 0 | 442 | 442 | 0 |
| 2026 pipeline vs 2025 EJAM | MO | 5031 | 0 | 402 | 402 | 0 |
| 2026 pipeline vs 2025 EJAM | IL | 9898 | 0 | 353 | 353 | 0 |
| 2026 pipeline vs 2025 EJAM | OK | 3374 | 0 | 337 | 337 | 0 |

## 2. Percentile Lookup Tables

### Raw-score lookup columns with substantive differences or NA/zero mismatches

| comparison | varlist | column | rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_d_subgroups | pctnhwa | 5304 | 1 | 0 | 0 | 210 | 209 | 0 | 0.0316869000 | 0.0000059741400 | AK\|1 | 0.00531427081805888 | 0.00531427081805888 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_e | proximity.npdes | 5304 | 1 | 102 | 102 | 379 | 379 | 0 | 0.0000038147 | 0.0000000011311 | AL\|1 | 1.41282813e-06 | 1.4128281298e-06 |
| 2026 pipeline statestats vs EPA state lookup | names_e | proximity.npdes | 5304 | 1 | 102 | 102 | 379 | 379 | 0 | 0.0000038147 | 0.0000000011311 | AL\|1 | 1.41282813e-06 | 1.4128281298e-06 |
| 2026 pipeline usastats vs 2025 EJAM usastats | names_e | proximity.npdes | 102 | 1 | 0 | 0 | 8 | 8 | 0 | 0.0000038147 | 0.0000000376663 | USA\|10 | 0.003104158243576 | 0.00310415824357621 |
| 2026 pipeline usastats vs EPA national lookup | names_e | proximity.npdes | 102 | 1 | 0 | 0 | 8 | 8 | 0 | 0.0000038147 | 0.0000000376663 | USA\|10 | 0.003104158243576 | 0.00310415824357621 |

### State lookup demographic-index naming/compatibility crosswalk

| label | ref_column | candidate_column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EPA state Demog.Index vs old legacy Demog.Index | Demog.Index | Demog.Index | 0 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000000000 | 0.00000000000000000000 |  |  |  |
| EPA state Demog.Index vs new legacy Demog.Index | Demog.Index | Demog.Index | 4124 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000206955 | AK\|100 | 4.67924485801934 | 4.67924485801933 |
| EPA state Demog.Index vs new explicit Demog.Index.State | Demog.Index | Demog.Index.State | 4124 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000206955 | AK\|100 | 4.67924485801934 | 4.67924485801933 |
| EPA state Demog.Index.Supp vs old legacy Demog.Index.Supp | Demog.Index.Supp | Demog.Index.Supp | 0 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000000000000 | 0.00000000000000000000 |  |  |  |
| EPA state Demog.Index.Supp vs new legacy Demog.Index.Supp | Demog.Index.Supp | Demog.Index.Supp | 4563 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001341150 | 0.00000000000000263932 | AK\|1 | 0.41873096170812 | 0.418730961708119 |
| EPA state Demog.Index.Supp vs new explicit Demog.Index.Supp.State | Demog.Index.Supp | Demog.Index.Supp.State | 4563 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001341150 | 0.00000000000000263932 | AK\|1 | 0.41873096170812 | 0.418730961708119 |
| Old legacy Demog.Index vs new legacy Demog.Index | Demog.Index | Demog.Index | 4124 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000206955 | AK\|100 | 4.67924485801934 | 4.67924485801933 |
| Old legacy Demog.Index vs new explicit Demog.Index.State | Demog.Index | Demog.Index.State | 4124 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000206955 | AK\|100 | 4.67924485801934 | 4.67924485801933 |
| Old legacy Demog.Index.Supp vs new legacy Demog.Index.Supp | Demog.Index.Supp | Demog.Index.Supp | 4563 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001341150 | 0.00000000000000263932 | AK\|1 | 0.41873096170812 | 0.418730961708119 |
| Old legacy Demog.Index.Supp vs new explicit Demog.Index.Supp.State | Demog.Index.Supp | Demog.Index.Supp.State | 4563 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001341150 | 0.00000000000000263932 | AK\|1 | 0.41873096170812 | 0.418730961708119 |

### Current-code statestats recomputation check

This recomputes `calc_ejscreen_stats()` locally from the saved ACS2022 `blockgroupstats` without saving outputs. It checks whether the current code would still write the stale/different legacy demographic-index lookup columns. `diff_gt_tolerance == 0` for `Demog.Index` and `Demog.Index.Supp` here means the current code path is compatible; the already-saved S3 ACS2022 `statestats.csv` should be regenerated before treating its demographic-index differences as a code problem.

| column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Demog.Index | 4988 | 0 | 0 | 0 | 76 | 76 | 0 | 0.0000000000000253131 | 0.00000000000000182781 | AK\|1 | 0.240585372647978 | 0.240585372647977 |
| Demog.Index.Supp | 5036 | 0 | 0 | 0 | 57 | 57 | 0 | 0.0000000000001341150 | 0.00000000000000236909 | AK\|1 | 0.41873096170812 | 0.41873096170812 |
| drinking | 506 | 0 | 102 | 102 | 3779 | 3779 | 0 | 0.0000000000004973800 | 0.00000000000000095966 | AK\|36 | 0.025524695385474 | 0.0255246953854739 |

### Drinking lookup NA/zero pattern

| comparison | column | rows_compared | ref_na_candidate_na | ref_na_candidate_zero | ref_na_candidate_nonzero | ref_zero_candidate_na | ref_zero_candidate_zero | ref_zero_candidate_nonzero | both_non_na_equal | both_non_na_diff_gt_tolerance | max_abs_diff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2025 EJAM usastats vs EPA national lookup | drinking | 102 | 0 | 0 | 0 | 0 | 74 | 0 | 102 | 0 | 0.0000000000000000000 |
| 2026 pipeline usastats vs EPA national lookup | drinking | 102 | 0 | 0 | 0 | 0 | 74 | 0 | 102 | 0 | 0.0000000000000102141 |
| 2026 pipeline usastats vs 2025 EJAM usastats | drinking | 102 | 0 | 0 | 0 | 0 | 74 | 0 | 102 | 0 | 0.0000000000000102141 |
| 2025 EJAM statestats vs EPA state lookup | drinking | 5304 | 102 | 0 | 0 | 0 | 3779 | 0 | 5202 | 0 | 0.0000000000000000000 |
| 2026 pipeline statestats vs EPA state lookup | drinking | 5304 | 102 | 0 | 0 | 0 | 3779 | 0 | 5202 | 0 | 0.0000000000004973800 |
| 2026 pipeline statestats vs 2025 EJAM statestats | drinking | 5304 | 102 | 0 | 0 | 0 | 3779 | 0 | 5202 | 0 | 0.0000000000004973800 |

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
| 2026 pipeline statestats vs EPA state lookup | AK | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | AL | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | AR | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | AZ | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | CA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | CO | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | CT | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | DC | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | DE | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | FL | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | GA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | HI | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | IA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | ID | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | IL | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | IN | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | KS | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | KY | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | LA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs EPA state lookup | MA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | AK | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | AL | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | AR | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | AZ | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | CA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | CO | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | CT | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | DC | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | DE | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | FL | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | GA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | HI | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | IA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | ID | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | IL | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | IN | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | KS | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | KY | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | LA | 102 | 0 | 0 | 0 | 0 |
| 2026 pipeline statestats vs 2025 EJAM statestats | MA | 102 | 0 | 0 | 0 | 0 |

### Drinking raw-vs-lookup state link

This joins the state-level raw-score missing-to-zero pattern to the state lookup-table differences. It helps distinguish the PR all-missing lookup case from non-PR cutoff shifts caused by treating EPA-missing raw drinking rows as zero.

| region | raw_rows | raw_ref_na_pipeline_zero | raw_na_mismatch | raw_diff_gt_tolerance | lookup_rows | lookup_ref_na_pipeline_zero | lookup_na_mismatch | lookup_diff_gt_tolerance |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AS | 77 | 0 | 0 | 0 |  |  |  |  |
| GU | 58 | 0 | 0 | 0 |  |  |  |  |
| MP | 135 | 0 | 0 | 0 |  |  |  |  |
| VI | 416 | 0 | 0 | 0 |  |  |  |  |
| AK | 504 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| AL | 3925 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| AR | 2294 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| AZ | 4773 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| CA | 25607 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| CO | 4058 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| CT | 2717 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| DC | 571 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| DE | 706 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| FL | 13388 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| GA | 7446 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| HI | 1083 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| IA | 2703 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| ID | 1284 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| IL | 9898 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| IN | 5290 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| KS | 2461 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| KY | 3581 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| LA | 4294 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| MA | 5116 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| MD | 4079 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| ME | 1184 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| MI | 8386 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| MN | 4706 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| MO | 5031 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| MS | 2445 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| MT | 900 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| NC | 7111 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| ND | 632 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| NE | 1648 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| NH | 997 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| NJ | 6599 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| NM | 1614 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| NV | 1963 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| NY | 16070 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |
| OH | 9472 | 0 | 0 | 0 | 102 | 0 | 0 | 0 |

### National export percentile fields

This checks looked-up national percentile fields in the EPA national blockgroup output against the pipeline `ejscreen_export`. It is separate from the lookup-table cutoff comparisons above.

| comparison | column | rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026 pipeline ejscreen_export vs EPA national BG export | DISABILITY | 243022 | 29 | 686 | 686 | 1996 | 1996 | 0 | 1 | 0.000119669 | 060376024043 | 215 | 214 |

### State-demographic export raw-field crosswalk

The EPA state-percentile BG file uses some column names differently from the national BG file. This crosswalk compares the EPA state-demographic raw fields to the pipeline's explicit `*ST` export fields, rather than comparing the same names blindly.

| label | ref_column | candidate_column | differing_rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EPA statepct DEMOGIDX_2 vs pipeline DEMOGIDX_2ST | DEMOGIDX_2 | DEMOGIDX_2ST | 195771 | 0 | 7 | 686 | 2593 | 2423 | 679 | 0.0000000000000333067 | 0.00000000000000250803 | 010010201001 | 1.36295872299704 | 1.36295872299704 |
| EPA statepct DEMOGIDX_5 vs pipeline DEMOGIDX_5ST | DEMOGIDX_5 | DEMOGIDX_5ST | 214139 | 0 | 686 | 686 | 208 | 208 | 0 | 0.0000000000001341150 | 0.00000000000000301920 | 010010201001 | 2.24944381790889 | 2.24944381790889 |

## 3. EJ Index Consequences

EJ index diagnostics should be read after the raw and lookup diagnostics above. In the current reports, the large EJ-index differences are concentrated in drinking-related EJ index lookup columns and a small number of state proximity.npl EJ-index lookup rows. The likely upstream causes to confirm before changing code are: drinking-water missing-vs-zero behavior, state demographic-index lookup column semantics, and any EPA lookup-table rounding/tied-minimum conventions.

### EJ-index lookup columns with substantive differences or NA/zero mismatches

| comparison | varlist | column | rows | diff_gt_tolerance | na_ref | na_pipeline | zero_ref | zero_pipeline | na_mismatch | max_abs_diff | mean_abs_diff | example_id | example_ref | example_pipeline |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_ej_supp_state | state.EJ.DISPARITY.proximity.npl.supp | 5304 | 45 | 0 | 0 | 3120 | 3120 | 0 | 5.88806 | 0.00511645 | AK\|100 | 399.64151445465 | 399.641514454651 |
| 2026 pipeline statestats vs 2025 EJAM statestats | names_ej_state | state.EJ.DISPARITY.proximity.npl.eo | 5304 | 41 | 0 | 0 | 3128 | 3128 | 0 | 5.25578 | 0.00492712 | AK\|100 | 458.565996085895 | 458.565996085895 |

## Working Interpretation

- `usastats` and `statestats` from EJAM v2.32.8.001 replicate the EPA lookup tables exactly on shared lookup columns, so the old package lookup tables are a valid proxy for EPA shared lookup behavior.
- The raw blockgroup demographic index fields replicate at blockgroup level to floating-point tolerance. Large demographic-index lookup differences, if present, are therefore lookup-table semantics or stale-output issues rather than raw blockgroup formula failures.
- Drinking-water is the main historical raw-score difference against EPA: EPA has missing raw values in many block groups where EJAM v2.32.8.001 stores zero. That historical zero-fill should not be repeated in later EJAM releases.
- Current ACS22 pipeline outputs should be built from corrected `bg_envirodata`, not patched during replication comparison. With corrected `bg_envirodata`, the 2026-vs-2024 replication should preserve EPA-style drinking-water missingness and no longer show the v2.32.8.001 raw-score problem.
- The national EPA export percentiles for the four demographic index fields match the pipeline exactly. The state-percentile EPA export file should not be compared by same-named demographic columns without a crosswalk, because the state file uses `DEMOGIDX_2`/`DEMOGIDX_5` where the pipeline uses explicit `DEMOGIDX_2ST`/`DEMOGIDX_5ST` fields.
- A current-code recomputation of `statestats` from the saved ACS2022 `blockgroupstats` makes the legacy `Demog.Index` and `Demog.Index.Supp` lookup columns match the old/EPA state-specific values to tolerance. The S3 ACS2022 `statestats.csv` demographic-index lookup difference is therefore stale saved output, not a remaining code defect.
- `pctunemployed` and disability raw differences are small or already characterized: unemployment is mostly denominator-zero NA handling, and disability count/universe differences are +/-1 apportionment rounding.
- Language and health-insurance differences are important for old-EJAM replication, but the v2.5.0 validation decision already treats those as deliberate/nonblocking for EJAM datasets.

## Decision Points Before Any Code Change

- For EJAM versions after v2.32.8.001, preserve environmental-indicator `NA` values as `NA`; specifically, preserve EPA-style drinking-water missingness in `bg_envirodata` rather than converting missing `drinking`/`DWATER` scores to zero.
- Confirm whether current ACS22 pipeline `statestats` output was regenerated after the `Demog.Index`/`Demog.Index.State` compatibility fix; if not, rerun before considering a code change.
- Confirm whether state lookup differences should target exact EPA lookup-table replication or only acceptable downstream percentile behavior in current EJAM outputs.
- Do not change tied-zero, interpolation, rounding, Puerto Rico inclusion, or missing-value percentile behavior until the specific upstream cause is confirmed.
