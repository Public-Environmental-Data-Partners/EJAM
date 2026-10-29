# Cloudflare Workers for the ejanalysis.com names

The short `*.ejanalysis.com` names, such as `ejam.`, `api.` and `docs.ejanalysis.com`,
are small Cloudflare Workers on the ejanalysis.com Cloudflare account. This folder
holds their code. It is not part of the R package (it is listed in `.Rbuildignore`).

**Merging changes here deploys nothing.** Cloudflare keeps running whatever was last
deployed. Deploying is a separate step, done by someone with access to the Cloudflare
account and only with a maintainer's go (see [Deploying](#deploying)).

## The Workers

| Folder (Worker name) | Names it answers | What it does |
|---|---|---|
| [`ejam-api`](ejam-api) | `api.`, `ejamapi.` | Passes requests to the EJAM-API on Google Cloud Run, and caches `GET /report` answers at the edge for a day. See [its README](ejam-api/README.md). |
| [`ejamapp`](ejamapp) | `ejam.`, `ejamapp.` | Redirects to the EJAM app at `ejam.publicenvirodata.org`, keeping the query so deep links work. |
| [`ejam-dev-redirect`](ejam-dev-redirect) | `dev.`, `ejamdev.`, `ejamappdev.` | Redirects to the development EJAM app, keeping the query. |
| [`ejscreen-redirect`](ejscreen-redirect) | `ejscreenapp.` (and `ejscreen.`, see below) | Redirects to the EJSCREEN app on Azure, keeping the query. |
| [`repo-docs-redirect`](repo-docs-redirect) | `docs.`, `ejamdocs.`, `ejscreendocs.`, `apidocs.`, `ejamrepo.`, `ejscreenrepo.`, `apirepo.`, `ejamdata.`, and the `-archive` docs names | Redirects to the GitHub repositories and the docs site. The `-archive` names go to the frozen v3.2022.3 docs. |
| [`securitytxt`](securitytxt) | `security.` | Serves the project's `security.txt` (RFC 9116). |

Each Worker's names are listed under `routes` in its `wrangler.toml`.

**Not here:** `ejscreen-origin-proxy`, the reverse proxy for `ejscreen.ejanalysis.com/*`,
is kept in the EJScreen repository (`cloudflare/ejscreen-proxy`). That proxy is what
answers `ejscreen.ejanalysis.com` (checked 2026-10-28: the page itself comes back, not a
redirect), so `ejscreen-redirect` only serves `ejscreenapp.` in practice.

## Keeping this folder and Cloudflare the same

- Change a Worker here first, in a pull request, and deploy it after the merge.
- If someone changes a Worker in the Cloudflare dashboard instead, copy the change back
  here in a pull request.
- Each `src/index.mjs` started as an exact copy of the live Worker on 2026-10-28. To
  compare later: Cloudflare dashboard → Workers & Pages → the Worker → Edit code.

Never put the Cloudflare account ID, API tokens or other secrets in this folder.
Secrets, such as the optional `GATE_BYPASS_TOKEN` of `ejam-api`, are set only in the
dashboard.

## Checking a change

From this folder, run `node --test` (Node 22 or newer; nothing to install). The **Check
Cloudflare Workers** workflow runs the same tests on pull requests that touch this
folder. It also does a Wrangler dry run of each `wrangler.toml`, which deploys nothing.

## Deploying

After the merge, and with a maintainer's go, use either way:

- **Dashboard:** Workers & Pages → the Worker → Edit code → paste its `src/index.mjs` →
  Deploy. The Worker's settings and names stay as they are.
- **Wrangler**, from the Worker's folder, with `CLOUDFLARE_API_TOKEN` and
  `CLOUDFLARE_ACCOUNT_ID` set in the environment:

  ```sh
  npx wrangler@4.126.0 deploy
  ```

  Each `wrangler.toml` matches the live settings: the names, the compatibility date,
  no `workers.dev` address, and logs on for `ejam-api` and `ejamapp`. `keep_vars = true`
  keeps variables set in the dashboard, such as `MAINTENANCE` on `ejam-api`.

Then open one of the Worker's names to check it answers as expected.

**To add a name** to an existing Worker: add it to the code and its test, and to
`routes` in `wrangler.toml`. After the merge, deploy, then attach the name (Wrangler
attaches the `routes` itself; in the dashboard, use the Worker's Settings → Domains &
Routes → Add → Custom domain). Cloudflare creates the DNS record.
