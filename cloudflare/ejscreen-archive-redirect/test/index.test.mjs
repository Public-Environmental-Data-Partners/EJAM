import assert from "node:assert/strict";
import test from "node:test";

import worker from "../src/index.mjs";

const TARGET = "https://pedp-ejscreen-archive.azurewebsites.net/index.html";

test("redirects to the archive EJSCREEN app and keeps the query", async () => {
  const resp = await worker.fetch(new Request("https://ejscreen-archive.ejanalysis.com/?fips=10001&radius=3"));
  assert.equal(resp.status, 302);
  assert.equal(resp.headers.get("Location"), TARGET + "?fips=10001&radius=3");
});

test("redirects a bare name to the archive app", async () => {
  const resp = await worker.fetch(new Request("https://ejscreen-archive.ejanalysis.com/"));
  assert.equal(resp.status, 302);
  assert.equal(resp.headers.get("Location"), TARGET);
});
