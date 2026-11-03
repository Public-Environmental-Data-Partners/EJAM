// Serves the RFC 9116 security.txt for ejanalysis.com (EJAM / EJScreen projects).
// The apex ejanalysis.com is hosted on Squarespace (which cannot serve /.well-known/),
// so Squarespace 301-redirects /.well-known/security.txt and /security.txt to this Worker.
const BODY = `# security.txt for ejanalysis.com
# EJAM and EJScreen projects — Public Environmental Data Partners
# Format: RFC 9116  (https://securitytxt.org)

Contact: https://github.com/Public-Environmental-Data-Partners/EJAM/security/advisories/new
Contact: mailto:ejam@ejanalysis.com
Expires: 2027-07-01T00:00:00.000Z
Preferred-Languages: en
Canonical: https://ejanalysis.com/security.txt
Canonical: https://security.ejanalysis.com/.well-known/security.txt
`;

export default {
  async fetch(request) {
    const path = new URL(request.url).pathname;
    if (path === "/.well-known/security.txt" || path === "/security.txt" || path === "/") {
      return new Response(BODY, {
        status: 200,
        headers: {
          "content-type": "text/plain; charset=utf-8",
          "cache-control": "max-age=300",
        },
      });
    }
    return new Response("Not found. See /.well-known/security.txt", { status: 404 });
  },
};
