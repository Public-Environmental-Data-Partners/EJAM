#!/usr/bin/env python3
"""Turn the pandoc Markdown files into vignette .Rmd files in env-indicators.

For each .md file in archived_html/pandocMarkdown, prepend the vignette header
used by ejscreen-indicators-overview-ozone.Rmd and write the result to
env-indicators/<name>.Rmd. Existing .Rmd files are never overwritten.

Usage:
    python build_indicator_rmd.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

UTILITIES_DIRECTORY = Path(__file__).resolve().parent
INPUT_DIRECTORY = UTILITIES_DIRECTORY / "archived_html" / "pandocMarkdown"
OUTPUT_DIRECTORY = UTILITIES_DIRECTORY.parent
EXAMPLE_SUFFIX = "_chatgpt_example"

HEADER = """---
title: "{title}"
description: "{title}"
output:
  rmarkdown::html_vignette:
    toc: true
vignette: >
  %\\VignetteIndexEntry{{{title}}}
  %\\VignetteEngine{{knitr::rmarkdown}}
  %\\VignetteEncoding{{UTF-8}}
editor_options:
  markdown:
    wrap: 80
---
# TEMP: [test link back to Overview page](../overview-environmental-indicators-ejscreen.html)

"""


def get_title(markdown: str, name: str) -> str:
    match = re.search(r"^# (.+)$", markdown, re.MULTILINE)
    if match is None:
        raise ValueError(f"{name}: no top-level heading found")
    # pandoc turned the original en dash into "--"
    return match.group(1).strip().replace(" -- ", " \u2013 ")


def main() -> int:
    sources = [p for p in sorted(INPUT_DIRECTORY.glob("*.md")) if not p.stem.endswith(EXAMPLE_SUFFIX)]
    if not sources:
        print(f"ERROR: no .md files in {INPUT_DIRECTORY}", file=sys.stderr)
        return 2

    failed = 0
    for source in sources:
        destination = OUTPUT_DIRECTORY / f"{source.stem}.Rmd"
        if destination.exists():
            print(f"SKIPPED: {destination.name} already exists")
            continue
        try:
            markdown = source.read_text(encoding="utf-8")
            title = get_title(markdown, source.name)
        except ValueError as error:
            failed += 1
            print(f"FAILED: {error}")
            continue
        # pandoc turned the en dashes in the headings into "--"
        body = markdown.replace(" -- ", " \u2013 ")
        destination.write_text(HEADER.format(title=title) + body, encoding="utf-8", newline="\n")
        print(f"WROTE: {destination}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
