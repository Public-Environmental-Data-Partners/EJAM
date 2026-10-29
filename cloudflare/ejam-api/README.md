# The `ejam-api` Worker

Answers `api.ejanalysis.com` and `ejamapi.ejanalysis.com`. It passes each request to the
EJAM-API service on Google Cloud Run (`ejamapi-84652557241.us-central1.run.app`) and
adds CORS headers so web pages can call the API. Its settings are listed at the top of
[`src/index.mjs`](src/index.mjs); all are optional.

## Cached reports

Successful `GET /report` answers are cached at Cloudflare's edge for a day; errors are
never cached. Asking for the same report again then takes milliseconds instead of the
13–45+ seconds it takes to compute. Added for
[EJAM#293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) (see
also [EJAM-API#44](https://github.com/Public-Environmental-Data-Partners/EJAM-API/issues/44)).

These cached answers are stored under the **Cloud Run** hostname the Worker forwards to,
not under `api.ejanalysis.com`, so purging `api.ejanalysis.com` would not remove them.
Each one carries the cache tag `ejam-api-report` (setting `CACHE_TAG`). To clear them,
for example right after the API switches to a new data release:

- Caching → Configuration → Purge Cache → Custom Purge → **Tag** → `ejam-api-report`,
- or **Hostname** → `ejamapi-84652557241.us-central1.run.app`.

Answers cached before the tag was added have none. They expire within a day, so deploy
this code at least 24 hours before a purge has to catch every cached report.

## The "being updated" gate

While the API switches to a new data release, the gate stops anyone getting a mix of old
and new answers.

- **On:** Settings → Variables and Secrets → add the text variable `MAINTENANCE` = `on` →
  Save and deploy (it takes seconds). Every request then gets a 503 with `Retry-After`
  and `Cache-Control: no-store`: a short page for browsers, JSON for programs. Nothing
  reaches Cloud Run. CORS preflight is still answered, so web pages that call the API
  show the message instead of a confusing error.
- **Check:** `curl -i "https://api.ejanalysis.com/report?lat=33&lon=-112&buffer=1"`
  answers `503`.
- **Off:** set `MAINTENANCE` = `off`, or delete it → Save and deploy. The same `curl`
  answers `200` again.

With `MAINTENANCE` unset or `off`, the Worker behaves exactly as it did before the gate.

`MAINTENANCE_MESSAGE` and `MAINTENANCE_RETRY_AFTER` (seconds, default 600) change what
the 503 says. To check the new API through Cloudflare while the gate is on, add a Secret
`GATE_BYPASS_TOKEN`: a request with the header `X-EJAM-Gate-Bypass: <that value>` then
passes. It also skips the cache both ways: it never gets a cached report, which could
be from the old data release, and its answer isn't stored for the public. The header
isn't passed on to Cloud Run. Don't post the value anywhere.

**If something goes wrong:** turn the gate off. If the code itself misbehaves, redeploy
the previous version (Deployments tab, or this file from an earlier commit).

## A second API name with the same code

For example `api-archive.ejanalysis.com` for the frozen v3.2022.3 API: create another
Worker (such as `ejam-api-archive`) from this same `src/index.mjs`, with the settings

- `UPSTREAM` = the archive Cloud Run address, e.g.
  `https://ejamapi-archive-84652557241.us-central1.run.app`
- `CACHE_TAG` = `ejam-api-archive-report`

then attach the name as a custom domain. When it's made, record it here as a Wrangler
environment in this folder's `wrangler.toml` (an `[env.archive]` section with its name,
`routes` and those two `vars`), so both Workers share one copy of the code. If the API
later moves to other names, such as
`api.publicenvirodata.org`, only `UPSTREAM` and the attached names change.
