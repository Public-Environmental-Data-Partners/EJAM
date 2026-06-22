"""
ejam_issues_scoring_functions.py
=================================
Score EJAM GitHub issues on two independent dimensions (Cost and Benefit)
and generate inst/issues/ejam_issues_scored_by_risk_and_value.MD.

# ============================================================
# HOW TO REUSE THESE FUNCTIONS
# ============================================================
#
# ── Option 1: Run as a standalone script (re-fetch + regenerate .MD) ─────────
#
#   From the repository root, run:
#
#       python inst/issues/ejam_issues_scoring_functions.py \
#           --token YOUR_GITHUB_TOKEN \
#           --output inst/issues/ejam_issues_scored_by_risk_and_value.MD \
#           --scores-output inst/issues/ejam_issues_scored_by_risk_and_value.json \
#           --date 2026-05-30
#
#   --token   GitHub personal access token (optional, but raises rate limit
#             from 60 to 5000 requests/hour). Generate one at
#             https://github.com/settings/tokens  (no scopes needed for
#             public repos).
#   --output         Path to write the Markdown report (default shown above).
#   --scores-output  Path to write a JSON score payload for a later GitHub
#                    update task. This script never mutates GitHub issues.
#   --date           Date string embedded in the file header (default: today).
#
# ── Option 2: Import individual scoring functions ────────────────────────────
#
#   Place this file on your Python path (or run from the same directory),
#   then:
#
#       from ejam_issues_scoring_functions import (
#           cost_score,       # Score one issue on cost/effort dimension
#           benefit_score,    # Score one issue on value/urgency dimension
#           quadrant,         # Assign A/B/C/D quadrant label
#           score_issues,     # Score a full list of GitHub issue dicts
#           generate_markdown # Build the full 2-D ranked Markdown text
#       )
#
#   Example – score a single issue manually:
#
#       c = cost_score(
#           issue_title  = "Refactor spatial join to use sf package",
#           issue_labels = ["refactor", "shapefile-related"],
#           issue_body   = "This would require rewriting …"
#       )
#       b = benefit_score(
#           issue_title  = "Refactor spatial join to use sf package",
#           issue_labels = ["PRIORITY HIGH", "bug"],
#           issue_body   = "This would require rewriting …"
#       )
#       q = quadrant(cost=c, benefit=b, cost_threshold=3, benefit_threshold=7)
#       print(c, b, q)   # e.g.  7 14 B
#
# ── Option 3: Score a list of GitHub issue dicts ─────────────────────────────
#
#   If you already have a list of issue dicts in the GitHub REST API format
#   (e.g. obtained via fetch_all_open_issues() or any other means):
#
#       from ejam_issues_scoring_functions import (
#           fetch_all_open_issues, score_issues, generate_markdown
#       )
#
#       issues = fetch_all_open_issues(token="ghp_…")   # or supply your own list
#       scored, cost_med, benefit_med = score_issues(issues)
#
#       # scored is a list of dicts:
#       #   { num, title, labels, cost, benefit, quad }
#       # cost_med / benefit_med are the median thresholds used to split quadrants
#
#       md_text = generate_markdown(scored, cost_med, benefit_med,
#                                   generated_date="2026-05-19")
#       with open("inst/issues/ejam_issues_scored_by_risk_and_value.MD", "w") as fh:
#           fh.write(md_text)
#
# ── Extending the scoring rules ───────────────────────────────────────────────
#
#   All scoring logic lives in two functions:
#     • cost_score()    – keyword checks on title / labels / body length
#     • benefit_score() – priority label weights + keyword checks
#
#   Add or adjust the +/- point assignments inside those functions to tune
#   the model for new label conventions or different priorities.
#
# ── Requirements ─────────────────────────────────────────────────────────────
#
#   Standard-library only (no pip installs needed).
#   Python 3.9+.
#
# ============================================================
"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from datetime import date
from pathlib import Path

# ── GitHub API helpers ────────────────────────────────────────────────────────

OWNER = "Public-Environmental-Data-Partners"
REPO  = "EJAM"
URL_BASE = f"https://github.com/{OWNER}/{REPO}/issues/"
REPORT_SOURCE = f"Live GitHub REST API open issues ({OWNER}/{REPO})"
DEFAULT_MARKDOWN_OUTPUT = "inst/issues/ejam_issues_scored_by_risk_and_value.MD"
DEFAULT_SCORES_OUTPUT = "inst/issues/ejam_issues_scored_by_risk_and_value.json"

RANK_LABELS = {
    "A": "rank:A-high-value-low-cost",
    "B": "rank:B-high-value-high-cost",
    "C": "rank:C-low-value-low-cost",
    "D": "rank:D-defer",
}


def fetch_all_open_issues(token: str | None = None) -> list[dict]:
    """Fetch every open issue from the GitHub REST API (auto-paginates)."""
    import urllib.request

    headers = {"Accept": "application/vnd.github+json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    issues = []
    page = 1
    while True:
        url = (
            f"https://api.github.com/repos/{OWNER}/{REPO}/issues"
            f"?state=open&per_page=100&page={page}"
        )
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as resp:
            batch = json.loads(resp.read().decode())
        if not batch:
            break
        # filter out pull requests (they appear in /issues)
        issues.extend(i for i in batch if "pull_request" not in i)
        if len(batch) < 100:
            break
        page += 1
    return issues


def get_labels(issue: dict) -> list[str]:
    """Return a flat list of label name strings from a GitHub issue dict."""
    return [
        lbl if isinstance(lbl, str) else lbl["name"]
        for lbl in issue.get("labels", [])
    ]


# ── COST SCORE ────────────────────────────────────────────────────────────────
# Measures implementation complexity, risk, and expected effort.
# PRIORITY / BUG labels intentionally excluded here – they belong in benefit.

def cost_score(issue_title: str, issue_labels: list[str], issue_body: str) -> int:
    """
    Return an integer cost score (≥ 0).  Higher = harder / riskier.

    Parameters
    ----------
    issue_title  : str  – issue title
    issue_labels : list[str] – list of label names
    issue_body   : str  – issue body text (may be empty)
    """
    s = 0
    labs  = " ".join(issue_labels).lower()
    title = issue_title.lower()
    blen  = len(issue_body or "")

    # ── Label signals → cost ──────────────────────────────────────────────────
    if "datasets-related"   in labs: s += 4
    if "calculate/validate" in labs: s += 4
    if "speed / performance" in labs: s += 3
    if "future plan list"   in labs: s += 3
    if "tasklist"           in labs: s += 3
    if "shapefile-related"  in labs: s += 2
    if "refactor"           in labs: s += 2
    if "still relevant?"    in labs: s += 2
    if "from archive"       in labs: s += 1
    # documentation label lowers cost slightly (unless entangled with data/calc)
    if ("documentation" in labs
            and "calculate" not in labs
            and "datasets" not in labs):
        s -= 1

    # ── Title signals → HIGH cost ─────────────────────────────────────────────
    for kw in ("replicate", "validate", "resolve differences",
               "reconcile", "harmonize"):
        if kw in title:
            s += 4
            break
    for kw in ("dasymetric", "areal apportionment", "async"):
        if kw in title:
            s += 5
            break
    for kw in ("work in progress", "wip", "revisit", "draft", "revisiting"):
        if kw in title:
            s += 3
            break
    for kw in ("investigate", "review approach", "confirm", "decide whether"):
        if kw in title:
            s += 2
            break
    for kw in ("refactor", "move code", "restructure", "reorganize"):
        if kw in title:
            s += 2
            break
    for kw in ("module", "create a new", "enable the", "add ability", "develop "):
        if kw in title:
            s += 2
            break
    if "submit to cran" in title or re.search(r"\bcran\b", title):
        s += 4

    # ── Title signals → LOW cost (reduce score) ───────────────────────────────
    if any(x in title for x in ("readme", "update readme", "update the readme")):
        s -= 4
    if any(x in title for x in ("silence", "suppress message", "suppress warning")):
        s -= 3
    if any(x in title for x in ("remove na", "filter na", "hide na")):
        s -= 2
    if any(x in title for x in ("trim the", "remove unused", "delete unused")):
        s -= 2
    if any(x in title for x in ("rename param", "rename parameter", "rename column")):
        s -= 2
    if any(x in title for x in ("round to", "rounding", "format number")):
        s -= 2
    if any(x in title for x in ("news.md", "changelog", "update news")):
        s -= 3
    if any(x in title for x in ("update url", "update link", "fix link", "fix url")):
        s -= 3

    # ── Body length → complexity proxy ───────────────────────────────────────
    if blen > 3000:
        s += 4
    elif blen > 1500:
        s += 3
    elif blen > 700:
        s += 2
    elif blen > 250:
        s += 1
    elif blen < 50:
        s -= 1

    return max(s, 0)


# ── BENEFIT SCORE ─────────────────────────────────────────────────────────────
# Measures value, urgency, and importance of fixing the issue.

def benefit_score(issue_title: str, issue_labels: list[str], issue_body: str) -> int:
    """
    Return an integer benefit score (≥ 0).  Higher = more valuable / urgent.

    Parameters
    ----------
    issue_title  : str  – issue title
    issue_labels : list[str] – list of label names
    issue_body   : str  – issue body text (may be empty)
    """
    s = 0
    labs  = " ".join(issue_labels).lower()
    title = issue_title.lower()

    # ── PRIORITY label weight ─────────────────────────────────────────────────
    if "priority high" in labs and "high-ish" not in labs:
        s += 8
    elif "priority high-ish" in labs:
        s += 6
    elif "priority medium" in labs:
        s += 4
    elif "priority low" in labs:
        s += 1

    # ── BUG label ─────────────────────────────────────────────────────────────
    if "bug" in labs:
        s += 4
        if "priority high" in labs:
            s += 2  # extra urgency for high-priority bugs

    # ── Web app / API impact (broader user audience) ──────────────────────────
    if any(x in labs for x in ("web app", "webapp", "shiny")):
        s += 3
    if "api" in labs:
        s += 2

    # ── Title signals → high benefit ─────────────────────────────────────────
    if any(x in title for x in ("web app", "webapp", "shiny", "the app", "in app")):
        s += 2
    if any(x in title for x in ("api", "rest api")):
        s += 2
    if any(x in title for x in ("calculation", "calculates",
                                  "incorrect", "wrong", "error in")):
        s += 3
    if any(x in title for x in ("crash", "fail", "broken",
                                  "does not work", "doesn't work")):
        s += 4
    if any(x in title for x in ("submit to cran", "cran submission")):
        s += 3
    if any(x in title for x in ("major", "critical", "urgent")):
        s += 3

    # ── Low-value signals ─────────────────────────────────────────────────────
    if "documentation" in labs and "bug" not in labs:
        s -= 2
    if any(x in title for x in ("readme", "update readme")):
        s -= 3
    if any(x in title for x in ("silence", "suppress", "remove unused", "delete unused")):
        s -= 2
    if any(x in title for x in ("news.md", "changelog")):
        s -= 3
    if any(x in title for x in ("rename param", "rename parameter")):
        s -= 1
    if any(x in title for x in ("round to", "format number")):
        s -= 1
    # Unrated enhancement (no PRIORITY label set) ← small penalty
    if "enhancement" in labs and "priority" not in labs:
        s -= 1

    # retain-0325 = someone kept it intentionally
    if "retain-0325" in labs:
        s += 1

    return max(s, 0)


# ── QUADRANT ASSIGNMENT ───────────────────────────────────────────────────────

def quadrant(cost: int, benefit: int,
             cost_threshold: int, benefit_threshold: int) -> str:
    """
    Return a single letter for the 2×2 quadrant:
      A = low cost, high benefit  → BEST CANDIDATES
      B = high cost, high benefit → OK Candidates
      C = low cost, low benefit   → Might As Well
      D = high cost, low benefit  → WORST CANDIDATES
    """
    hi_c = cost    >= cost_threshold
    hi_b = benefit >= benefit_threshold
    if not hi_c and hi_b:     return "A"
    if hi_c     and hi_b:     return "B"
    if not hi_c and not hi_b: return "C"
    return "D"


# ── MARKDOWN GENERATION ───────────────────────────────────────────────────────

def get_priority_label(labels: list[str]) -> str:
    for lbl in labels:
        if "PRIORITY" in lbl:
            return lbl
    return "—"


def rank_comment_body(issue: dict, generated_date: str,
                      report_path: str) -> str:
    return "\n".join([
        f"Last ranked: {generated_date}",
        f"Cost score: {issue['cost']}",
        f"Benefit score: {issue['benefit']}",
        f"Quadrant: {issue['quad']}",
        f"Run report: {report_path}",
    ])


def empty_run_changes() -> dict:
    return {
        "previous_run": None,
        "opened_count": None,
        "closed_count": None,
        "quadrant_changed_count": None,
        "opened_issue_numbers": [],
        "closed_issue_numbers": [],
        "quadrant_changed_issue_numbers": [],
    }


def load_previous_score_payload(path: str) -> dict | None:
    score_path = Path(path)
    if not score_path.exists():
        return None
    with score_path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def _issue_number(issue: dict) -> int:
    return int(issue.get("number", issue.get("num")))


def _issue_quadrant(issue: dict) -> str | None:
    return issue.get("quadrant", issue.get("quad"))


def summarize_run_changes(scored_issues: list[dict],
                          previous_payload: dict | None) -> dict:
    if not previous_payload:
        return empty_run_changes()

    previous_issues = {
        _issue_number(issue): issue
        for issue in previous_payload.get("issues", [])
    }
    current_issues = {
        _issue_number(issue): issue
        for issue in scored_issues
    }

    previous_numbers = set(previous_issues)
    current_numbers = set(current_issues)
    opened = sorted(current_numbers - previous_numbers)
    closed = sorted(previous_numbers - current_numbers)
    still_open = previous_numbers & current_numbers
    changed_quadrants = sorted(
        num for num in still_open
        if _issue_quadrant(previous_issues[num]) != _issue_quadrant(current_issues[num])
    )

    return {
        "previous_run": previous_payload.get("metadata", {}).get("generated"),
        "opened_count": len(opened),
        "closed_count": len(closed),
        "quadrant_changed_count": len(changed_quadrants),
        "opened_issue_numbers": opened,
        "closed_issue_numbers": closed,
        "quadrant_changed_issue_numbers": changed_quadrants,
    }


def build_score_payload(scored_issues: list[dict],
                        cost_med: int, benefit_med: int,
                        generated_date: str,
                        report_path: str,
                        run_changes: dict | None = None) -> dict:
    run_changes = run_changes or empty_run_changes()
    issues = []
    for r in scored_issues:
        rank_label = RANK_LABELS[r["quad"]]
        issues.append({
            "number": r["num"],
            "title": r["title"],
            "url": f"{URL_BASE}{r['num']}",
            "existing_labels": r["labels"],
            "cost": r["cost"],
            "benefit": r["benefit"],
            "quadrant": r["quad"],
            "rank_label": rank_label,
            "rank_labels_to_remove": [
                label for quad, label in RANK_LABELS.items()
                if quad != r["quad"]
            ],
            "rank_comment": rank_comment_body(r, generated_date, report_path),
        })

    return {
        "metadata": {
            "generated": generated_date,
            "source": REPORT_SOURCE,
            "repository": f"{OWNER}/{REPO}",
            "open_issue_count": len(scored_issues),
            "cost_median": cost_med,
            "benefit_median": benefit_med,
            "rank_labels": RANK_LABELS,
            "report_path": report_path,
            "run_changes": run_changes,
        },
        "issues": issues,
    }


def cost_tier(c: int) -> str:
    if c <= 1:    return "🟢 Very Low"
    elif c <= 3:  return "🔵 Low"
    elif c <= 6:  return "🟡 Medium"
    elif c <= 10: return "🟠 High"
    return "⛔ Very High"


def benefit_tier(b: int) -> str:
    if b <= 1:    return "⬜ Very Low"
    elif b <= 4:  return "⬜ Low"
    elif b <= 8:  return "🟦 Medium"
    elif b <= 12: return "🟩🟦 High"
    return "🟩🟩 Very High"


def _write_quad(lines: list[str], letter: str, heading: str, desc: str,
                issues: list[dict]) -> None:
    lines.append(f"## Quadrant {letter} — {heading}")
    lines.append(f"*{desc}*")
    lines.append("")
    lines.append(f"**{len(issues)} issues**")
    lines.append("")
    for r in issues:
        plbl    = get_priority_label(r["labels"])
        bug_tag = " 🐛" if any("bug" in l.lower() for l in r["labels"]) else ""
        lines.append(
            f"- [#{r['num']}]({URL_BASE}{r['num']}) | "
            f"Cost {r['cost']} / Benefit {r['benefit']} | "
            f"{plbl}{bug_tag} — {r['title']}"
        )
    lines.append("")
    lines.append("| # | Issue | Cost | Benefit | Priority | Labels (key) |")
    lines.append("|---|-------|------|---------|----------|--------------|")
    for r in issues:
        plbl     = get_priority_label(r["labels"])
        key_labs = [
            l for l in r["labels"]
            if l not in ("enhancement", "retain-0325", "from archive")
            and "PRIORITY" not in l
        ]
        lab_str  = ", ".join(key_labs[:4])
        short    = r["title"][:70] + ("…" if len(r["title"]) > 70 else "")
        lines.append(
            f"| [{r['num']}]({URL_BASE}{r['num']}) | {short} | "
            f"{r['cost']} ({cost_tier(r['cost'])}) | "
            f"{r['benefit']} ({benefit_tier(r['benefit'])}) | "
            f"{plbl} | {lab_str} |"
        )
    lines.append("")
    lines.append("---")
    lines.append("")


def generate_markdown(scored_issues: list[dict],
                      cost_med: int, benefit_med: int,
                      generated_date: str = "2026-05-30",
                      score_output_path: str | None = DEFAULT_SCORES_OUTPUT,
                      run_changes: dict | None = None) -> str:
    """
    Build and return the full Markdown text for
    inst/issues/ejam_issues_scored_by_risk_and_value.MD.

    Parameters
    ----------
    scored_issues  : list of dicts with keys num, title, labels, cost, benefit, quad
    cost_med       : median cost score (split threshold)
    benefit_med    : median benefit score (split threshold)
    generated_date : date string for the header
    score_output_path : JSON score payload path for later GitHub updates
    run_changes    : optional previous-run comparison counts
    """
    run_changes = run_changes or empty_run_changes()
    n = len(scored_issues)
    quads: dict[str, list[dict]] = {"A": [], "B": [], "C": [], "D": []}
    for r in scored_issues:
        quads[r["quad"]].append(r)

    quads["A"].sort(key=lambda x: (-x["benefit"], x["cost"]))
    quads["B"].sort(key=lambda x: (-x["benefit"], x["cost"]))
    quads["C"].sort(key=lambda x: (-x["benefit"], x["cost"]))
    quads["D"].sort(key=lambda x: (x["cost"], -x["benefit"]))

    lines: list[str] = []
    lines.append("# EJAM Open Issues — Scored by Cost & Benefit")
    lines.append("")
    lines.append(
        f"**Total open issues:** {n}  |  **Generated:** {generated_date}  |  "
        f"**Source:** {REPORT_SOURCE}"
    )
    if score_output_path:
        lines.append("")
        lines.append(f"**Score payload:** `{score_output_path}`")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Overview")
    lines.append("")
    lines.append("Each issue is scored independently on two dimensions:")
    lines.append("")
    lines.append("| Dimension | What it measures | Key inputs |")
    lines.append("|-----------|-----------------|------------|")
    lines.append(
        "| **Cost** (complexity / risk / effort) | How hard is it to fix safely? | "
        "WIP/unclear state, data pipeline, spatial methods, refactor scope, body length, "
        "architecture labels |"
    )
    lines.append(
        "| **Benefit** (value / urgency / importance) | How much does fixing it matter? | "
        "PRIORITY label, BUG label, web app vs R-only impact, crash/wrong-calculation "
        "signals, CRAN visibility |"
    )
    costs    = sorted(r["cost"]    for r in scored_issues)
    benefits = sorted(r["benefit"] for r in scored_issues)
    lines.append("")
    lines.append("### Previous-run comparison")
    lines.append("")
    lines.append("| Metric | Value |")
    lines.append("|--------|-------|")
    lines.append(
        f"| Previous run | {run_changes['previous_run'] or 'not available'} |"
    )
    opened = (
        "not available" if run_changes["opened_count"] is None
        else str(run_changes["opened_count"])
    )
    closed = (
        "not available" if run_changes["closed_count"] is None
        else str(run_changes["closed_count"])
    )
    changed = (
        "not available" if run_changes["quadrant_changed_count"] is None
        else str(run_changes["quadrant_changed_count"])
    )
    lines.append(f"| Issues opened since previous run | {opened} |")
    lines.append(f"| Issues closed since previous run | {closed} |")
    lines.append(f"| Issues whose quadrant changed | {changed} |")
    lines.append("")
    lines.append("### GitHub rank labels for a later update task")
    lines.append("")
    lines.append("This scoring script writes the labels below into the JSON payload, but it does not apply them to GitHub.")
    lines.append("")
    lines.append("| Quadrant | Label |")
    lines.append("|----------|-------|")
    for quad in ("A", "B", "C", "D"):
        lines.append(f"| {quad} | `{RANK_LABELS[quad]}` |")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 2×2 Priority Matrix")
    lines.append("")
    lines.append("```")
    lines.append("                │  LOW Benefit          │  HIGH Benefit")
    lines.append("                │  (value < median)     │  (value ≥ median)")
    lines.append("────────────────┼───────────────────────┼───────────────────────")
    lines.append(f" LOW Cost       │  C — Might As Well    │  A — BEST CANDIDATES")
    lines.append(f" (cost < med.)  │  {len(quads['C'])} issues                │  {len(quads['A'])} issues")
    lines.append("────────────────┼───────────────────────┼───────────────────────")
    lines.append(f" HIGH Cost      │  D — WORST CANDIDATES │  B — OK Candidates")
    lines.append(f" (cost ≥ med.)  │  {len(quads['D'])} issues                │  {len(quads['B'])} issues")
    lines.append("```")
    lines.append("")
    lines.append("---")
    lines.append("")

    _write_quad(lines, "A",
                "BEST CANDIDATES — Low Cost, High Benefit",
                "Easy fixes with clear high value. Prioritize these above all others.",
                quads["A"])
    _write_quad(lines, "B",
                "OK Candidates — High Cost, High Benefit",
                "Worth doing but require more effort or expertise. Plan carefully before starting.",
                quads["B"])
    _write_quad(lines, "C",
                "Might As Well — Low Cost, Low Benefit",
                "Cheap to do; low urgency. Pick these up when bandwidth allows or combine with nearby work.",
                quads["C"])
    _write_quad(lines, "D",
                "WORST CANDIDATES — High Cost, Low Benefit",
                "Expensive to fix, limited payoff. Defer or deprioritize unless circumstances change.",
                quads["D"])

    lines.append(f"## Full Table — All {n} Issues")
    lines.append("")
    lines.append("Sorted: A first (best), then B, C, D; within each group by benefit DESC.")
    lines.append("")
    lines.append("| Quad | Issue # | Cost | Benefit | Priority | Title |")
    lines.append("|------|---------|------|---------|----------|-------|")
    for letter in ("A", "B", "C", "D"):
        for r in quads[letter]:
            plbl  = get_priority_label(r["labels"])
            short = r["title"][:72] + ("…" if len(r["title"]) > 72 else "")
            lines.append(
                f"| {letter} | [{r['num']}]({URL_BASE}{r['num']}) | "
                f"{r['cost']} | {r['benefit']} | {plbl} | {short} |"
            )

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("### Score ranges")
    lines.append("")
    lines.append("| Dimension | Range | Median (split threshold) |")
    lines.append("|-----------|-------|--------------------------|")
    lines.append(f"| Cost    | {costs[0]} – {costs[-1]}    | {cost_med} |")
    lines.append(f"| Benefit | {benefits[0]} – {benefits[-1]} | {benefit_med} |")
    lines.append("")
    lines.append(
        "Issues at or above the median are **High**; below are **Low** "
        "for that dimension."
    )
    lines.append("")
    lines.append("## Scoring Factors")
    lines.append("")
    lines.append("### Cost factors (higher = harder/riskier)")
    lines.append("")
    lines.append("| Factor | Points |")
    lines.append("|--------|--------|")
    lines.append("| datasets-related or calculate/validate label | +4 |")
    lines.append("| speed/performance label | +3 |")
    lines.append("| future plan list / tasklist label | +3 each |")
    lines.append("| shapefile / spatial label | +2 |")
    lines.append("| refactor / still relevant? labels | +2 each |")
    lines.append("| Title: replicate/validate/resolve/reconcile | +4 |")
    lines.append("| Title: dasymetric / areal apportionment / async | +5 |")
    lines.append("| Title: WIP / revisit / draft | +3 |")
    lines.append("| Title: investigate / decide | +2 |")
    lines.append("| Title: refactor / restructure | +2 |")
    lines.append("| Title: new module / create / enable | +2 |")
    lines.append("| Title: CRAN submission | +4 |")
    lines.append("| Body length >3000 chars | +4 |")
    lines.append("| Body length 1500–3000 chars | +3 |")
    lines.append("| Body length 700–1500 chars | +2 |")
    lines.append("| Body length 250–700 chars | +1 |")
    lines.append("| Title: README / suppress / remove unused / rename param / round / changelog / fix link | −2 to −4 |")
    lines.append("| documentation label (no calculate/datasets) | −1 |")
    lines.append("")
    lines.append("### Benefit factors (higher = more valuable/urgent)")
    lines.append("")
    lines.append("| Factor | Points |")
    lines.append("|--------|--------|")
    lines.append("| PRIORITY HIGH label | +8 |")
    lines.append("| PRIORITY HIGH-ish label | +6 |")
    lines.append("| PRIORITY MEDIUM label | +4 |")
    lines.append("| PRIORITY LOW label | +1 |")
    lines.append("| BUG label | +4 (+2 extra if also PRIORITY HIGH) |")
    lines.append("| web app / shiny label | +3 |")
    lines.append("| API label | +2 |")
    lines.append("| Title: web app / shiny / in app | +2 |")
    lines.append("| Title: API | +2 |")
    lines.append("| Title: calculation wrong / incorrect / error in | +3 |")
    lines.append("| Title: crash / fail / broken / does not work | +4 |")
    lines.append("| Title: CRAN submission | +3 |")
    lines.append("| Title: major / critical / urgent | +3 |")
    lines.append("| retain-0325 label | +1 |")
    lines.append("| documentation label (no bug) | −2 |")
    lines.append("| Title: README / silence / suppress | −2 to −3 |")
    lines.append("| Title: changelog / NEWS.md | −3 |")
    lines.append("| Unrated enhancement (no PRIORITY label) | −1 |")

    return "\n".join(lines)


# ── MAIN ENTRY POINT ──────────────────────────────────────────────────────────

def score_issues(issues: list[dict]) -> tuple[list[dict], int, int]:
    """
    Score a list of GitHub issue dicts and return (scored_list, cost_med, benefit_med).

    Each element of scored_list is a dict with keys:
        num, title, labels, cost, benefit, quad
    """
    scored = []
    for issue in issues:
        labels = get_labels(issue)
        body   = issue.get("body") or ""
        title  = issue.get("title", "")
        c = cost_score(title, labels, body)
        b = benefit_score(title, labels, body)
        scored.append({
            "num":     issue["number"],
            "title":   title,
            "labels":  labels,
            "cost":    c,
            "benefit": b,
        })

    all_costs    = sorted(r["cost"]    for r in scored)
    all_benefits = sorted(r["benefit"] for r in scored)
    n            = len(scored)
    cost_med    = all_costs[n // 2]
    benefit_med = all_benefits[n // 2]

    for r in scored:
        r["quad"] = quadrant(r["cost"], r["benefit"], cost_med, benefit_med)

    return scored, cost_med, benefit_med


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Re-score EJAM issues and regenerate the 2D markdown file."
    )
    parser.add_argument(
        "--token", default=None,
        help="GitHub personal access token (optional; increases rate limit)"
    )
    parser.add_argument(
        "--output",
        default=DEFAULT_MARKDOWN_OUTPUT,
        help="Path for the output .MD file"
    )
    parser.add_argument(
        "--scores-output",
        default=DEFAULT_SCORES_OUTPUT,
        help="Path for the output JSON score payload"
    )
    parser.add_argument(
        "--date", default=date.today().isoformat(),
        help="Generated-date string to embed in the header"
    )
    args = parser.parse_args()

    previous_payload = load_previous_score_payload(args.scores_output)

    print("Fetching open issues from GitHub …")
    issues = fetch_all_open_issues(token=args.token)
    print(f"  {len(issues)} open issues fetched.")

    scored, cost_med, benefit_med = score_issues(issues)
    print(
        f"  Cost range  {min(r['cost']    for r in scored)}–"
        f"{max(r['cost']    for r in scored)}, median={cost_med}"
    )
    print(
        f"  Benefit range {min(r['benefit'] for r in scored)}–"
        f"{max(r['benefit'] for r in scored)}, median={benefit_med}"
    )

    run_changes = summarize_run_changes(scored, previous_payload)
    md = generate_markdown(
        scored, cost_med, benefit_med,
        generated_date=args.date,
        score_output_path=args.scores_output,
        run_changes=run_changes,
    )
    score_payload = build_score_payload(
        scored, cost_med, benefit_med,
        generated_date=args.date,
        report_path=args.output,
        run_changes=run_changes,
    )

    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as fh:
        fh.write(md)
    print(f"Written: {args.output}  ({len(md):,} bytes)")

    Path(args.scores_output).parent.mkdir(parents=True, exist_ok=True)
    with open(args.scores_output, "w", encoding="utf-8") as fh:
        json.dump(score_payload, fh, ensure_ascii=False, indent=2)
        fh.write("\n")
    print(f"Written: {args.scores_output}")


if __name__ == "__main__":
    main()
