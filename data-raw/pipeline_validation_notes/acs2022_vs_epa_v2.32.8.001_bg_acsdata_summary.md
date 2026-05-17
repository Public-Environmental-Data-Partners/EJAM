# ACS2022 Pipeline Validation Against EPA EJSCREEN v2.32.8.001

This note summarizes the remaining differences found when comparing the ACS
2022 `bg_acsdata` stage created by the EJAM ACS2024 pipeline to the old EPA
EJSCREEN/EJAM dataset stored in the EJAM `v2.32.8.001` release.

Comparison inputs:

- New pipeline output:
  `s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2022/bg_acsdata.rda`
- Old/reference object:
  `v2.32.8.001:data/blockgroupstats.rda`
- Related GitHub issue:
  <https://github.com/Public-Environmental-Data-Partners/EJAM/issues/321>

The block group universe matches exactly: 242,336 rows in both datasets, with
the same `bgfips` set.

## Summary By Remaining Column

| Column | Exact differing rows | Old NA | New NA | Main interpretation |
|---|---:|---:|---:|---|
| `percapincome` | 2,418 | 0 | 2,418 | Intentional/acceptable: old sentinel or zero-like legacy values are now missing values. |
| `pctunemployed` | 131,991 | 424 | 2,589 | Mostly floating-point noise plus intentional zero-denominator rule. The denominator is not the issue. |
| `pctnohealthinsurance` | 240,695 | 3,450 | 0 | Still not exact-replication resolved. Current pipeline uses the Census-consistent B27010 universe; old EPA values differ substantially and need a final accept-or-mimic decision. |
| `disab_universe` | 23 | 0 | 0 | Acceptable: tiny apportioned-count rounding differences. |
| `disability` | 29 | 0 | 0 | Acceptable: tiny apportioned-count rounding differences. |
| `pctlan_arabic` | 57,848 | 1,151 | 0 | Acceptable if using precise Census-derived values; old EPA appears rounded to 2 decimals and has legacy NAs. |
| `pctlan_english` | 238,720 | 1,151 | 0 | Same language rounding/missingness issue. |
| `pctlan_french` | 105,706 | 1,151 | 0 | Same language rounding/missingness issue. |
| `pctlan_other_asian` | 110,481 | 1,151 | 0 | Same language rounding/missingness issue. |
| `pctlan_other_ie` | 145,089 | 1,151 | 0 | Same language rounding/missingness issue. |
| `pctlan_rus_pol_slav` | 94,460 | 1,151 | 0 | Same language rounding/missingness issue. |
| `pctlan_vietnamese` | 57,725 | 1,151 | 0 | Same language rounding/missingness issue. |

## Details

### `percapincome`

The new pipeline has 2,418 `NA` rows. In the old EPA data, those same rows were:

- `-666666666` sentinel value in 2,185 rows
- `0` in 233 rows

All rows with finite old and finite new values match exactly. This is
intentional if EJAM stores missing or invalid ACS income values as `NA` rather
than keeping EPA-style sentinel values. The EJScreen export stage can still
convert to sentinel-compatible values if needed for downstream EJScreen
conventions.

### `pctunemployed`

The denominator is not the replication problem. The current formula uses the
Census-consistent unemployment-rate denominator:

- `laborforce_universe = B23025_003`, civilian labor force
- `unemployed = B23025_005`, unemployed persons in the civilian labor force
- `pctunemployed = unemployed / laborforce_universe`

The older `unemployedbase` name is confusing because it refers to `B23025_001`,
population 16 years and over, but that is preserved as a separate universe/count
field and is not used as the current denominator for `pctunemployed`.

The large exact-difference count is misleading because 129,826 rows differ only
by floating-point representation. The maximum finite absolute difference is
about `1.03e-15`.

The meaningful difference is the zero-denominator rule:

- New `laborforce_universe == 0` in 2,589 rows
- Old value was `0` and new value is `NA` in 2,165 rows
- 424 rows are `NA` in both old and new

This reflects the current rule that `pctunemployed` should be `NA` when the
labor-force denominator is zero. That is a deliberate data-quality choice, not
an unexplained formula mismatch.

### `pctnohealthinsurance`

This one should not be described as merely floating-point or simple rounding. It
remains the main ACS replication item that is not exactly resolved.

The current pipeline formula follows the Census B27010 table universe:

- `healthinsurance_universe = B27010_001`
- `nohealthinsurance = B27010_017 + B27010_033 + B27010_050 + B27010_066`
- `pctnohealthinsurance = nohealthinsurance / healthinsurance_universe`

That denominator is the civilian noninstitutionalized population for health
insurance coverage status, not households. There is an older archived draft
formula using `hhlds` as the denominator, and that would be wrong for B27010 if
it had been used. However, the row-level comparison alone does not yet prove
exactly what EPA or EJAM `v2.32.8.001` used to create the old released values.

Counts and distribution:

- Old `NA`: 3,450 rows
- New `NA`: 0 rows
- Finite old/new differing rows: 237,245
- Mean absolute finite difference: `0.0551`
- Median absolute finite difference: `0.0295`
- 95th percentile absolute difference: `0.2008`
- Maximum absolute difference: `0.99`

Difference thresholds:

- `abs(diff) > 0.001`: 218,700 rows
- `abs(diff) > 0.005`: 144,229 rows
- `abs(diff) > 0.010`: 140,646 rows
- `abs(diff) > 0.050`: 91,402 rows
- `abs(diff) > 0.100`: 46,031 rows
- `abs(diff) > 0.250`: 6,401 rows
- `abs(diff) > 0.500`: 178 rows

Examples of largest differences show old EPA values near `0.01` while the new
Census-derived values can be close to `1.0` in small-universe block groups.
Current pipeline values are based on the current B27010-derived calculation, but
this column should remain flagged unless EJAM either intentionally accepts the
new definition or decides to mimic EPA legacy behavior.

### `disab_universe` And `disability`

These now effectively replicate. Remaining differences are only +/- 1 in
apportioned intermediate counts:

- `disab_universe`: 23 rows differ; 16 are `new - old = -1`, 7 are
  `new - old = +1`
- `disability`: 29 rows differ; 17 are `new - old = -1`, 12 are
  `new - old = +1`

These are acceptable rounding differences from tract-to-blockgroup apportionment
and do not indicate a formula problem.

### Detailed Language Variables

The broad language groups now replicate exactly:

- `pctlan_api`
- `pctlan_ie`
- `pctlan_nonenglish`
- `pctlan_other`
- `pctlan_spanish`

The remaining differences are the detailed language variables listed above. For
each detailed language variable:

- Old EPA has 1,151 `NA` rows
- New pipeline has 0 `NA` rows
- Among rows where both old and new are non-missing, old EPA values almost
  always equal `round(new, 2)`
- Maximum absolute finite difference is `0.005`, exactly consistent with
  two-decimal rounding

Two-decimal rounding match counts:

| Column | Both non-NA rows | `old == round(new, 2)` | Mismatches after rounding |
|---|---:|---:|---:|
| `pctlan_arabic` | 241,185 | 241,177 | 8 |
| `pctlan_english` | 241,185 | 241,182 | 3 |
| `pctlan_french` | 241,185 | 241,182 | 3 |
| `pctlan_other_asian` | 241,185 | 241,169 | 16 |
| `pctlan_other_ie` | 241,185 | 241,170 | 15 |
| `pctlan_rus_pol_slav` | 241,185 | 241,172 | 13 |
| `pctlan_vietnamese` | 241,185 | 241,182 | 3 |

Conclusion: the language formula/name cleanup appears to have fixed the major
mismatch. Exact old replication would require intentionally reproducing EPA's
legacy two-decimal rounding and 1,151-row missingness mask. For the ACS2024
pipeline, the current precise Census-derived values are likely preferable unless
the explicit goal is byte-for-byte replication of the older EPA table.

## Current Close/Readiness View

Most `bg_acsdata` differences are now either intentional or small/acceptable.
The only column still treated as substantively unresolved for replication is
`pctnohealthinsurance`, unless EJAM explicitly decides that the new
Census-derived calculation is the desired v2.5.0 behavior even though it does
not replicate the EPA 2022 table.
