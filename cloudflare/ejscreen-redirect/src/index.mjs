export default {
  async fetch(request) {
    const TARGET = "https://pedp-ejscreen.azurewebsites.net/index.html"; // live EJScreen app (Azure)
    const search = new URL(request.url).search; // preserve ?query (any #hash is kept by the browser)
    return Response.redirect(TARGET + search, 302);
  }
};
