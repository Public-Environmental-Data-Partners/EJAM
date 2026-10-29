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
    calls.push({ url: req.url, method: req.method, init });
    return new Response("upstream body", { status, headers });
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
