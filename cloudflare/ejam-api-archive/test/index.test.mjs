import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { afterEach, test } from "node:test";

import worker from "../src/index.mjs";

// The settings the deployed Worker gets, read from its wrangler.toml.
const toml = readFileSync(new URL("../wrangler.toml", import.meta.url), "utf8");
const setting = (name) => toml.match(new RegExp(`^${name} = "([^"]+)"`, "m"))[1];
const env = { UPSTREAM: setting("UPSTREAM"), CACHE_TAG: setting("CACHE_TAG") };

const realFetch = globalThis.fetch;
let calls = [];
function mockUpstream() {
  calls = [];
  globalThis.fetch = async (req, init) => {
    calls.push({ url: req.url, init });
    return new Response("upstream body", { status: 200, headers: { "Content-Type": "text/html" } });
  };
}
afterEach(() => { globalThis.fetch = realFetch; });

test("settings point at the archive API, with its own cache tag", () => {
  assert.equal(env.UPSTREAM, "https://ejamapi-archive-84652557241.us-central1.run.app");
  assert.equal(env.CACHE_TAG, "ejam-api-archive-report");
  assert.match(toml, /pattern = "api-archive\.ejanalysis\.com"/);
});

test("forwards requests to the archive API, keeping path and query", async () => {
  mockUpstream();
  const resp = await worker.fetch(new Request("https://api-archive.ejanalysis.com/report?lat=33&lon=-112&buffer=3"), env);
  assert.equal(resp.status, 200);
  assert.equal(calls[0].url, "https://ejamapi-archive-84652557241.us-central1.run.app/report?lat=33&lon=-112&buffer=3");
  assert.deepEqual(calls[0].init.cf.cacheTags, ["ejam-api-archive-report"]);
});

test("never forwards to the current API", async () => {
  mockUpstream();
  await worker.fetch(new Request("https://api-archive.ejanalysis.com/"), env);
  assert.ok(!calls[0].url.startsWith("https://ejamapi-84652557241."));
});
