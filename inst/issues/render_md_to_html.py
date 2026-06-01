#!/usr/bin/env python3
from __future__ import annotations

import argparse
import html
import subprocess
import sys
from pathlib import Path


def render_with_pandoc(md_path: Path, html_path: Path) -> bool:
    pandoc_wrapper = Path("inst/tools/pandoc")
    if not pandoc_wrapper.is_file():
        return False
    try:
        subprocess.run(
            [str(pandoc_wrapper), "-s", str(md_path), "-o", str(html_path)],
            check=True,
        )
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

