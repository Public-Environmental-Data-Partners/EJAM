/**
 * Cloudflare Worker
 *
 * - Run "npm run dev" in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run "npm run deploy" to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
  async fetch(request) {
    const upstream = "https://ejamapi-84652557241.us-central1.run.app";
    const url = new URL(request.url);
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors() });
    // Edge-cache GET /report: a report is deterministic for a given URL +
    // deployed data release (the API also sends Cache-Control: public,
    // max-age=86400 on successes, no-store on errors). cacheTtlByStatus caches
    // ONLY 2xx responses (for 1 day) and never errors, so a repeat of the same
    // report URL returns in milliseconds instead of recomputing for ~13-45+ s.
    // Added 2026-07-08 for Public-Environmental-Data-Partners/EJAM#293
    // (see also Public-Environmental-Data-Partners/EJAM-API#44).
    const isReportGet = request.method === "GET" && url.pathname === "/report";
    const resp = await fetch(
      new Request(upstream + url.pathname + url.search, request),
      isReportGet ? { cf: { cacheEverything: true, cacheTtlByStatus: { "200-299": 86400, "400-599": 0 } } } : undefined
    );
    const headers = new Headers(resp.headers);
    const c = cors(); for (const k in c) headers.set(k, c[k]);
    return new Response(resp.body, { status: resp.status, headers });
  }
};
function cors() {
  return { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET, POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type" };
}
