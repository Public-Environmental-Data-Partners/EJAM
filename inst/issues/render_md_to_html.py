#!/usr/bin/env python3
from __future__ import annotations

import argparse
import html
import re
import subprocess
import sys
from pathlib import Path


ISSUE_TABLE_COLGROUP = """<colgroup>
<col style="width: 5%" />
<col style="width: 18%" />
<col style="width: 14%" />
<col style="width: 18%" />
<col style="width: 9%" />
<col style="width: 16%" />
<col style="width: 20%" />
</colgroup>"""

ISSUE_TABLE_STYLE = """
  <style>
    body {
      max-width: 80em;
    }
    table.issue-details {
      display: table;
      table-layout: fixed;
      min-width: 64em;
      width: 100%;
    }
    table.issue-details th:first-child,
    table.issue-details td:first-child {
      white-space: nowrap;
    }
    table.issue-details th:nth-child(5) {
      white-space: nowrap;
    }
    table.issue-details th:nth-child(2),
    table.issue-details td:nth-child(2) {
      hyphens: auto;
      overflow-wrap: break-word;
      white-space: normal;
    }
    table.issue-details th:nth-child(3),
    table.issue-details td:nth-child(3),
    table.issue-details th:nth-child(4),
    table.issue-details td:nth-child(4) {
      hyphens: none;
      overflow-wrap: normal;
      white-space: nowrap;
    }
  </style>
"""


def style_issue_tables(html_path: Path) -> None:
    """Apply report-specific widths to tables with Issue and Labels columns."""
    document = html_path.read_text(encoding="utf-8")
    styled_table_count = 0

    def add_issue_table_layout(match: re.Match) -> str:
        nonlocal styled_table_count
        table = match.group(0)
        if "<th>Issue</th>" not in table or "<th>Labels (key)</th>" not in table:
            return table
        styled_table_count += 1
        table = table.replace("<table>", '<table class="issue-details">', 1)
        return re.sub(
            r"<colgroup>.*?</colgroup>",
            ISSUE_TABLE_COLGROUP,
            table,
            count=1,
            flags=re.DOTALL,
        )

    document = re.sub(
        r"<table>.*?</table>",
        add_issue_table_layout,
        document,
        flags=re.DOTALL,
    )
    if styled_table_count and "</head>" in document:
        document = document.replace("</head>", f"{ISSUE_TABLE_STYLE}</head>", 1)
    html_path.write_text(document, encoding="utf-8")


def render_with_pandoc(md_path: Path, html_path: Path) -> bool:
    pandoc_wrapper = Path("inst/tools/pandoc")
    if not pandoc_wrapper.is_file():
        return False
    try:
        subprocess.run(
            [str(pandoc_wrapper), "-s", str(md_path), "-o", str(html_path)],
            check=True,
        )
        style_issue_tables(html_path)
        return True
    except Exception:
        return False


def render_pre_fallback(md_path: Path, html_path: Path) -> None:
    md = md_path.read_text(encoding="utf-8")
    out = (
        "<!doctype html><meta charset=\"utf-8\">"
        "<title>EJAM issues scored</title>"
        "<pre style=\"white-space:pre-wrap;font-family:ui-monospace,Menlo,Monaco,Consolas,monospace\">"
        + html.escape(md)
        + "</pre>"
    )
    html_path.write_text(out, encoding="utf-8")


def main() -> None:
    p = argparse.ArgumentParser(
        description="Render EJAM issue-scoring Markdown to HTML (prefers RStudio's pandoc)."
    )
    p.add_argument("--input", required=True, help="Path to input Markdown file")
    p.add_argument("--output", required=True, help="Path to output HTML file")
    args = p.parse_args()

    md_path = Path(args.input)
    html_path = Path(args.output)
    if not md_path.is_file():
        raise SystemExit(f"Input Markdown not found: {md_path}")

    html_path.parent.mkdir(parents=True, exist_ok=True)

    if render_with_pandoc(md_path, html_path):
        return

    render_pre_fallback(md_path, html_path)


if __name__ == "__main__":
    main()
