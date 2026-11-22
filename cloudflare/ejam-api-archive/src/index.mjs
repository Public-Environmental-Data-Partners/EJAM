/**
 * Cloudflare Worker "ejam-api-archive": the api-archive.ejanalysis.com name.
 *
 * The same code as the "ejam-api" Worker (re-exported here, so the two never
 * drift apart), with different settings in wrangler.toml: UPSTREAM is the
 * archive EJAM-API service on Cloud Run, and CACHE_TAG is its own, so cached
 * /report answers from the two APIs can be purged separately. The edge cache
 * is keyed on the upstream URL, so the two APIs never share cached answers.
 * See ../../ejam-api/README.md for the gate and caching, and ../README.md
 * before deploying.
 */
export { default } from "../../ejam-api/src/index.mjs";
