// Friendly HTTPS entry for the DEV EJAM Shiny app. Query-preserving 302 so
// deep links (?lat=&lon=&fips=&shape=&radius=&handoff=) arrive intact.
// Same pattern as the ejamapp.ejanalysis.com Worker (prod).
export default {
  async fetch(request) {
    const TARGET = "http://ejam-dev-alb-971929002.us-east-1.elb.amazonaws.com/";
    const search = new URL(request.url).search;
    return Response.redirect(TARGET + search, 302);
  }
};
