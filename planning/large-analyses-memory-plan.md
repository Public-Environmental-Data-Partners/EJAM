# Large analyses: memory use, diagnosis, and plan

- **Tracking issue:** Public-Environmental-Data-Partners/EJAM#57. Crash reports: Public-Environmental-Data-Partners/EJAM#504.
- **Status:** Tier 1 (items 1–5) is in Public-Environmental-Data-Partners/EJAM#649. Items 6–7 (memory cap and freeing old results) are in Public-Environmental-Data-Partners/EJAM#650. Everything else below is the plan, in the order agreed in the #57 discussion (2026-10-07).

## Summary

The hosted app crashes on large analyses (10k points at 3.1 mi on prod with 7 GB and on dev with 6 GB; 10k at 2 mi on dev) because the single R process runs out of memory.

- **Where:** inside `doaggregate()`, during the "Joining blockgroups to EJSCREEN indicators" step that #504 reports.
- **Why:** much of the peak is full copies of large tables made along the way, not the results themselves.
- **Starting point:** the idle app already uses about 3 GB. It creeps to about 4–5 GB once anyone has used summary indexes, a FIPS analysis or a NAICS/SIC search, because those datasets stay loaded. Every user in a container shares that one process and its headroom.
- **Report download is a second risk:** pandoc used 4.85 GB to build the 37 MB report for 10k sites; 97% of that file is map popups.
- **Very large analyses need structural changes:** at 50k sites and 5 mi, the site × blockgroup table alone would be about 11 GB. Batching, blockgroup-level shortcuts and lighter maps are needed.

## How it was measured

- Mac with 24 GB RAM; EJAM 3.2022.3, which has the same analysis code as `development`; input `testpoints_10000`.
- App settings: `include_ejindexes = TRUE`, `extra_demog = TRUE`, `calculate_ratios = TRUE`.
- **"Peak"** is R's own high-water mark, `gc()` "max used". It includes garbage not yet collected, so it is the memory R actually asked the operating system for. It is repeatable from run to run.
- **Whole-process memory** (RSS) on macOS is noisy because the OS compresses memory. It was used only for memory outside R's heap: pandoc, the block search index, and Arrow data. That outside part is about 2–2.5 GB when idle.
- The server runs Linux, so absolute numbers will differ somewhat. The ranking of the steps should hold.

Size of the 10k / 3.1 mi case:

| Measure | Count |
|---|---|
| site-block rows | 9.28M |
| unique blocks | 3.0M |
| unique blockgroups | 155k |
| site-blockgroup pairs | 654k |

### Measurement traps

- `gc(reset = TRUE)` returns "max used" *after* resetting it. Read `gc(reset = FALSE)` first, then reset.
- Use the last column of `gc()` ("max used (Mb)"). Recent R versions add a "limit (Mb)" column, which shifts the column positions.
- Do not compare two macOS RSS readings, especially with two R jobs running at once.

## Where the memory goes (10k points, 3.1 mi, app settings, before this PR)

| Step | R memory peak | Main cause |
|---|---|---|
| Idle app after startup | 0.8 GB R heap (about 3.1–3.4 GB whole process) | `blockgroupstats` (0.58 GB, 404 columns); Arrow block tables; block search index `localtree` (about 0.7 GB, outside R's heap) |
| `getblocksnearby()` | 3.85 GB | Keeps every block in each site's search square (1.58× as many as end up inside the circle) until all sites are done. Keeps the per-site list alive to the end, and makes a combined copy, a join copy, a filter copy and two reorder copies, to return a 0.35 GB table. |
| `doaggregate()` input | +0.35–0.45 GB | A defensive `copy(sites2blocks)` while `ejamit()` still holds the original. The radius filter copied the table even when it removed nothing. |
| `doaggregate()` join | 4.6 GB | Merging `bgej` made a private full copy of `blockgroupstats` (0.68 GB, kept for the whole function). Then `blockgroupstats[ , ..cols]` copied all 243k rows twice. The joined site × blockgroup table itself is 0.94 GB (654k rows × 232 columns). |
| `doaggregate()` just after the join | 6.4 GB | `sites2bgs_plusblockgroupdata_bysite$x <- NA`. Inside a package that imports data.table, `$<-` on a data.table deep-copies the whole table (`$<-.data.table` calls `copy(x)`): about 1 GB each time, three times. `ejamit()` did it once more, with `out$results_bybg_people$area_sqmi <- NA`. |
| `doaggregate()` state percentiles | 6.6 GB | Garbage piles up between collections: `pctile_from_raw_lookup()` copied the `statestats` lookup table (5.3 MB) on each of about 300 calls. |
| `batch.summarize()` | about +1 GB (from the code) | `as.data.frame(popstats)` deep-copied `results_bybg_people`. |
| Kept in the session | 1.0 GB | `results_bybg_people` (654k × 232) lives on in `data_processed()`. The previous analysis's result also stays alive until a new run finishes. |

**Small runs pay a fixed cost too.** 1,000 points at 1 mi (130k block rows) peaked at 2.94 GB from a 0.78 GB baseline, mostly from copying all of `blockgroupstats`.

### Other large steps

- **Report download** (`ejam2report()`, then rmarkdown, then pandoc):
  - 10k sites produce a 37 MB self-contained HTML file. pandoc, a separate process in the same container, peaked at 4.85 GB.
  - Per-site popups are 3.5 KB each: 97% of the file. A 1,000-site map is 4.3 MB with full popups and 0.9 MB with "Site N" popups.
  - pandoc used about 100–130× the report's file size in both cases measured.
  - The in-app map sends the same ~35 MB to the browser.
- **All 52 states via FIPS, radius 0:**
  - `ejamit()` takes 15 s but peaks at 7.37 GB. The cost is `getblocksnearby_from_fips()` building an 8.2M-row block table through string joins on `blockid2fips`, then `doaggregate()` on 8.2M rows.
  - pandoc used 2.6 GB for the 24 MB report.
- **Polygons:** one California polygon (520k blocks) peaks at 2.7 GB, about 3.6 KB per block, because every candidate block point becomes an `sf` point before `st_join()`.
- **Datasets that load once and stay loaded** (approximate whole-process memory):

  | Loaded | Process memory |
  |---|---|
  | After startup | 3.3 GB |
  | + `bgej` | 4.3 GB |
  | + FRS tables | 4.9 GB |

  `bgej` adds about 0.8 GB to the process although it is 0.12 GB as an R object, probably Arrow overhead.

### Scale of very large analyses

Measured on a 1,000-site sample of `testpoints_10000`, using the Tier 1 version of the search:

| Radius | Block rows per site | Site-blockgroup pairs per site | Search time per 1,000 sites |
|---|---|---|---|
| 1 mi | 136 | 12 | 1.1 s |
| 3.1 mi | 972 | 72 | 1.1 s |
| 5 mi | 2,144 | 152 | 1.3 s |
| 10 mi | 6,593 | 452 | 2.2 s |

What that implies:

| Analysis | Block rows | Site-blockgroup pairs |
|---|---|---|
| 50k sites, 5 mi | ~107M (~3 GB as a table) | 7.6M (~11 GB as today's 232-column `results_bybg_people`) |
| 100k sites, 10 mi | ~660M | ~45M |

Copy-trimming alone cannot fit these into 6 GB.

## What Tier 1 changes (this PR)

Results are unchanged. Every output was compared with `identical()` between `development` and this branch, built and installed side by side:

- **16 cases, all identical:**
  - points at 1 and 3.1 mi, with and without summary indexes;
  - a 1–3 mi donut;
  - FIPS counties, states, blockgroups and tracts;
  - FIPS counties buffered by 1 mi;
  - two polygons;
  - `getblocksnearby()` with adjusted distances, with and without `retain_unadjusted_distance`;
  - `doaggregate()` called directly;
  - `batch.summarize()` given data.table and data.frame inputs with NA population.
- **Callers' tables are left unchanged:** `doaggregate()` (with its default copy) and `batch.summarize()`.
- **Full `ejamit()` at 10k points, 1 and 3.1 mi:** every column of every output element is identical.

The changes:

1. **`$<-` replaced with `:=` on large data.tables:** `doaggregate()` (three places) and `ejamit()` (`area_sqmi`).
2. **`doaggregate()` copies only the blockgroups and columns it needs, once:** `blockgroupstats[bgid %in% needed, ..cols]`, then adds the `bgej` columns to that small copy by reference. This replaces a full merged copy plus two full-table column copies. Blockgroups missing from `bgej` are still dropped, as the old inner join did.
3. **New `doaggregate(copy_sites2blocks = TRUE)` argument.** `ejamit()` passes `FALSE`, since it only checks afterwards which sites had blocks. The radius filter now copies the table only when some rows actually exceed the radius.
4. **`getblocksnearbyviaQuadTree()`:**
   - drops blocks well beyond the radius, such as the corners of the search square, inside the per-site loop. When distances are adjusted, it keeps blocks out to radius / 0.9 there, because a short distance is set to 0.9 × `block_radius_miles`, which can bring a block from just outside the radius to inside it. The final radius filter still runs, so the result is the same. (`getblocksnearby()` and `ejamit()` use unadjusted distances by default.);
   - `rm(res)` after `rbindlist()`;
   - does not join `block_radius_miles` when distances are not adjusted;
   - reorders in place with `setorder()` instead of a join plus a filter copy.
5. **`batch.summarize()` and `pctile_from_raw_lookup()`:**
   - `batch.summarize()` no longer deep-copies `popstats`. It uses a new data.frame that shares the caller's columns, and gives `pop` its own copy before changing NA to 0.
   - `doaggregate()` drops the `mean` and `std` rows of `usastats` and `statestats` once, and `pctile_from_raw_lookup()` skips its subset when those rows are already gone.

Measured effect (R heap peaks, 10k points):

| Case | Step | Before | After |
|---|---|---|---|
| 3.1 mi | `getblocksnearby()` | 3.86 GB | **2.13 GB** |
| 3.1 mi | `doaggregate()` | 6.59 GB | **5.25 GB** |
| 3.1 mi | `batch.summarize()` | 4.51 GB | **3.49 GB** |
| 3.1 mi | total `ejamit()` time | 58.6 s | 55.2 s |
| 1 mi | `getblocksnearby()` | 1.80 GB | 1.50 GB |
| 1 mi | `doaggregate()` | 3.60 GB | **2.56 GB** |
| 1 mi | `batch.summarize()` | 2.40 GB | 2.18 GB |
| 1 mi | total `ejamit()` time | 36.5 s | 35.2 s |

Time is unchanged within run-to-run noise. In this R process, 0.78 GB of R heap is already in use before each analysis starts.

## Plan, in agreed order

Order and decisions from the #57 discussion, 2026-10-07.

### Now

- [ ] **6. Cap R's memory and catch errors**, in Public-Environmental-Data-Partners/EJAM#650.
  - Today the operating system kills the whole container, ending every session in it.
  - With the cap, a too-large analysis stops as an R error for that one user, who sees a plain-language message, and the app stays up for everyone else.
  - The cap is the container limit minus a 3 GB reserve, for memory outside R's own heap and for pandoc/Chrome. That makes it 3 GB on dev and 4 GB on prod. Tested locally under those caps (full `ejamit()`, 10k points):

    | Cap | 10k pts at | Today on that server | development code + cap | with Tier 1 + cap |
    |---|---|---|---|---|
    | 3 GB (dev) | 1 mi | works | completes | completes |
    | 3 GB (dev) | 2 mi | crashes | stops with message | completes |
    | 4 GB (prod) | 2 mi | works | completes | completes |
    | 4 GB (prod) | 3.1 mi | crashes | stops with message | completes |

- [ ] **7. Free the previous result before a new analysis starts:** `data_processed(NULL)` at the start of the Start Analysis observer. In Public-Environmental-Data-Partners/EJAM#650, with item 6.
- [ ] **1–5. Tier 1 copy fixes**, in Public-Environmental-Data-Partners/EJAM#649.
- **8. `R_GC_MEM_GROW=0`: dropped.** It lowered the `doaggregate()` peak from 5.22 to 3.64 GB, but made that step about 34% slower (25 s to 34 s).

### Needs decisions first

- [ ] **9. Smaller maps for many sites**, in the in-app map and in `ejam2report()`. Questions:
  1. Above how many sites should popups get shorter? (suggested: 1,000)
  2. What should a short popup show? (suggested: site number or name, population, and the 2–3 key percentiles shown at the top of the community report)
  3. Above how many sites should individual circles become clustered markers? Above how many should the downloaded report get a static image or no map? (suggested: clusters above 5,000; a static image above 20,000)
  4. Should the in-app map keep full popups by building each one on click from the server (no size cost), while only the downloaded report uses short popups?
  5. For polygons: above how many shapes, or how many vertices, should shapes be simplified for the map?

### Tier 3, in this order

- [ ] **12. FIPS shortcut.**
  - For unbuffered state, county, tract and blockgroup FIPS, every block of every blockgroup is inside the area, so each blockgroup's weight is the sum of its block weights (1, except 0 for blockgroups with no population).
  - Build the site × blockgroup table directly from `blockgroupstats` FIPS prefixes, or from `blockwts` by integer `bgid`. That skips the 8.2M-row block table and the string join on `blockid2fips`, which then never needs to load.
  - All 52 states becomes about 243k rows instead of 8.2M. Block counts per blockgroup can come from a small lookup.
  - Buffered FIPS and cities keep the polygon path.
- [ ] **13. Polygons:** test which blocks fall inside one polygon at a time (or one chunk of candidate points at a time), after a cheap numeric bounding-box filter, instead of converting every candidate block into an `sf` point at once. Combined with the blockgroup-level idea below, interior blockgroups would not need their blocks tested at all.
- [ ] **14. Run long analyses without blocking other users.** All sessions in a container share one R process, so a 10–30 minute analysis freezes the app for everyone else there.
  - Options: Shiny's `ExtendedTask` with a forked child process (`future::multicore` or `parallel::mcparallel`), or routing very large analyses to `ejamit()` in R or to the API.
  - A forked child shares the already-loaded data instead of reloading its own ~3 GB.
  - Forking keeps the app responsive, but it does not by itself protect the app from running out of memory. The child and the app share the container's memory limit, and when that limit is reached the system may stop either process, or the whole container. Keeping the app safe needs a separate memory limit for the worker, such as R's own cap in the child plus enough room in the container for both processes, or running large analyses in a separate task or container.
  - Set data.table to 1 thread in the child.
  - Relates to the in-app report design in Public-Environmental-Data-Partners/EJAM#476, which uses `ExtendedTask` with a `callr` worker.
- [ ] **15. Smaller footprint for `bgej` and the FRS tables** (about 0.8 and 0.5 GB of process memory).
  - `bgej`: keep only the needed columns as plain R columns, or store them with `blockgroupstats`.
  - FRS: drop the tables from memory after a search, or query them from the Arrow files on disk.
  - Later, the block search index (about 0.7 GB) could be replaced by a lighter grid index.
- [ ] **10. Batch by sites,** switching on the number of block rows rather than the number of sites. See "Batching design" below.
- [ ] **11. For big runs, keep less detail.**
  - Return a unique-blockgroup version of `results_bybg_people` (at most 243k rows, about 0.35 GB) instead of the site × blockgroup table.
  - That is also what the "percentile of people" rows in `batch.summarize()` and `calc_flagged_areas()` need: the current table counts residents near 2 or more sites more than once.
  - This changes outputs, so it needs a decision.
  - Longer term: compute by-site results as sparse-matrix products instead of join-then-group.

### Batching design (item 10)

1. Run a first batch, or a 100–200-site sample, to measure block rows per site.
2. Size each batch to about 2–3M block rows: about 3,000 sites at 3.1 mi, 1,000 at 5 mi, 400 at 10 mi.
3. For each batch, run `getblocksnearby()`, aggregate by site, and keep only that batch's `results_bysite` rows. Memory then stays flat however many sites there are.

Overall (unique-resident) results can't simply be added up across batches, but they are bounded, because the US has only 8.2M blocks:

- Across batches, keep per-block vectors: number of nearby sites (integers, about 33 MB) and distance to the nearest site.
- At the end, build the unique-block table (at most 8.2M rows, about 0.25 GB) and run the existing overall aggregation once.
- Overall state-percentile averages already come from `results_bysite`, so they are unaffected.

One catch: per-site `sitecount_avg` and `sitecount_max`, shown in the report's "Analyzed Sites" table, need each block's count of nearby sites across all batches. So use two passes:

1. Pass 1 searches every batch, writes each batch's `sites2blocks` to a temporary Arrow file, and updates the per-block counts.
2. Pass 2 reads each batch back and aggregates it. (Pass 2 could instead redo the search, which is the cheaper part.)

Test: batched results for a 1,000-site input split into 10 batches must be identical to the unbatched results.

Rough time, scaled from 10k / 3.1 mi:

| Analysis | Locally | On the server |
|---|---|---|
| 50k sites, 5 mi | 5–6 min | maybe 10–12 min |
| 100k sites, 10 mi | 30+ min | |

## Blockgroup-level simplification (idea from the #57 discussion)

Most blockgroups in an analysis are completely inside a site: all of the blockgroup's block points are inside the circle, polygon or FIPS unit. Block-level rows matter only for blockgroups that are partly inside.

Measured on a 1,000-site sample of `testpoints_10000`:

| Radius | Site-blockgroup pairs fully inside | Block rows before → after collapsing complete pairs to one row each |
|---|---|---|
| 1 mi | 43% | 136k → 78k (43% fewer) |
| 3.1 mi | 76% | 972k → 267k (73% fewer) |
| 5 mi | 84% | 2.14M → 0.45M (79% fewer) |
| 10 mi | 91% | 6.59M → 1.01M (85% fewer) |

How much of the current output stays exact if complete pairs are collapsed:

- **Exact:**
  - **All indicators.** Each blockgroup's weight in a site is all `doaggregate()` needs. For a complete pair, that weight is the sum of the blockgroup's block weights. This is exactly 1 for 99.4% of blockgroups and 0 for those with no population, so use the precomputed sum, not 1.
  - **Overall (unique-resident) results.** A blockgroup complete in any site is fully counted. The union of blocks is needed only for blockgroups that are partial everywhere, and those keep their block rows.
  - **Overlap counts** (`sitecount_avg`, `sitecount_max`). A block's count of nearby sites is the number of sites where its blockgroup is complete, plus the number of partial rows listing that block.
  - **Block counts per site:** from a small per-blockgroup lookup.
- **Needs per-block distances:** `distance_min` and `distance_min_avgperson` for complete pairs. These can still be exact without storing block rows: compute each site's distances to the blocks of its complete blockgroups and summarize them on the fly (min and weighted mean per pair). Or make them optional for large runs.

Where the savings come from:

- Collapsing at the start of `doaggregate()` is the simplest change, but saves little, because `getblocksnearby()` has already built the block-level table.
- The large win is to never build block rows for complete blockgroups. Index blockgroups by a "bounding circle" (centroid plus the largest distance from the centroid to any of its block points). For each site:
  - when the distance to the centroid plus that radius is within the search radius, the whole blockgroup is inside;
  - when the distance minus that radius exceeds the search radius, the whole blockgroup is outside;
  - only the blockgroups in between need block-level distances.
- That is the same "complete blockgroup" representation items 12 (FIPS) and 13 (polygons) need. FIPS is the special case where every blockgroup is complete. So one design should cover circles, FIPS and polygons.
- The cost is a second row type in `sites2blocks` (complete-blockgroup rows with no `blockid`). Every function that reads `sites2blocks` would need to handle it, or the compact format could be used only above a size threshold.

## Decisions needed

1. Item 9 thresholds and popup content (questions above).
2. Item 11: whether large runs may return a unique-blockgroup `results_bybg_people` instead of site × blockgroup pairs.
3. Blockgroup-level simplification: whether to add a complete-blockgroup row type to `sites2blocks` for every analysis, or only above a size threshold. Also, whether exact distance stats are required for complete blockgroups or may be optional in large runs.
