#!/usr/bin/env python3
"""retrieve_wayback.py

Purpose:
	Download the latest successful Wayback Machine captures of EPA EJSCREEN
	indicator pages given a list of Wayback URLs.
	Tracks all download attempts, captures, and any failures in a manifest CSV.

Process summary:
	- Read the list of Wayback URLs from the input file.
	- Extract the original EPA URL from each Wayback URL.
	- Query the Wayback Machine API to find the latest successful capture of each original EPA URL.
	- Download the captured HTML files with proper retry logic and timeouts.
	- Validate downloaded content to verify it is actual HTML (not an error page).
	- Generate a manifest CSV tracking original URLs, capture timestamps, download
	  results, and any warnings or errors.
	- Print a summary report of successes, failures, skipped files, and warnings.

Runtime arguments (current defaults shown):
	- input_file: required path to the local file containing Wayback URLs (one per line).

Constants and defaults:
	- OUTPUT_DIRECTORY: archived_html
	- MANIFEST_FILENAME: manifest.csv
	- REQUEST_TIMEOUT_SECONDS: 120
	- REQUEST_INTERVAL_SECONDS: 2 (rate limiting between requests)
	- MAX_ATTEMPTS: 5 (retry attempts per request)
	- RETRY_BASE_SECONDS: 2 (exponential backoff base)
	- USER_AGENT: EJAM-Wayback-HTML-Retriever/1.0

Outputs:
	- archived_html/{capture_timestamp}_{safe_filename}.html for each downloaded capture.
	- archived_html/manifest.csv with columns: Original EPA URL, Selected capture timestamp,
	  Requested download URL, Final download URL, Local filename, Result, Warning or error message.

Examples (run from the tools directory):

    - Download from a specific file with the full or relative path:
        python retrieve_wayback.py /path/to/urls.txt
        python retrieve_wayback.py ./urls.txt

"""

from __future__ import annotations

import argparse
import csv
import json
import re
import socket
import sys
import tempfile
import time
from collections import OrderedDict
from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote, unquote, urlencode, urlsplit, urlunsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener, urlopen

OUTPUT_DIRECTORY = Path("archived_html")
MANIFEST_FILENAME = "manifest.csv"
REQUEST_TIMEOUT_SECONDS = 120
REQUEST_INTERVAL_SECONDS = 2
MAX_ATTEMPTS = 5
RETRY_BASE_SECONDS = 2
USER_AGENT = "EJAM-Wayback-HTML-Retriever/1.0"
MANIFEST_FIELDS = [
    "Original EPA URL",
    "Selected capture timestamp",
    "Requested download URL",
    "Final download URL",
    "Local filename",
    "Result",
    "Warning or error message",
]
WAYBACK_PATH = re.compile(r"^/web/(\d{1,14})(?:id_)?/(https?://.+)$")
SAFE_FILENAME = re.compile(r"^[A-Za-z0-9._-]+$")
HTML_SIGNATURE = re.compile(
    rb"^\s*(?:\xef\xbb\xbf)?(?:<!doctype\s+html\b|<html\b|<head\b|<body\b)",
    re.IGNORECASE,
)
REMOVAL_OR_ERROR_PHRASES = (
    "this page has been removed",
    "the page has been removed",
    "this page no longer exists",
    "the page no longer exists",
    "the page you are looking for has been removed",
    "the wayback machine has not archived that url",
    "wayback machine error",
    "page not found",
)


class RejectRedirectHandler(HTTPRedirectHandler):
    def redirect_request(
        self, req: Request, fp: object, code: int, msg: str, headers: object, newurl: str
    ) -> None:
        raise HTTPError(
            req.full_url,
            code,
            f"Redirect rejected: {newurl}",
            headers,  # type: ignore[arg-type]
            fp,  # type: ignore[arg-type]
        )


@dataclass
class Response:
    body: bytes
    headers: object
    final_url: str


class RequestFailure(Exception):
    pass


class RequestClient:
    def __init__(self) -> None:
        self._last_request_at: float | None = None

    def _wait_for_request_interval(self) -> None:
        if self._last_request_at is not None:
            elapsed = time.monotonic() - self._last_request_at
            remaining = REQUEST_INTERVAL_SECONDS - elapsed
            if remaining > 0:
                time.sleep(remaining)
        self._last_request_at = time.monotonic()

    @staticmethod
    def _retry_after_seconds(headers: object) -> float | None:
        value = headers.get("Retry-After") if headers is not None else None
        if not value:
            return None
        try:
            return max(0.0, float(value))
        except ValueError:
            try:
                retry_at = parsedate_to_datetime(value)
                if retry_at.tzinfo is None:
                    retry_at = retry_at.replace(tzinfo=timezone.utc)
                return max(0.0, (retry_at - datetime.now(timezone.utc)).total_seconds())
            except (TypeError, ValueError, OverflowError):
                return None

    def get(self, url: str, *, reject_redirects: bool = False) -> Response:
        request = Request(url, headers={"User-Agent": USER_AGENT})
        opener = build_opener(RejectRedirectHandler()) if reject_redirects else None

        for attempt in range(MAX_ATTEMPTS):
            self._wait_for_request_interval()
            try:
                if opener is None:
                    response = urlopen(request, timeout=REQUEST_TIMEOUT_SECONDS)
                else:
                    response = opener.open(request, timeout=REQUEST_TIMEOUT_SECONDS)
                with response:
                    body = response.read()
                    return Response(
                        body=body,
                        headers=response.headers,
                        final_url=response.geturl(),
                    )
            except HTTPError as error:
                retryable = error.code == 429 or 500 <= error.code <= 599
                if not retryable or attempt == MAX_ATTEMPTS - 1:
                    raise RequestFailure(f"HTTP {error.code}: {error.reason}") from error
                retry_after = self._retry_after_seconds(error.headers)
                error.close()
            except (URLError, TimeoutError, socket.timeout, OSError) as error:
                if attempt == MAX_ATTEMPTS - 1:
                    raise RequestFailure(f"Network request failed: {error}") from error
                retry_after = None

            backoff = RETRY_BASE_SECONDS * (2**attempt)
            time.sleep(max(backoff, retry_after or 0.0))

        raise RequestFailure("Request exhausted its retry attempts")


def extract_original_urls(input_path: Path) -> list[str]:
    originals: OrderedDict[str, None] = OrderedDict()
    content = input_path.read_text(encoding="utf-8")
    for line in content.splitlines():
        url = line.strip()
        if not url or url.startswith("#"):
            continue
        wayback = urlsplit(url)
        if wayback.hostname != "web.archive.org":
            continue
        match = WAYBACK_PATH.match(wayback.path)
        if match is None:
            continue
        original = unquote(match.group(2))
        original_parts = urlsplit(original)
        if (original_parts.hostname != "www.epa.gov" 
            or not original_parts.path.startswith("/ejscreen/")): 
            print(f"Skipping non-EJScreen URL: {original}")
            continue
        else:
            print(f"Will attempt to retrieve wayback content for EJScreen URL: {original}")
            
        original = urlunsplit(
            (
                original_parts.scheme,
                original_parts.netloc,
                original_parts.path,
                original_parts.query,
                "",
            )
        )
        originals.setdefault(original, None)
    return list(originals)


def local_filename(original_url: str) -> str:
    final_component = unquote(urlsplit(original_url).path.rstrip("/").rsplit("/", 1)[-1])
    if (
        not final_component
        or final_component in {".", ".."}
        or SAFE_FILENAME.fullmatch(final_component) is None
    ):
        raise ValueError(f"Unsafe or missing filename component in URL: {original_url}")
    return f"{final_component}.html"


def find_latest_capture(client: RequestClient, original_url: str) -> tuple[str, str] | None:
    query = urlencode(
        {
            "url": original_url,
            "matchType": "exact",
            "output": "json",
            "filter": "statuscode:200",
            "fl": "timestamp,original",
            "limit": "-1",
        }
    )
    response = client.get(f"https://web.archive.org/cdx/search/cdx?{query}")
    try:
        rows = json.loads(response.body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ValueError(f"Invalid JSON from the Wayback CDX API: {error}") from error
    if not isinstance(rows, list) or not rows:
        raise ValueError("Unexpected response from the Wayback CDX API")

    captures: list[tuple[str, str]] = []
    for row in rows[1:]:
        if (
            isinstance(row, list)
            and len(row) >= 2
            and isinstance(row[0], str)
            and isinstance(row[1], str)
            and row[0].isdigit()
        ):
            capture_parts = urlsplit(row[1])
            if (
                capture_parts.hostname == "www.epa.gov"
                and capture_parts.path.startswith(
                    "/ejscreen/"
                )
            ):
                captures.append((row[0], row[1]))
    if not captures:
        return None
    return max(captures, key=lambda capture: capture[0])


def is_html_response(headers: object, body: bytes) -> bool:
    if not body.strip():
        return False
    if body.lstrip().startswith(b"%PDF-"):
        return False
    content_type = headers.get_content_type().lower()
    if content_type in {"text/html", "application/xhtml+xml"}:
        return True
    if content_type in {"application/octet-stream", "binary/octet-stream"}:
        return HTML_SIGNATURE.match(body[:1024]) is not None
    return False


def review_warning(body: bytes) -> str:
    text = body.decode("utf-8", errors="replace").casefold()
    matches = [phrase for phrase in REMOVAL_OR_ERROR_PHRASES if phrase in text]
    if matches:
        return "Possible Wayback error or EPA page-removal message: " + "; ".join(matches)
    return ""


def download_html(
    client: RequestClient,
    requested_url: str,
    destination: Path,
) -> tuple[str, str]:
    response = client.get(requested_url, reject_redirects=True)
    if urlsplit(response.final_url).hostname != "web.archive.org":
        raise ValueError(f"Download ended outside Wayback: {response.final_url}")
    if not is_html_response(response.headers, response.body):
        raise ValueError("Response was empty or did not appear to be HTML")

    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="wb",
            dir=destination.parent,
            prefix=f".{destination.name}.",
            suffix=".tmp",
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
            temporary_file.write(response.body)
        temporary_path.replace(destination)
    except OSError:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)
        raise

    return response.final_url, review_warning(response.body)


def load_manifest(path: Path) -> OrderedDict[str, dict[str, str]]:
    records: OrderedDict[str, dict[str, str]] = OrderedDict()
    if not path.exists():
        return records
    with path.open("r", encoding="utf-8-sig", newline="") as manifest_file:
        reader = csv.DictReader(manifest_file)
        if reader.fieldnames is None or any(
            field not in reader.fieldnames for field in MANIFEST_FIELDS
        ):
            raise ValueError(f"Manifest does not have the expected columns: {path}")
        for row in reader:
            original_url = row.get("Original EPA URL", "")
            if original_url:
                records[original_url] = {
                    field: row.get(field, "") or "" for field in MANIFEST_FIELDS
                }
    return records


def write_manifest(path: Path, records: Iterable[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            newline="",
            dir=path.parent,
            prefix=f".{path.name}.",
            suffix=".tmp",
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
            writer = csv.DictWriter(temporary_file, fieldnames=MANIFEST_FIELDS)
            writer.writeheader()
            writer.writerows(records)
        temporary_path.replace(path)
    except OSError:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)
        raise


def run(input_path: Path) -> int:
    if not input_path.is_file():
        raise ValueError(f"Input file not found: {input_path}")

    originals = extract_original_urls(input_path)
    print(f"Extracted {len(originals)} distinct EPA EJSCREEN indicator URLs:")
    for original in originals:
        print(f"  {original}")

    warning_count = 0
    output_directory = Path.cwd() / OUTPUT_DIRECTORY
    manifest_path = output_directory / MANIFEST_FILENAME
    output_directory.mkdir(parents=True, exist_ok=True)
    existing_records = load_manifest(manifest_path)
    records: OrderedDict[str, dict[str, str]] = OrderedDict()
    client = RequestClient()
    downloaded = skipped = missing = failed = 0

    for original_url in originals:
        print(f"Processing {original_url}")
        try:
            filename = local_filename(original_url)
        except ValueError as error:
            records[original_url] = {
                "Original EPA URL": original_url,
                "Selected capture timestamp": "",
                "Requested download URL": "",
                "Final download URL": "",
                "Local filename": "",
                "Result": "failed",
                "Warning or error message": str(error),
            }
            print(f"FAILED: {original_url}: {error}")
            failed += 1
            continue

        destination = output_directory / filename
        relative_filename = (OUTPUT_DIRECTORY / filename).as_posix()
        if destination.exists():
            skipped += 1
            if original_url in existing_records:
                records[original_url] = existing_records[original_url]
            else:
                records[original_url] = {
                    "Original EPA URL": original_url,
                    "Selected capture timestamp": "",
                    "Requested download URL": "",
                    "Final download URL": "",
                    "Local filename": relative_filename,
                    "Result": "skipped",
                    "Warning or error message": (
                        "Destination file already exists; it was not downloaded."
                    ),
                }
            print(f"SKIPPED: {destination} already exists")
            continue

        timestamp = ""
        requested_url = ""
        try:
            capture = find_latest_capture(client, original_url)
            if capture is None:
                missing += 1
                records[original_url] = {
                    "Original EPA URL": original_url,
                    "Selected capture timestamp": "",
                    "Requested download URL": "",
                    "Final download URL": "",
                    "Local filename": relative_filename,
                    "Result": "no capture",
                    "Warning or error message": "No successful capture was found.",
                }
                print(f"NO CAPTURE: {original_url}")
                continue

            timestamp, captured_original = capture
            requested_url = (
                f"https://web.archive.org/web/{timestamp}id_/"
                f"{quote(captured_original, safe=':/?&=#%')}"
            )
            final_url, content_warning = download_html(
                client, requested_url, destination
            )
            downloaded += 1
            warning_count += bool(content_warning)
            records[original_url] = {
                "Original EPA URL": original_url,
                "Selected capture timestamp": timestamp,
                "Requested download URL": requested_url,
                "Final download URL": final_url,
                "Local filename": relative_filename,
                "Result": "downloaded",
                "Warning or error message": content_warning,
            }
            if content_warning:
                print(f"WARNING: {original_url}: {content_warning}")
            print(f"DOWNLOADED: {destination} (capture {timestamp})")
        except (RequestFailure, ValueError, OSError) as error:
            failed += 1
            records[original_url] = {
                "Original EPA URL": original_url,
                "Selected capture timestamp": timestamp,
                "Requested download URL": requested_url,
                "Final download URL": "",
                "Local filename": relative_filename,
                "Result": "failed",
                "Warning or error message": str(error),
            }
            print(f"FAILED: {original_url}: {error}")

    write_manifest(manifest_path, records.values())
    print("\nCompletion report")
    print(f"URLs found: {len(originals)}")
    print(f"Files downloaded: {downloaded}")
    print(f"Files skipped: {skipped}")
    print(f"Missing captures: {missing}")
    print(f"Failures: {failed}")
    print(f"Warnings: {warning_count}")
    print(f"Output directory: {output_directory}")
    print(f"Manifest: {manifest_path}")
    return 1 if failed else 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Download the latest successful Wayback captures of EPA EJSCREEN "
            "indicator pages given a list of original EPA URLs."
        )
    )
    parser.add_argument("input_file", type=Path, help="Path to the file containing EPA URLs")
    args = parser.parse_args()
    try:
        return run(args.input_file)
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
