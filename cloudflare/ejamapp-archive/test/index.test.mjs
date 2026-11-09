import assert from "node:assert/strict";
import test from "node:test";

import worker from "../src/index.mjs";

test("redirects to the archive EJAM app and keeps deep-link parameters", async () => {
  const resp = await worker.fetch(new Request("https://ejam-archive.ejanalysis.com/?lat=33&lon=-112&radius=3"));
  assert.equal(resp.status, 302);
  assert.equal(resp.headers.get("Location"), "https://ejam-archive.publicenvirodata.org/?lat=33&lon=-112&radius=3");
});

test("redirects a bare name to the archive app's front page", async () => {
  const resp = await worker.fetch(new Request("https://ejam-archive.ejanalysis.com/"));
  assert.equal(resp.status, 302);
  assert.equal(resp.headers.get("Location"), "https://ejam-archive.publicenvirodata.org/");
});

test("drops the path, like the ejamapp Worker", async () => {
  const resp = await worker.fetch(new Request("https://ejam-archive.ejanalysis.com/some/path?fips=10001"));
  assert.equal(resp.status, 302);
  assert.equal(resp.headers.get("Location"), "https://ejam-archive.publicenvirodata.org/?fips=10001");
});
