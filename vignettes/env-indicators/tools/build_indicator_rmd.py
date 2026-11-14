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

TOOLS_DIR = Path(__file__).resolve().parent
INPUT_DIRECTORY = TOOLS_DIR / "archived_html" / "pandocMarkdown"
OUTPUT_DIRECTORY = TOOLS_DIR / "archived_html" / "Rmd"
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
"""


def get_title(markdown: str, name: str) -> str:
    match = re.search(r"^# (.+)$", markdown, re.MULTILINE)
    if match is None:
        raise ValueError(f"{name}: no top-level heading found")
    # pandoc turned the original en dash into "--"
    title = match.group(1).strip().replace(" -- ", " \u2013 ")
    return title.replace("EJScreen Indicators Overview \u2013 ", "EJScreen Indicators: ")


def main() -> int:
    OUTPUT_DIRECTORY.mkdir(parents=True, exist_ok=True)
    
    sources = [p for p in sorted(INPUT_DIRECTORY.glob("*.md")) if not p.stem.endswith(EXAMPLE_SUFFIX)]
    print(f"Found {len(sources)} files to convert")
    if not sources:
        print(f"ERROR: no .md files in {INPUT_DIRECTORY}", file=sys.stderr)
        return 2

    failed = 0
    for source in sources:
        print(f"PROCESSING: {source.name}")
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
        # the title comes from the page's YAML, so drop the level-1 heading from the body
        body = re.sub(r"^# .+\n\n?", "", markdown, count=1, flags=re.MULTILINE)
        body = body.replace(" -- ", " \u2013 ")
        destination.write_text(HEADER.format(title=title) + body, encoding="utf-8", newline="\n")
        print(f"WROTE: {destination}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
