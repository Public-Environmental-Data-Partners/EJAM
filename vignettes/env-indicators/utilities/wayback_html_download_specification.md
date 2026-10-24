# Wayback HTML Download Specification

Implement a small Python command-line utility that downloads archived HTML pages for later conversion into `.Rmd` documentation. This utility handles retrieval only.

File name and location: retrieve_wayback.py in vignettes/env-indicators/scratch

## Input

Accept the path to a local Markdown file, including an `.Rmd` file, containing
inline Markdown links like:

```text
[Traffic proximity and volume](https://web.archive.org/web/20250123162159/https://www.epa.gov/ejscreen/ejscreen-indicators-overview-traffic-proximity-and-volume)
```

Extract links from Markdown link syntax only. Do not extract links from HTML
`href` attributes or bare URLs in the source.

Output files will go to an `archived_html/` subdirectory of the current working
directory.

## Extract the page URLs

- Read inline Markdown link destinations in `[label](URL)` and `[label](<URL>)`
  syntax.
- Select Wayback links whose embedded original URL points to an EPA EJSCREEN indicator overview page: host `www.epa.gov`, with a path beginning `/ejscreen/ejscreen-indicators-overview-`.
- Support Wayback URLs both with and without the `id_` modifier.
- Extract the original EPA URL. **Ignore the timestamp in the supplied link** when selecting the capture to download.
- Remove fragment identifiers such as `#references` before looking up captures.
- Deduplicate the original URLs, preserving their order of appearance.
- Print the extracted list and its count. Expect 13 distinct URLs; report a warning if the count differs, and process the URLs found.

## Find the latest successful capture

For each original EPA URL, query:

```text
https://web.archive.org/cdx/search/cdx
```

Use these parameters:

| Parameter | Value |
|---|---|
| `url` | Original EPA URL |
| `matchType` | `exact` |
| `output` | `json` |
| `filter` | `statuscode:200` |
| `fl` | `timestamp,original` |
| `limit` | `-1` |

Use the returned timestamp and original URL to construct the download URL.

“Latest” means the most recent successful capture available when the utility runs, without a date cutoff. If none is found, record that result and continue.

## Download the archived HTML

Construct the URL as:

```text
https://web.archive.org/web/{timestamp}id_/{original}
```

The `id_` modifier requests the archived content without Wayback's added interface and link rewriting.

- Download the HTML response body and preserve its bytes.
- Do not parse and rewrite the downloaded HTML.
- Do not download images, stylesheets, scripts, or linked pages.
- Do not remove navigation, headers, footers, or other original EPA content.
- Permit redirects within Wayback, but do not follow redirects to the live EPA site or another external site.
- Record the final download URL, including any change in capture timestamp.

## Output files

Derive each filename from the final component of the original EPA URL, adding `.html`. For example:

```text
archived_html/
    ejscreen-indicators-overview-traffic-proximity-and-volume.html
```

I will probably run this script multiple times. Check to see if the expected destination
file already exists. If it does, output a note to that effect and skip it.

Also create a CSV manifest with one row per distinct source URL:

- Original EPA URL
- Selected capture timestamp
- Requested download URL
- Final download URL
- Local filename
- Result: downloaded, skipped, no capture, or failed
- Warning or error message

Preserve existing manifest records when skipping previously downloaded files.

## Reliability and basic checks

- Make requests sequentially, with a short delay between requests.
- Set request timeouts.
- Retry temporary network failures, HTTP 429 responses, and server errors a limited number of times, using increasing delays and honoring `Retry-After`.
- Continue processing other URLs after an individual failure.
- Save through a temporary file so failed downloads do not leave apparently complete HTML files.
- Reject empty responses and clearly non-HTML downloads.
- Flag recognizable Wayback error pages or EPA “page removed” messages for review. An HTTP 200 response alone does not prove the page contains the expected documentation.

## Completion report

Print totals for URLs found, files downloaded, files skipped, missing captures, failures, and warnings. Show the output directory and manifest path.

**Acceptance criterion:** Every distinct matching URL has either a downloaded HTML file with capture information recorded in the manifest, or an explicit explanation of why it was not downloaded.
