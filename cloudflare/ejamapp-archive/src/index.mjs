/**
 * Cloudflare Worker "ejamapp-archive": the ejam-archive.ejanalysis.com name.
 *
 * Redirects to the archive EJAM app, which runs the frozen v3.2022.3 release
 * (ACS 2018-2022), keeping the query so deep links work. It is the archive
 * counterpart of the "ejamapp" Worker, which sends ejam.ejanalysis.com to the
 * current app. See ../README.md before deploying.
 */

export default {
  async fetch(request) {
    const TARGET = "https://ejam-archive.publicenvirodata.org/";
    const search = new URL(request.url).search;   // forwards ?fips=… ?lat=… ?shape=… ?handoff=…
    return Response.redirect(TARGET + search, 302);
  }
};
