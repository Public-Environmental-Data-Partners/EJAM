# EJAM runtime benchmark evidence

This directory contains the durable ETA benchmark evidence collected on
2026-07-25. It separates the two prediction targets:

- `target = "ejamit"` measures only `system.time(EJAM::ejamit(...))`.
- `target = "web_app"` measures from clicking **Start Analysis** until the
  multisite report is visible.

The curated 78-row record is
`Analysis_timing_results_runtime_scenarios.csv`. It retains successful runs,
pre-click failures, post-click timeout lower bounds, the ETA displayed by the
old app, the candidate v3.2022.2 prediction, and source-file/source-row
provenance. Raw browser event logs are intentionally reduced to this compact
table. The fixture matrix, timing rules, fixture writer, and opt-in local
runner are in `datacreate_runtime_benchmarks.R`.
The runner writes a raw 22-column local-R timing table. The curated evidence
adds browser outcomes, source provenance, cohort decisions, and comparison
metrics to produce the 39-column table committed here.

## Environments and timing boundary

| Environment | EJAM version | Interpretation |
|---|---:|---|
| Local `ejamit()` | 3.2022.2 | Local R compute only; package and fixtures were loaded before the clock |
| Local web app | 3.2022.2 | One local Shiny process; click to visible report |
| Live development | 3.2022.2 | Shared development service; click to visible report |
| Live production | 3.2022.1 | Shared production service; context only, not the v3.2022.2 calibration target |

For browser rows, the monotonic clock starts immediately before clicking
`#bt_get_results`. It stops when `#comm_report_html` exists and has more than
100 characters of visible text. Navigation, Shiny startup, input selection,
upload or deep-link setup, and the wait for the expected uploaded count are
outside the clock. Analysis, Shiny notifications, network transfer, and report
insertion are inside it.

Every successful browser row records the app version, requested and observed
radius, expected input count, exact displayed ETA text, and elapsed seconds. A
known capture-only issue truncates the local and live 1,000-point
`uploadSummary` to `1` because the parser stops at the comma. The exact-count
wait passed and the displayed ETA says `1,000`, so those rows remain valid.

## Cache and repeat interpretation

The runs do not establish a controlled cold-cache/warm-cache experiment.
Local repeats use the same R or Shiny process. Browser scenarios use new pages
in one browser context, while the live services are shared with other traffic.
Accordingly, the CSV describes order as `first_occurrence`,
`same_process_repeat`, or `shared_service_unknown`; it never claims that a
first run is cold or a repeat is warm.

For live development, the clean point repeats varied materially:

| Scenario | First valid (s) | Later repeat (s) | Canonical median (s) |
|---|---:|---:|---:|
| 1 point, radius 1 | 9.449559833 | 4.061652459 | 6.755606146 |
| 10 points, radius 1 | 4.608597625 | 3.877770875 | 4.243184250 |
| 10 points, radius 5 | 3.827862959 | 6.166934167 | 4.997398563 |
| 100 points, radius 3.1 | 8.588973792 | 9.407480083 | 8.998226938 |
| 1,000 points, radius 3.1 | 37.359882000 | 30.399785042 | 33.879833521 |

There is no consistent warm-cache multiplier: the later runs changed by about
-57%, -16%, +61%, +10%, and -19%, respectively.

## Calibration cohort and service variability

The point curve uses ten completed development runs collapsed to five scenario
medians. The nonpoint curves use completed, radius-matched development runs:
1 and 20 counties, 1 state, 2 polygons, and 2 cities. A later 3-county run is
retained as validation.

The following remain in the CSV but were not used to fit:

- early FIPS rows where radius 0 was requested but 0.5 was observed; current
  FIPS code treats 0.5 as a real buffer, so those are different workloads;
- a radius-matched county row collected immediately after service overload;
- post-click timeouts, recorded as lower bounds rather than elapsed times;
- pre-click 503/setup failures and the expected mixed-FIPS rejection.

This distinction matters. Input count can predict normal compute and report
overhead, but it cannot predict a transient 502/503, an unavailable worker, or
a stalled upstream boundary lookup. The active web profile targets expected
v3.2022.2 service. Operational failures are reported separately rather than
inflating every small-run ETA to hundreds of seconds.

## Canonical point results

The existing local point model is non-monotone over the target range. Its
predictions fall from 33.806 seconds for one point to 16.315 seconds for 1,000
points, while live-development medians rise to 33.880 seconds.

The implemented web-only point formula is:

```r
5.21244256247219 +
  0.0420642708336423 * pmax(0, pmin(N, 100) - 10) +
  0.0276462295372222 * pmax(0, N - 100)
```

It is a monotone piecewise-linear curve with knots at 1, 10, 100, and 1,000
points and linear extrapolation above 1,000. Radius is omitted from the live
curve because the two matched 10-point radius comparisons disagreed in
direction and constrained direct fits estimated a zero radius coefficient.

| Scenario | Live-dev median (s) | Existing local fit (s) | Existing error | Implemented web ETA (s) | Implemented error |
|---|---:|---:|---:|---:|---:|
| 1 point, radius 1 | 6.755606146 | 33.806268593 | +400.418% | 5.212442562 | -22.843% |
| 10 points, radius 1 | 4.243184250 | 26.724523978 | +529.822% | 5.212442562 | +22.843% |
| 10 points, radius 5 | 4.997398563 | 25.917683066 | +418.625% | 5.212442562 | +4.303% |
| 100 points, radius 3.1 | 8.998226938 | 17.934841096 | +99.314% | 8.998226938 | 0.000% |
| 1,000 points, radius 3.1 | 33.879833521 | 16.315331213 | -51.843% | 33.879833521 | 0.000% |

Across these five canonical medians, the implemented formula has 4.303%
median absolute percentage error, 9.998% mean absolute percentage error,
22.843% maximum absolute percentage error, three of five scenarios within
10%, and all five within 25%.

Across the ten individual point runs, its median absolute percentage error is
14.290%, mean absolute percentage error is 20.222%, and maximum error is
44.839%; six of ten runs are within 25%. The 25% target is therefore supported
for canonical scenario medians, not every individual request under current
browser/server variability.

## Local `ejamit()` profile

The old packaged regression has 124 point rows but no input count below 243.
Its negative log term makes the estimate fall as the count rises from one into
the hundreds. Updating coefficients alone cannot repair that missing low-count
support.

Local R predictions now use empirical, monotone knots. The measured anchors
are 0.889 seconds for 1 point at radius 1; 1.0175 seconds for 10 points at
radius 1; 1.4185 seconds for 10 points at radius 5; and 1.7015, 5.704,
15.046, and 43.779 seconds for 100, 1,000, 3,000, and 10,000 points at radius
3.1. A measured radius-squared adjustment is applied to the local knots, and
the adjusted knots are forced monotone before interpolation.

The web app does not reuse this local curve. It explicitly requests
`target = "webapp_report"` with profile `live_v3.2022.2`.

## FIPS and polygon validation

The active live profile uses absolute, versioned curves rather than offsets
tied to the coefficients of the legacy local models. County, state, polygon,
and 2-city anchors use direct development evidence; the remaining sparsely
observed FIPS counts use conservative monotone interpolation or heuristic
anchors until more successful live runs are available. Multi-state values are
reported as operational lower bounds, not expected completion times:

| Scenario | Candidate ETA (s) | Radius-matched dev run (s) | Error | Other dev evidence |
|---|---:|---:|---:|---|
| 1 county | 13.581 | 17.649 | -23.1% | 21.267 s after overload; 6.827 s at radius 0.5 |
| 20 counties | 14.074 | 11.438 | +23.1% | 10.954 s at radius 0.5; >600 s stall |
| 1 state | 26.125 | 26.125 | 0.0% | 7.768 s at radius 0.5; >300 s stall |
| 2 polygons | 5.500 | median 5.500 | 0.0% | individual runs 4.849 and 6.150 s |
| 2 cities | 10.000 | 10.274 | -2.7% | production v3.2022.1 took 6.980 s |
| 3 counties | 13.633 | 16.752 | -18.6% | held out as validation |

Across all eight completed radius-matched development FIPS/polygon runs,
median absolute percentage error is 16.0%; seven of eight are within 25%.
The 36.1% maximum is the county run designated post-overload before fitting.
All seven non-contaminated calibration/validation runs are within 25%.

No live all-state completion was obtained. A bounded retry successfully
uploaded all 52 state units and clicked Start Analysis, then remained in step
1 for more than 120 seconds while the endpoint returned repeated 502s. The
local `ejamit()` run completed in 19.451 seconds. The source-app validation
completed click-to-report in 23.365 seconds, but that local timing is not valid
calibration evidence for the live service. The live profile therefore reports
“allow at least 2 minutes” for 2 or more states. It does not call 120 seconds
an expected completion time.

On the development service, the packaged blockgroup and tract pages also
returned 503 before a valid click, while the 2-state fixture exceeded 120
seconds after click with repeated 502s. Mixed FIPS input was correctly rejected
before analysis. A final live recheck also reached the app error/timeout screen
before a report for both 2 and 52 states.

The app now passes the actual submitted FIPS radius to the ETA helper. The
three completed rows with radius 0.5 were requested as radius 0 and captured
after the UI showed a different value; their within-scenario ratios to
radius-zero runs are inconsistent and directionally counterintuitive. They are
diagnostic UI/service evidence, not controlled radius experiments. For now the
live profile deliberately declines to show a numeric ETA for buffered FIPS
analyses instead of silently applying the radius-zero curve.

## Cross-environment comparison

The local app is much faster than live development and must not determine the
deployed ETA. Production is also not a training substitute because it runs
v3.2022.1.

| Scenario | Local app (s) | Live dev v3.2022.2 (s) | Production v3.2022.1 (s) |
|---|---:|---:|---:|
| 1 point, radius 1 | 2.708 | median 6.756 | 6.322 |
| 10 points, radius 1 | 1.631 | median 4.243 | 4.791 |
| 10 points, radius 5 | 1.777 | median 4.997 | 6.857 |
| 100 points, radius 3.1 | 2.378 | median 8.998 | 7.687 |
| 1,000 points, radius 3.1 | 7.198 | median 33.880 | 17.838 |
| 1 county | 4.878 | 17.649-21.267 at radius 0; 6.827 at radius 0.5 | 12.035 |
| 20 counties | 3.451 | 11.438 at radius 0; 10.954 at radius 0.5; one >600 s stall | 8.799 |
| 1 state | 2.486 | 26.125 at radius 0; 7.768 at radius 0.5; one >300 s stall | >300 s stall |
| 2 polygons | 1.486 | 4.849-6.150 | 7.476 |

The largest stable version/environment difference is the 1,000-point case:
development v3.2022.2 took a median 33.880 seconds versus 17.838 seconds on
production v3.2022.1 and 7.198 seconds locally.

Production packaged-FIPS context was 11.490 seconds for 14 blockgroups, 6.980
for 2 cities, 7.358 for 3 counties, and 7.383 for 2 states. The 8-tract run
stalled for more than 600 seconds, and mixed FIPS was correctly rejected.

## Source-app validation

The branch was loaded into a local app to verify the point, county, polygon,
and state code paths. The table reports the final rounded live-target value;
the county value was recalibrated from 8 to 14 seconds after the
radius-mismatch review:

| Scenario | Final live-target value | Local click-to-report (s) |
|---|---:|---:|
| 1 point, radius 1 | 5 | 2.273 |
| 100 points, radius 3.1 | 9 | 3.200 |
| 1,000 points, radius 3.1 | 34 | 6.793 |
| 1 county | 14 | 5.166 |
| 2 polygons | 5 | 2.013 |
| all 52 state units | at least 120 s | 23.365 |

The point estimates intentionally remain higher than these local-app times
because the active profile targets the live v3.2022.2 deployment. The local
all-state completion proves the branch path can finish, but it does not
override censored live-development failures. Expected-time messages now show
only the fitted value; they no longer present a 95% regression upper bound as
another ETA. Lower-bound cases use explicit “allow at least” wording. Long-run
notification gating uses the fit or lower bound rather than the old upper
prediction.

## Refresh guidance

Future collection should use at least three interleaved repeats per scenario,
include intermediate point counts and counts above 1,000, explicitly control
or stratify cache state, and repeat every accepted FIPS subtype and multiple
polygon counts. Keep pre-click service failures, post-click lower bounds, and
completed timings as separate outcomes. Refit a versioned web profile only
from the deployment/version it is intended to predict.

Before adding buffered-FIPS ETAs, deliberately set and verify both requested
and observed radii, then collect at least three interleaved repeats at radius
0, 0.5, 1, and 3.1 for identical county and state fixtures. Until those
controlled pairs exist, a missing numeric buffered-FIPS ETA is more accurate
than a radius-zero number presented as calibrated.

Before running the local fixture helper against a checkout, use
`devtools::load_all(".")`; the helper stops if the loaded EJAM namespace points
somewhere else. `datacreate_runtime_models.R` preserves the packaged fallback
models when a new capture lacks enough scenario or `doaggregate` rows. A
replacement model is accepted only with minimum count/range coverage and
nondecreasing, nonnegative predictions from 1 through 100,000 inputs across
the supported radius grid.
