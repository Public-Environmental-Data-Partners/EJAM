"""
ejam_issues_scoring_functions.py
=================================
Score EJAM GitHub issues on two independent dimensions (Cost and Benefit)
and publish the Markdown ranking in a comment on GitHub issue #715.

# ============================================================
# HOW TO REUSE THESE FUNCTIONS
# ============================================================
#
# ── Option 1: Run as a standalone script ──────────────────────────────
#
#   From the repository root, run:
#
#       python inst/issues/ejam_issues_scoring_functions.py \
#           --token YOUR_GITHUB_TOKEN \
#           --publish \
#           --issue-number 715 \
#           --date 2026-05-30
#
#   --token          GitHub token. If omitted, use GH_TOKEN, GITHUB_TOKEN, or
#                    the token returned by `gh auth token`.
#   --publish        Create or replace the marked ranking comment.
#   --issue-number   Issue that owns the ranking comment (default: 715).
#   --output         Optional local Markdown output path for debugging.
#   --date           Date string embedded in the report (default: today).
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
#       #   { num, title, labels, milestone, cost, benefit, quad }
#       # cost_med / benefit_med are the median thresholds used to split quadrants
#
#       md_text = generate_markdown(scored, cost_med, benefit_med,
#                                   generated_date="2026-05-19")
#       print(md_text)
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
import os
import re
import subprocess
from collections import Counter
from datetime import date
from pathlib import Path

# ── GitHub API helpers ────────────────────────────────────────────────────────

OWNER = "Public-Environmental-Data-Partners"
REPO  = "EJAM"
URL_BASE = f"https://github.com/{OWNER}/{REPO}/issues/"
REPORT_SOURCE = f"Live GitHub REST API open issues ({OWNER}/{REPO})"
DEFAULT_ISSUE_NUMBER = 715
RANKING_COMMENT_MARKER = "<!-- ejam-open-issues-ranking-report -->"
RANKING_REPORT_HEADING = "# EJAM Open Issues — Scored by Cost & Benefit"
MAX_QUADRANT_A_ISSUES = 20

RANK_LABELS = {
    "A": "rank:A-high-value-low-cost",
    "B": "rank:B-high-value-high-cost",
    "C": "rank:C-low-value-low-cost",
    "D": "rank:D-defer",
}


def fetch_all_open_issues(token: str | None = None,
                          exclude_issue_number: int | None = None) -> list[dict]:
    """Fetch open issues, excluding pull requests and the report container."""
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
        # Pull requests appear in /issues. The destination issue only stores
        # the report, so ranking it would make the report affect itself.
        issues.extend(
            issue for issue in batch
            if "pull_request" not in issue
            and issue["number"] != exclude_issue_number
        )
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


def get_milestone(issue: dict) -> str:
    """Return the issue's milestone title, or ``NA`` when none is assigned."""
    milestone = issue.get("milestone")
    if not milestone:
        return "NA"
    if isinstance(milestone, str):
        return milestone
    return milestone.get("title") or "NA"


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


def cap_quadrant_a(scored_issues: list[dict]) -> None:
    """Keep Quadrant A small enough to serve as an actionable focus list.

    Median thresholds identify the low-cost, high-benefit candidates.  When
    there are more than the focus-list limit, retain the highest-benefit,
    lowest-cost candidates in A and move the rest to C as lower-priority
    low-cost work.
    """
    candidates = sorted(
        (issue for issue in scored_issues if issue["quad"] == "A"),
        key=lambda issue: (-issue["benefit"], issue["cost"], issue["num"]),
    )
    for issue in candidates[MAX_QUADRANT_A_ISSUES:]:
        issue["quad"] = "C"


# ── MARKDOWN GENERATION ───────────────────────────────────────────────────────

def get_priority_label(labels: list[str]) -> str:
    for lbl in labels:
        if "PRIORITY" in lbl:
            return lbl
    return "—"


def resolve_github_token(token: str | None = None) -> str | None:
    """Find a token suitable for publishing an issue comment."""
    if token:
        return token
    for variable in ("GH_TOKEN", "GITHUB_TOKEN"):
        value = os.environ.get(variable)
        if value:
            return value
    try:
        result = subprocess.run(
            ["gh", "auth", "token"],
            check=True,
            capture_output=True,
            text=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None
    return result.stdout.strip() or None


def github_api_request(method: str, path: str, token: str,
                       payload: dict | None = None):
    """Call one EJAM GitHub REST endpoint and decode its JSON response."""
    import urllib.request

    url = f"https://api.github.com/repos/{OWNER}/{REPO}{path}"
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "User-Agent": "ejam-open-issue-ranking",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    request = urllib.request.Request(
        url, data=body, headers=headers, method=method
    )
    with urllib.request.urlopen(request) as response:
        response_body = response.read()
    return json.loads(response_body.decode("utf-8")) if response_body else None


def fetch_issue_comments(issue_number: int, token: str,
                         request=github_api_request) -> list[dict]:
    """Fetch every comment on the issue that owns the ranking report."""
    comments: list[dict] = []
    page = 1
    while True:
        batch = request(
            "GET",
            f"/issues/{issue_number}/comments?per_page=100&page={page}",
            token,
        )
        comments.extend(batch)
        if len(batch) < 100:
            return comments
        page += 1


def find_ranking_comment(comments: list[dict]) -> dict | None:
    """Find the marked report comment, adopting the original heading once.

    Only a comment that begins with the marker counts. A comment that merely
    quotes the marker, such as instructions or a code block, is never
    selected, so it is not overwritten and does not count as a duplicate.
    """
    def body_of(comment: dict) -> str:
        return (comment.get("body") or "").lstrip()

    marked = [
        comment for comment in comments
        if body_of(comment).startswith(RANKING_COMMENT_MARKER)
    ]
    if len(marked) > 1:
        raise RuntimeError("More than one ranking comment starts with the marker")
    if marked:
        return marked[0]

    legacy = [
        comment for comment in comments
        if body_of(comment).startswith(RANKING_REPORT_HEADING)
    ]
    if len(legacy) > 1:
        raise RuntimeError("More than one unmarked ranking comment was found")
    return legacy[0] if legacy else None


def publish_ranking_comment(markdown: str, issue_number: int,
                            token: str,
                            request=github_api_request) -> str:
    """Create or replace the single marked ranking comment on an issue."""
    body = f"{RANKING_COMMENT_MARKER}\n\n{markdown}"
    existing = find_ranking_comment(
        fetch_issue_comments(issue_number, token, request=request)
    )
    if existing:
        result = request(
            "PATCH", f"/issues/comments/{existing['id']}", token, {"body": body}
        )
    else:
        result = request(
            "POST", f"/issues/{issue_number}/comments", token, {"body": body}
        )
    return result["html_url"]


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


def issue_count_text(count: int) -> str:
    return f"{count} issue" if count == 1 else f"{count} issues"


def md_escape(text: str) -> str:
    """Escape the characters in an issue title that break the generated report.

    Both of these are structural, not cosmetic:

    * ``$`` opens a Pandoc inline-math span. Titles such as
      ``doaggregate()$results_bybg_people`` and ``... vs input$ ?`` left an
      unclosed span that swallowed every following table row into one cell --
      three issues disappeared from each of two tables in the rendered HTML.
    * ``*`` and ``_`` would trigger Markdown emphasis and corrupt the title.
    * ``|`` would end a table cell early and shift the rest of the row.

    Applied only where a title is written into Markdown.
    """
    return (
        text.replace("*", r"\*")
        .replace("_", r"\_")
        .replace("$", r"\$")
        .replace("|", r"\|")
    )


def _write_quad(lines: list[str], letter: str, heading: str, desc: str,
                issues: list[dict]) -> None:
    lines.append(f"## Quadrant {letter} — {heading}")
    lines.append(f"*{desc}*")
    lines.append("")
    lines.append(f"**{len(issues)} issues**")
    lines.append("")
    for r in issues:
        lines.append(
            f"- [#{r['num']}]({URL_BASE}{r['num']}) — {md_escape(r['title'])}"
        )
    lines.append("")
    lines.append(
        "| # | Issue | Cost | Benefit | Milestone | Priority | Proposed rank | Current GitHub labels (key) |"
    )
    lines.append(
        "|---|-------|------|---------|-----------|----------|---------------|-----------------------------|"
    )
    for r in issues:
        plbl     = get_priority_label(r["labels"])
        key_labs = [
            l for l in r["labels"]
            if l not in ("enhancement", "retain-0325", "from archive")
            and "PRIORITY" not in l
        ]
        ## Show the score separately from the live metadata. A rank label can be
        ## stale until a later, explicit GitHub-label update task applies it.
        rank_lbl = RANK_LABELS.get(r["quad"])
        current_rank_labs = [l for l in key_labs if l.startswith("rank:")]
        key_labs = current_rank_labs + [l for l in key_labs if l not in current_rank_labs]
        lab_str  = ", ".join(key_labs[:4])
        ## truncate first, then escape - escaping first would let backslashes
        ## count toward the limit and could cut a "\$" in half
        short    = md_escape(r["title"][:70] + ("…" if len(r["title"]) > 70 else ""))
        lines.append(
            f"| [{r['num']}]({URL_BASE}{r['num']}) | {short} | "
            f"{r['cost']} ({cost_tier(r['cost'])}) | "
            f"{r['benefit']} ({benefit_tier(r['benefit'])}) | "
            f"{r['milestone']} | {plbl} | `{rank_lbl}` | {lab_str} |"
        )
    lines.append("")
    lines.append("---")
    lines.append("")


def generate_markdown(scored_issues: list[dict],
                      cost_med: int, benefit_med: int,
                      generated_date: str = "2026-05-30") -> str:
    """
    Build and return the full Markdown text for the issue-ranking comment.

    Parameters
    ----------
    scored_issues  : list of dicts with keys num, title, labels, cost, benefit, quad
    cost_med       : median cost score (split threshold)
    benefit_med    : median benefit score (split threshold)
    generated_date : date string for the header
    """
    n = len(scored_issues)
    quads: dict[str, list[dict]] = {"A": [], "B": [], "C": [], "D": []}
    for r in scored_issues:
        quads[r["quad"]].append(r)

    quads["A"].sort(key=lambda x: (-x["benefit"], x["cost"]))
    quads["B"].sort(key=lambda x: (-x["benefit"], x["cost"]))
    quads["C"].sort(key=lambda x: (-x["benefit"], x["cost"]))
    quads["D"].sort(key=lambda x: (x["cost"], -x["benefit"]))

    lines: list[str] = []
    lines.append(RANKING_REPORT_HEADING)
    lines.append("")
    lines.append(
        f"**Total open issues:** {n}  |  **Generated:** {generated_date}  |  "
        f"**Source:** {REPORT_SOURCE}"
    )
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Overview")
    lines.append("")
    costs    = sorted(r["cost"]    for r in scored_issues)
    benefits = sorted(r["benefit"] for r in scored_issues)
    lines.append("## 2×2 Priority Matrix")
    lines.append("")
    lines.append(
        "| Cost / Benefit | **LOW Benefit**<br>value < median | "
        "**HIGH Benefit**<br>value ≥ median |"
    )
    lines.append("|---|---|---|")
    lines.append(
        "| **LOW Cost**<br>cost < median | "
        f"**C — Other Low-Cost Work**<br>{issue_count_text(len(quads['C']))} | "
        f"**A — Focus Shortlist (max {MAX_QUADRANT_A_ISSUES})**<br>"
        f"{issue_count_text(len(quads['A']))} |"
    )
    lines.append(
        "| **HIGH Cost**<br>cost ≥ median | "
        f"**D — WORST CANDIDATES**<br>{issue_count_text(len(quads['D']))} | "
        f"**B — OK Candidates**<br>{issue_count_text(len(quads['B']))} |"
    )
    lines.append("")
    lines.append("---")
    lines.append("")

    _write_quad(lines, "A",
                "FOCUS SHORTLIST — Low Cost, High Benefit",
                f"The top {MAX_QUADRANT_A_ISSUES} low-cost, high-benefit candidates at most, "
                "ordered by benefit then cost. Prioritize these above all others.",
                quads["A"])
    _write_quad(lines, "B",
                "OK Candidates — High Cost, High Benefit",
                "Worth doing but require more effort or expertise. Plan carefully before starting.",
                quads["B"])
    _write_quad(lines, "C",
                "OTHER LOW-COST WORK",
                "Cheap to do but not in the current focus shortlist. Pick these up when bandwidth allows "
                "or combine them with nearby work.",
                quads["C"])
    _write_quad(lines, "D",
                "WORST CANDIDATES — High Cost, Low Benefit",
                "Expensive to fix, limited payoff. Defer or deprioritize unless circumstances change.",
                quads["D"])

    lines.append(f"## Full Table — All {n} Issues")
    lines.append("")
    lines.append("Sorted: A first (best), then B, C, D; within each group by benefit DESC.")
    lines.append("")
    lines.append("| Quad | Issue # | Cost | Benefit | Milestone | Priority | Title |")
    lines.append("|------|---------|------|---------|-----------|----------|-------|")
    for letter in ("A", "B", "C", "D"):
        for r in quads[letter]:
            plbl  = get_priority_label(r["labels"])
            short = md_escape(r["title"][:72] + ("…" if len(r["title"]) > 72 else ""))
            lines.append(
                f"| {letter} | [{r['num']}]({URL_BASE}{r['num']}) | "
                f"{r['cost']} | {r['benefit']} | {r['milestone']} | "
                f"{plbl} | {short} |"
            )

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Issues by Milestone")
    lines.append("")
    lines.append("| Milestone | Issue count |")
    lines.append("|-----------|------------:|")
    milestone_counts = Counter(r["milestone"] for r in scored_issues)
    for milestone in sorted(
        milestone_counts,
        key=lambda value: (value == "NA", value.casefold()),
    ):
        lines.append(f"| {milestone} | {milestone_counts[milestone]} |")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## How Ranking was Done")
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
    lines.append("### Focus shortlist rule")
    lines.append("")
    lines.append(
        f"Quadrant A is capped at **{MAX_QUADRANT_A_ISSUES} issues**. After the median split, "
        "eligible low-cost, high-benefit issues are ordered by benefit descending, cost ascending, "
        "then issue number. Any remaining eligible issues are placed in C as other low-cost work."
    )
    lines.append("")
    lines.append("### GitHub rank labels for a later update task")
    lines.append("")
    lines.append(
        "The report proposes the labels below, but the scoring script does not "
        "apply them to GitHub."
    )
    lines.append("")
    lines.append("| Quadrant | Label |")
    lines.append("|----------|-------|")
    for quad in ("A", "B", "C", "D"):
        lines.append(f"| {quad} | `{RANK_LABELS[quad]}` |")
    lines.append("")
    lines.append("### Scoring Factors")
    lines.append("")
    lines.append("#### Cost factors (higher = harder/riskier)")
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
    lines.append("#### Benefit factors (higher = more valuable/urgent)")
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
        num, title, labels, milestone, cost, benefit, quad
    """
    scored = []
    for issue in issues:
        labels = get_labels(issue)
        body   = issue.get("body") or ""
        title  = issue.get("title", "").strip()
        c = cost_score(title, labels, body)
        b = benefit_score(title, labels, body)
        scored.append({
            "num":     issue["number"],
            "title":   title,
            "labels":  labels,
            "milestone": get_milestone(issue),
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
    cap_quadrant_a(scored)

    return scored, cost_med, benefit_med


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Re-score EJAM issues and publish the Markdown ranking."
    )
    parser.add_argument(
        "--token", default=None,
        help="GitHub token (defaults to GH_TOKEN, GITHUB_TOKEN, or gh auth)"
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Optional path for a local Markdown copy"
    )
    parser.add_argument(
        "--publish", action="store_true",
        help="Create or replace the ranking comment on GitHub"
    )
    parser.add_argument(
        "--issue-number", type=int, default=DEFAULT_ISSUE_NUMBER,
        help=f"Issue that owns the ranking comment (default: {DEFAULT_ISSUE_NUMBER})"
    )
    parser.add_argument(
        "--date", default=date.today().isoformat(),
        help="Generated-date string to embed in the header"
    )
    args = parser.parse_args()
    if not args.publish and not args.output:
        parser.error("specify --publish and/or --output")

    token = resolve_github_token(args.token) if args.publish else args.token
    if args.publish and not token:
        parser.error(
            "--publish requires --token, GH_TOKEN, GITHUB_TOKEN, or gh auth login"
        )

    print("Fetching open issues from GitHub …")
    issues = fetch_all_open_issues(
        token=token, exclude_issue_number=args.issue_number
    )
    print(
        f"  {len(issues)} open issues fetched and ranked "
        f"(excluding report issue #{args.issue_number})."
    )

    scored, cost_med, benefit_med = score_issues(issues)
    print(
        f"  Cost range  {min(r['cost']    for r in scored)}–"
        f"{max(r['cost']    for r in scored)}, median={cost_med}"
    )
    print(
        f"  Benefit range {min(r['benefit'] for r in scored)}–"
        f"{max(r['benefit'] for r in scored)}, median={benefit_med}"
    )

    md = generate_markdown(
        scored, cost_med, benefit_med,
        generated_date=args.date,
    )

    if args.output:
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        with open(args.output, "w", encoding="utf-8") as fh:
            fh.write(md)
        print(f"Written: {args.output}  ({len(md):,} bytes)")

    if args.publish:
        comment_url = publish_ranking_comment(
            md, issue_number=args.issue_number, token=token
        )
        print(f"Published: {comment_url}")


if __name__ == "__main__":
    main()
