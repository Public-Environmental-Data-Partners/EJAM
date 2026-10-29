/**
 *  Cloudflare Worker enabling deep linking to launch EJAM app with parameters
 *
 * - Run "npm run dev" in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run "npm run deploy" to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
  async fetch(request) {
    const TARGET = "https://ejam.publicenvirodata.org/";
    const search = new URL(request.url).search;   // forwards ?fips=… ?lat=… ?shape=… ?handoff=…
    return Response.redirect(TARGET + search, 302);
  }
};