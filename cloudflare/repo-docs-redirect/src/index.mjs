export default {
  async fetch(request) {
    const url = new URL(request.url);
    // Path-preserving: base URL + original path + ?query (any #hash is kept by the browser)
    const PATH_PRESERVING = {
      "ejamrepo.ejanalysis.com": "https://github.com/Public-Environmental-Data-Partners/EJAM",
      "ejscreenrepo.ejanalysis.com": "https://github.com/Public-Environmental-Data-Partners/EJScreen",
      "apirepo.ejanalysis.com": "https://github.com/Public-Environmental-Data-Partners/EJAM-API",
      "ejamdata.ejanalysis.com": "https://github.com/Public-Environmental-Data-Partners/ejamdata",
      "ejamdocs.ejanalysis.com": "https://public-environmental-data-partners.github.io/EJAM",
      "docs.ejanalysis.com": "https://public-environmental-data-partners.github.io/EJAM",
      // Frozen v3.2022.3 docs (archive aliases, 2026-10-28)
      "docs-archive.ejanalysis.com": "https://public-environmental-data-partners.github.io/EJAM/v3.2022.3",
    };
    // Fixed page: whole host goes to one URL (path ignored, ?query preserved)
    const FIXED = {
      "ejscreendocs.ejanalysis.com": "https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen.html",
      "apidocs.ejanalysis.com": "https://public-environmental-data-partners.github.io/EJAM/articles/dev-api.html",
      // Frozen v3.2022.3 docs (archive aliases, 2026-10-28)
      "ejscreendocs-archive.ejanalysis.com": "https://public-environmental-data-partners.github.io/EJAM/v3.2022.3/articles/ejscreen.html",
      "apidocs-archive.ejanalysis.com": "https://public-environmental-data-partners.github.io/EJAM/v3.2022.3/articles/dev-api.html",
    };
    const host = url.hostname;
    if (host in PATH_PRESERVING) {
      const path = url.pathname === "/" ? "" : url.pathname;
      return Response.redirect(PATH_PRESERVING[host] + path + url.search, 302);
    }
    if (host in FIXED) {
      return Response.redirect(FIXED[host] + url.search, 302);
    }
    return new Response("Unknown host: " + host, { status: 404 });
  }
};
