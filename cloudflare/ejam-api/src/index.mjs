/**
 * Cloudflare Worker "ejam-api": serves api.ejanalysis.com and ejamapi.ejanalysis.com
 * by passing requests to the EJAM-API on Google Cloud Run, and edge-caches GET /report.
 * How to use the settings below is in ../README.md.
 *
 * Settings (Worker → Settings → Variables and Secrets; saving them deploys):
 *   MAINTENANCE              "on" or "off" (default off). When "on", every request
 *                            except CORS preflight gets a 503 "EJAM is being updated"
 *                            answer, as HTML for browsers and JSON otherwise, and
 *                            nothing reaches Cloud Run. Used while the API switches
 *                            data releases.
 *   MAINTENANCE_RETRY_AFTER  seconds to suggest waiting (default 600)
 *   MAINTENANCE_MESSAGE      optional replacement for the default message
 *   GATE_BYPASS_TOKEN        optional secret (set it as a Secret, not a plain variable).
 *                            A request whose X-EJAM-Gate-Bypass header equals it
 *                            passes the gate, skipping the cache both ways, so it
 *                            checks Cloud Run itself. If unset, nothing bypasses.
 *   UPSTREAM                 optional origin, so the same code can serve another name,
 *                            e.g. https://ejamapi-archive-84652557241.us-central1.run.app
 *   CACHE_TAG                tag on cached /report answers (default "ejam-api-report"),
 *                            so a data-release switch can purge exactly those
 */

const DEFAULT_UPSTREAM = "https://ejamapi-84652557241.us-central1.run.app";
const DEFAULT_CACHE_TAG = "ejam-api-report";
const DEFAULT_MESSAGE = "EJAM is being updated to newer data. Please try again in a few minutes.";
const BYPASS_HEADER = "X-EJAM-Gate-Bypass";

export default {
  async fetch(request, env = {}) {
    const url = new URL(request.url);
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors() });

    // A bypassed request while the gate is on is a check of the new API, so it must
    // reach Cloud Run: no cached answer (it could be from the old data release), and
    // nothing stored in the shared cache.
    const gated = gateIsOn(env);
    const probe = gated && bypassed(request, env);
    if (gated && !probe) return maintenance(request, env);

    const upstream = String(env.UPSTREAM || DEFAULT_UPSTREAM).replace(/\/+$/, "");
    const upstreamRequest = new Request(upstream + url.pathname + url.search, request);
    upstreamRequest.headers.delete(BYPASS_HEADER); // the secret is for this Worker only
    // Edge-cache GET /report: a report is deterministic for a given URL +
    // deployed data release (the API also sends Cache-Control: public,
    // max-age=86400 on successes, no-store on errors). cacheTtlByStatus caches
    // ONLY 2xx responses (for 1 day) and never errors, so a repeat of the same
    // report URL returns in milliseconds instead of recomputing for ~13-45+ s.
    // Added 2026-07-08 for Public-Environmental-Data-Partners/EJAM#293
    // (see also Public-Environmental-Data-Partners/EJAM-API#44).
    // The cache tag lets a data-release switch purge exactly these answers.
    const isReportGet = request.method === "GET" && url.pathname === "/report";
    const resp = await fetch(
      upstreamRequest,
      probe ? { cache: "no-store" }
        : isReportGet
          ? { cf: { cacheEverything: true, cacheTtlByStatus: { "200-299": 86400, "400-599": 0 },
                    cacheTags: [String(env.CACHE_TAG || DEFAULT_CACHE_TAG)] } }
          : undefined
    );
    const headers = new Headers(resp.headers);
    const c = cors(); for (const k in c) headers.set(k, c[k]);
    if (probe) headers.set("Cache-Control", "no-store");
    return new Response(resp.body, { status: resp.status, headers });
  }
};

function gateIsOn(env) {
  return String(env.MAINTENANCE || "").trim().toLowerCase() === "on";
}

function bypassed(request, env) {
  const token = env.GATE_BYPASS_TOKEN;
  return Boolean(token) && request.headers.get(BYPASS_HEADER) === token;
}

function maintenance(request, env) {
  const retryAfter = String(parseInt(env.MAINTENANCE_RETRY_AFTER, 10) || 600);
  const message = String(env.MAINTENANCE_MESSAGE || DEFAULT_MESSAGE);
  const headers = new Headers(cors());
  headers.set("Retry-After", retryAfter);
  headers.set("Cache-Control", "no-store");
  const wantsHtml = (request.headers.get("Accept") || "").includes("text/html");
  if (wantsHtml) {
    headers.set("Content-Type", "text/html; charset=utf-8");
    const html = '<!doctype html><html lang="en"><head><meta charset="utf-8">' +
      '<meta name="viewport" content="width=device-width, initial-scale=1">' +
      '<title>EJAM is being updated</title></head>' +
      '<body style="font-family: system-ui, sans-serif; max-width: 40em; margin: 4em auto; padding: 0 1em;">' +
      '<h1>EJAM is being updated</h1><p>' + escapeHtml(message) + '</p></body></html>';
    return new Response(html, { status: 503, headers });
  }
  headers.set("Content-Type", "application/json; charset=utf-8");
  const body = { error: "maintenance", message: message, retry_after_seconds: Number(retryAfter) };
  return new Response(JSON.stringify(body), { status: 503, headers });
}

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, ch => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[ch]));
}

function cors() {
  return { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET, POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type" };
}
