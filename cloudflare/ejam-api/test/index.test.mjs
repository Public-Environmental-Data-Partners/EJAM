import assert from "node:assert/strict";
import { afterEach, test } from "node:test";

import worker from "../src/index.mjs";

const PUBLIC_ORIGIN = "https://api.ejanalysis.com";
const CLOUD_RUN = "https://ejamapi-84652557241.us-central1.run.app";

// Stands in for Cloud Run: records each request the Worker forwards.
const realFetch = globalThis.fetch;
let calls = [];
function mockUpstream(status = 200, headers = { "Content-Type": "text/html" }) {
  calls = [];
  globalThis.fetch = async (req, init) => {
    calls.push({ url: req.url, method: req.method, init, bypassHeader: req.headers.get("X-EJAM-Gate-Bypass") });
    return new Response("upstream body", { status, headers });
  };
}

// Also stands in for Cloudflare's edge cache in front of Cloud Run, following its
// documented rules: answers fetched with cf.cacheEverything are stored and reused by
// URL, and cache: "no-store" neither reads nor writes the cache.
function mockCachedUpstream(cache, body) {
  calls = [];
  globalThis.fetch = async (req, init = {}) => {
    calls.push({ url: req.url, method: req.method, init, bypassHeader: req.headers.get("X-EJAM-Gate-Bypass") });
    const useCache = init.cache !== "no-store" && init.cf?.cacheEverything === true;
    if (useCache && cache.has(req.url)) return new Response(cache.get(req.url), { status: 200 });
    if (useCache) cache.set(req.url, body);
    return new Response(body, { status: 200, headers: { "Cache-Control": "public, max-age=86400" } });
  };
}
afterEach(() => { globalThis.fetch = realFetch; });

test("forwards the path and query to Cloud Run and adds CORS headers", async () => {
  mockUpstream();
  const resp = await worker.fetch(new Request(`${PUBLIC_ORIGIN}/data?lat=33&lon=-112`), {});
  assert.equal(resp.status, 200);
  assert.equal(await resp.text(), "upstream body");
  assert.equal(calls.length, 1);
  assert.equal(calls[0].url, `${CLOUD_RUN}/data?lat=33&lon=-112`);
  assert.equal(calls[0].init, undefined);
  assert.equal(resp.headers.get("Access-Control-Allow-Origin"), "*");
  assert.equal(resp.headers.get("Content-Type"), "text/html");
});

test("edge-caches only successful GET /report answers, for one day", async () => {
  mockUpstream();
  await worker.fetch(new Request(`${PUBLIC_ORIGIN}/report?lat=33&lon=-112&buffer=1`), {});
  const cf = calls[0].init.cf;
  assert.equal(cf.cacheEverything, true);
  assert.deepEqual(cf.cacheTtlByStatus, { "200-299": 86400, "400-599": 0 });
  assert.deepEqual(cf.cacheTags, ["ejam-api-report"]);

  mockUpstream();
  await worker.fetch(new Request(`${PUBLIC_ORIGIN}/report`, { method: "POST" }), {});
  assert.equal(calls[0].method, "POST");
  assert.equal(calls[0].init, undefined);
});

test("answers CORS preflight without calling Cloud Run", async () => {
  mockUpstream();
  const resp = await worker.fetch(new Request(`${PUBLIC_ORIGIN}/report`, { method: "OPTIONS" }), {});
  assert.equal(resp.status, 204);
  assert.equal(resp.headers.get("Access-Control-Allow-Methods"), "GET, POST, OPTIONS");
  assert.equal(calls.length, 0);
});

test("passes upstream errors through unchanged", async () => {
  mockUpstream(500);
  const resp = await worker.fetch(new Request(`${PUBLIC_ORIGIN}/report?lat=0`), {});
  assert.equal(resp.status, 500);
});

test("UPSTREAM and CACHE_TAG settings override the defaults", async () => {
  mockUpstream();
  const env = { UPSTREAM: "https://archive.example.run.app/", CACHE_TAG: "ejam-api-archive-report" };
  await worker.fetch(new Request(`${PUBLIC_ORIGIN}/report?lat=33`), env);
  assert.equal(calls[0].url, "https://archive.example.run.app/report?lat=33");
  assert.deepEqual(calls[0].init.cf.cacheTags, ["ejam-api-archive-report"]);
});

test("the gate stays off unless MAINTENANCE is on", async () => {
  for (const value of [undefined, "", "off", "no", "true"]) {
    mockUpstream();
    const resp = await worker.fetch(new Request(`${PUBLIC_ORIGIN}/data`), { MAINTENANCE: value });
    assert.equal(resp.status, 200, String(value));
    assert.equal(calls.length, 1, String(value));
  }
});

test("with the gate on, programs get a JSON 503 and nothing reaches Cloud Run", async () => {
  mockUpstream();
  const resp = await worker.fetch(new Request(`${PUBLIC_ORIGIN}/report?lat=33`), { MAINTENANCE: " ON " });
  assert.equal(resp.status, 503);
  assert.equal(calls.length, 0);
  assert.equal(resp.headers.get("Retry-After"), "600");
  assert.equal(resp.headers.get("Cache-Control"), "no-store");
  assert.equal(resp.headers.get("Access-Control-Allow-Origin"), "*");
  assert.match(resp.headers.get("Content-Type"), /^application\/json/);
  assert.deepEqual(await resp.json(), {
    error: "maintenance",
    message: "EJAM is being updated to newer data. Please try again in a few minutes.",
    retry_after_seconds: 600,
  });
});

test("with the gate on, browsers get an HTML page with the message escaped", async () => {
  mockUpstream();
  const env = { MAINTENANCE: "on", MAINTENANCE_RETRY_AFTER: "120", MAINTENANCE_MESSAGE: "Back <soon> & \"ready\"" };
  const resp = await worker.fetch(
    new Request(`${PUBLIC_ORIGIN}/report?lat=33`, { headers: { Accept: "text/html,*/*" } }), env);
  assert.equal(resp.status, 503);
  assert.equal(resp.headers.get("Retry-After"), "120");
  assert.match(resp.headers.get("Content-Type"), /^text\/html/);
  const html = await resp.text();
  assert.match(html, /Back &lt;soon&gt; &amp; &quot;ready&quot;/);
  assert.doesNotMatch(html, /<soon>/);
});

test("with the gate on, CORS preflight is still answered", async () => {
  mockUpstream();
  const resp = await worker.fetch(new Request(`${PUBLIC_ORIGIN}/report`, { method: "OPTIONS" }), { MAINTENANCE: "on" });
  assert.equal(resp.status, 204);
});

test("only the right bypass secret passes the gate", async () => {
  const withHeader = value =>
    new Request(`${PUBLIC_ORIGIN}/data`, { headers: { "X-EJAM-Gate-Bypass": value } });

  mockUpstream();
  let resp = await worker.fetch(withHeader("s3cret"), { MAINTENANCE: "on", GATE_BYPASS_TOKEN: "s3cret" });
  assert.equal(resp.status, 200);
  assert.equal(calls.length, 1);

  mockUpstream();
  resp = await worker.fetch(withHeader("wrong"), { MAINTENANCE: "on", GATE_BYPASS_TOKEN: "s3cret" });
  assert.equal(resp.status, 503);

  // With no secret set, nothing bypasses, not even an empty header.
  mockUpstream();
  resp = await worker.fetch(withHeader(""), { MAINTENANCE: "on" });
  assert.equal(resp.status, 503);
  assert.equal(calls.length, 0);
});

test("a bypassed check reaches Cloud Run, not a cached old report, and stores nothing", async () => {
  const reportUrl = `${PUBLIC_ORIGIN}/report?lat=33&lon=-112&buffer=1`;
  const cache = new Map();

  // Before the switch, the public gets a report and it's cached.
  mockCachedUpstream(cache, "v3 report");
  let resp = await worker.fetch(new Request(reportUrl), {});
  assert.equal(await resp.text(), "v3 report");
  assert.equal(cache.size, 1);

  // During the switch, a bypassed check gets the new API's answer, uncached.
  mockCachedUpstream(cache, "v4 report");
  const env = { MAINTENANCE: "on", GATE_BYPASS_TOKEN: "s3cret" };
  resp = await worker.fetch(new Request(reportUrl, { headers: { "X-EJAM-Gate-Bypass": "s3cret" } }), env);
  assert.equal(resp.status, 200);
  assert.equal(await resp.text(), "v4 report");
  assert.deepEqual(calls[0].init, { cache: "no-store" });
  assert.equal(calls[0].bypassHeader, null);
  assert.equal(resp.headers.get("Cache-Control"), "no-store");
  assert.equal(cache.get(`${CLOUD_RUN}/report?lat=33&lon=-112&buffer=1`), "v3 report");

  // Public caching is unchanged: until the purge, the public copy is the old one.
  resp = await worker.fetch(new Request(reportUrl), {});
  assert.equal(await resp.text(), "v3 report");
});

test("the bypass header is never sent to Cloud Run, and doesn't change caching when the gate is off", async () => {
  mockUpstream();
  const resp = await worker.fetch(
    new Request(`${PUBLIC_ORIGIN}/report?lat=33`, { headers: { "X-EJAM-Gate-Bypass": "s3cret" } }),
    { GATE_BYPASS_TOKEN: "s3cret" });
  assert.equal(resp.status, 200);
  assert.equal(calls[0].bypassHeader, null);
  assert.equal(calls[0].init.cf.cacheEverything, true);
  assert.equal(resp.headers.get("Cache-Control"), null);
});
