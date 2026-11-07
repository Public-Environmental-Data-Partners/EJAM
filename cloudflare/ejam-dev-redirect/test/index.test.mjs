import assert from "node:assert/strict";
import test from "node:test";

import worker from "../src/index.mjs";

test("redirects to the dev EJAM app and keeps deep-link parameters", async () => {
  const resp = await worker.fetch(new Request("https://ejamdev.ejanalysis.com/?fips=10001&radius=0"));
  assert.equal(resp.status, 302);
  assert.equal(
    resp.headers.get("Location"),
    "http://ejam-dev-alb-971929002.us-east-1.elb.amazonaws.com/?fips=10001&radius=0",
  );
});
