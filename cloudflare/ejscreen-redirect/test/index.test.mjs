import assert from "node:assert/strict";
import test from "node:test";

import worker from "../src/index.mjs";

test("redirects to the EJScreen app and keeps the query", async () => {
  const resp = await worker.fetch(new Request("https://ejscreenapp.ejanalysis.com/?zip=20001"));
  assert.equal(resp.status, 302);
  assert.equal(
    resp.headers.get("Location"),
    "https://pedp-ejscreen.azurewebsites.net/index.html?zip=20001",
  );
});
