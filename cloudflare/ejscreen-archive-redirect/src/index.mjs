/**
 * Cloudflare Worker "ejscreen-archive-redirect": the ejscreen-archive.ejanalysis.com name.
 *
 * Redirects to the archive EJSCREEN app on Azure, keeping the query. It is a
 * redirect like "ejscreen-redirect", not a reverse proxy like the Worker that
 * serves ejscreen.ejanalysis.com: that proxy caches static files in a cache
 * that ignores the hostname, so the archive name must not share it.
 * See ../README.md before deploying.
 */

export default {
  async fetch(request) {
    const TARGET = "https://pedp-ejscreen-archive.azurewebsites.net/index.html"; // archive EJSCREEN app (Azure)
    const search = new URL(request.url).search; // preserve ?query (any #hash is kept by the browser)
    return Response.redirect(TARGET + search, 302);
  }
};
