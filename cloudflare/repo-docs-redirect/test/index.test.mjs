import assert from "node:assert/strict";
import test from "node:test";

import worker from "../src/index.mjs";

const GH = "https://github.com/Public-Environmental-Data-Partners";
const DOCS = "https://public-environmental-data-partners.github.io/EJAM";

async function redirectOf(url) {
  const resp = await worker.fetch(new Request(url));
  assert.equal(resp.status, 302, url);
  return resp.headers.get("Location");
}

test("path-preserving names keep the path and query", async () => {
  const cases = {
    "https://ejamrepo.ejanalysis.com/issues/681?x=1": `${GH}/EJAM/issues/681?x=1`,
    "https://ejscreenrepo.ejanalysis.com/": `${GH}/EJScreen`,
    "https://apirepo.ejanalysis.com/pulls": `${GH}/EJAM-API/pulls`,
    "https://ejamdata.ejanalysis.com/releases": `${GH}/ejamdata/releases`,
    "https://ejamdocs.ejanalysis.com/articles/whatis.html": `${DOCS}/articles/whatis.html`,
    "https://docs.ejanalysis.com/reference/index.html": `${DOCS}/reference/index.html`,
    "https://docs-archive.ejanalysis.com/articles/whatis.html": `${DOCS}/v3.2022.3/articles/whatis.html`,
  };
  for (const [from, to] of Object.entries(cases)) {
    assert.equal(await redirectOf(from), to, from);
  }
});

test("fixed-page names ignore the path but keep the query", async () => {
  const cases = {
    "https://ejscreendocs.ejanalysis.com/anything?x=1": `${DOCS}/articles/ejscreen.html?x=1`,
    "https://apidocs.ejanalysis.com/": `${DOCS}/articles/dev-api.html`,
    "https://ejscreendocs-archive.ejanalysis.com/": `${DOCS}/v3.2022.3/articles/ejscreen.html`,
    "https://apidocs-archive.ejanalysis.com/x": `${DOCS}/v3.2022.3/articles/dev-api.html`,
  };
  for (const [from, to] of Object.entries(cases)) {
    assert.equal(await redirectOf(from), to, from);
  }
});

test("an unknown name gets a 404", async () => {
  const resp = await worker.fetch(new Request("https://unknown.ejanalysis.com/"));
  assert.equal(resp.status, 404);
});
