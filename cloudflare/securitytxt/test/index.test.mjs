import assert from "node:assert/strict";
import test from "node:test";

import worker from "../src/index.mjs";

const ORIGIN = "https://security.ejanalysis.com";

test("serves security.txt at its standard paths", async () => {
  for (const path of ["/.well-known/security.txt", "/security.txt", "/"]) {
    const resp = await worker.fetch(new Request(ORIGIN + path));
    assert.equal(resp.status, 200, path);
    assert.equal(resp.headers.get("content-type"), "text/plain; charset=utf-8");
    assert.match(await resp.text(), /^Contact: /m);
  }
});

test("answers other paths with a 404", async () => {
  const resp = await worker.fetch(new Request(`${ORIGIN}/other`));
  assert.equal(resp.status, 404);
});

// RFC 9116 requires Expires, and a past date makes the file invalid. When this
// fails, move the date forward in src/index.mjs and redeploy.
test("the Expires date is still in the future", async () => {
  const body = await (await worker.fetch(new Request(`${ORIGIN}/.well-known/security.txt`))).text();
  const expires = new Date(body.match(/^Expires: (.+)$/m)[1]);
  assert.ok(expires > new Date(), `Expires ${expires.toISOString()} has passed`);
});
