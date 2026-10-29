# The `ejam-api` Worker

Answers `api.ejanalysis.com` and `ejamapi.ejanalysis.com`. It passes each request to the
EJAM-API service on Google Cloud Run (`ejamapi-84652557241.us-central1.run.app`) and
adds CORS headers so web pages can call the API.

## Cached reports

Successful `GET /report` answers are cached at Cloudflare's edge for a day; errors are
never cached. Asking for the same report again then takes milliseconds instead of the
13–45+ seconds it takes to compute. Added for
[EJAM#293](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/293) (see
also [EJAM-API#44](https://github.com/Public-Environmental-Data-Partners/EJAM-API/issues/44)).

These cached answers are stored under the **Cloud Run** hostname the Worker forwards to,
not under `api.ejanalysis.com`. To clear them, for example right after the API switches
to a new data release, purge by that hostname: Caching → Configuration → Purge Cache →
Custom Purge → Hostname → `ejamapi-84652557241.us-central1.run.app`. Purging
`api.ejanalysis.com` would not remove them.
