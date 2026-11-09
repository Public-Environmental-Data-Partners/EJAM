import assert from "node:assert/strict";
import test from "node:test";

import worker from "../src/index.mjs";

test("redirects to the EJAM app and keeps deep-link parameters", async () => {
  const resp = await worker.fetch(new Request("https://ejam.ejanalysis.com/?lat=33&lon=-112&radius=3"));
  assert.equal(resp.status, 302);
  assert.equal(resp.headers.get("Location"), "https://ejam.publicenvirodata.org/?lat=33&lon=-112&radius=3");
});

test("redirects a bare name to the app's front page", async () => {
  const resp = await worker.fetch(new Request("https://ejamapp.ejanalysis.com/"));
  assert.equal(resp.headers.get("Location"), "https://ejam.publicenvirodata.org/");
});
