#!/usr/bin/env python3
"""Extract the main article content from archived EPA EJSCREEN indicator pages.

Reads every .html file in archived_html/asDownloaded and writes a minimal HTML
document containing only the page's <article> to archived_html/htmlScrubbed.
Requires beautifulsoup4. Existing output files are overwritten.

Usage:
    python scrub_archived_html.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

from bs4 import BeautifulSoup, Comment, Tag

BASE_DIRECTORY = Path(__file__).resolve().parent / "archived_html"
INPUT_DIRECTORY = BASE_DIRECTORY / "asDownloaded"
OUTPUT_DIRECTORY = BASE_DIRECTORY / "htmlScrubbed"
EPA_BASE_URL = "https://www.epa.gov/ejscreen/"
LAST_UPDATED = re.compile(r"Last updated on\s+(.+)", re.IGNORECASE)
VOID_CONTENT_TAGS = {"img", "br", "hr"}
REMOVED_TAGS = ("script", "style", "noscript", "form")
KEPT_ARTICLE_ATTRIBUTES = {"lang"}


class ScrubError(ValueError):
    pass


def find_last_updated(soup: BeautifulSoup) -> str:
    footer = soup.find(class_="l-page__footer-last-updated")
    match = LAST_UPDATED.search(footer.get_text(strip=True)) if footer else None
    if match is None:
        raise ScrubError("Could not find the 'Last updated on' line")
    return match.group(1).strip().rstrip(".")


def has_content(tag: Tag) -> bool:
    return bool(tag.get_text(strip=True)) or tag.name in VOID_CONTENT_TAGS or bool(
        tag.find(VOID_CONTENT_TAGS)
    )


def clean_article(article: Tag) -> None:
    for comment in article.find_all(string=lambda text: isinstance(text, Comment)):
        comment.extract()
    for tag in article.find_all(REMOVED_TAGS):
        tag.decompose()
    # Editing-interface placeholders that sit between the title and the body.
    for tag in article.find_all(class_="js-toggle-admin-content"):
        tag.decompose()

    for tag in article.find_all(True):
        for attribute in list(tag.attrs):
            if attribute.startswith("data-") or attribute in {"class", "id", "tabindex"}:
                del tag.attrs[attribute]
    article.attrs = {k: v for k, v in article.attrs.items() if k in KEPT_ARTICLE_ATTRIBUTES}

    # Repeat until stable because removing an empty child can empty its parent.
    changed = True
    while changed:
        changed = False
        for tag in article.find_all(True):
            if tag.name in {"div", "span"} and not tag.attrs:
                tag.unwrap()
                changed = True
            elif not has_content(tag):
                tag.decompose()
                changed = True


def tidy_whitespace(markup: str) -> str:
    lines = (line.rstrip() for line in markup.splitlines())
    return "\n".join(line for line in lines if line.strip())


def scrub(source_path: Path) -> str:
    soup = BeautifulSoup(source_path.read_text(encoding="utf-8"), "html.parser")
    articles = soup.find_all("article")
    if len(articles) != 1:
        raise ScrubError(f"Expected exactly one <article>, found {len(articles)}")
    article = articles[0]
    title = article.find("h1")
    if title is None:
        raise ScrubError("Article has no <h1>")
    title_text = " ".join(title.get_text().split())
    last_updated = find_last_updated(soup)

    clean_article(article)
    original_url = f"{EPA_BASE_URL}{source_path.stem}"
    return (
        "<!DOCTYPE html>\n"
        '<html lang="en">\n'
        "<head>\n"
        '<meta charset="utf-8">\n'
        f"<title>{title_text}</title>\n"
        "</head>\n"
        "<body>\n"
        f"<!-- Original source: {original_url} -->\n"
        f"<!-- Original EPA page last updated: {last_updated}. "
        "This is not the archive capture date. -->\n"
        f"{tidy_whitespace(str(article))}\n"
        "</body>\n"
        "</html>\n"
    )


def main() -> int:
    sources = sorted(INPUT_DIRECTORY.glob("*.html"))
    if not sources:
        print(f"ERROR: no .html files in {INPUT_DIRECTORY}", file=sys.stderr)
        return 2

    OUTPUT_DIRECTORY.mkdir(parents=True, exist_ok=True)
    failed = 0
    for source_path in sources:
        try:
            output = scrub(source_path)
        except ScrubError as error:
            failed += 1
            print(f"FAILED: {source_path.name}: {error}")
            continue
        (OUTPUT_DIRECTORY / source_path.name).write_text(output, encoding="utf-8", newline="\n")
        print(f"WROTE: {OUTPUT_DIRECTORY / source_path.name}")

    print(f"\n{len(sources) - failed} written, {failed} failed. Output: {OUTPUT_DIRECTORY}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
