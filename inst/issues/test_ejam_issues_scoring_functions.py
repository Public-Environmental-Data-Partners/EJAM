import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parent))

import ejam_issues_scoring_functions as scoring
import render_md_to_html as renderer


class IssueScorePayloadTest(unittest.TestCase):
    def test_build_score_payload_includes_rank_label_and_comment_payload(self):
        scored = [
            {
                "num": 101,
                "title": "Lat/lon uploads over the point cap need a clear error",
                "labels": ["PRIORITY HIGH", "bug"],
                "milestone": "v3.2022.2",
                "cost": 2,
                "benefit": 17,
                "quad": "A",
            }
        ]

        payload = scoring.build_score_payload(
            scored,
            cost_med=3,
            benefit_med=7,
            generated_date="2026-05-30",
            report_path="inst/issues/report.MD",
            run_changes={
                "previous_run": None,
                "opened_count": None,
                "closed_count": None,
                "quadrant_changed_count": None,
                "opened_issue_numbers": [],
                "closed_issue_numbers": [],
                "quadrant_changed_issue_numbers": [],
            },
        )

        self.assertEqual(
            payload["metadata"]["rank_labels"],
            {
                "A": "rank:A-high-value-low-cost",
                "B": "rank:B-high-value-high-cost",
                "C": "rank:C-low-value-low-cost",
                "D": "rank:D-defer",
            },
        )
        issue = payload["issues"][0]
        self.assertEqual(issue["rank_label"], "rank:A-high-value-low-cost")
        self.assertEqual(issue["milestone"], "v3.2022.2")
        self.assertEqual(
            issue["rank_comment"],
            "\n".join(
                [
                    "Last ranked: 2026-05-30",
                    "Cost score: 2",
                    "Benefit score: 17",
                    "Quadrant: A",
                    "Run report: inst/issues/report.MD",
                ]
            ),
        )
        self.assertNotIn("cost_label", issue)
        self.assertNotIn("benefit_label", issue)

    def test_summarize_run_changes_compares_against_previous_score_file(self):
        previous_payload = {
            "metadata": {"generated": "2026-05-29"},
            "issues": [
                {"number": 101, "quadrant": "B"},
                {"number": 999, "quadrant": "C"},
            ],
        }
        scored = [
            {
                "num": 101,
                "title": "Existing issue moved into A",
                "labels": [],
                "milestone": "v3.2022.2",
                "cost": 2,
                "benefit": 17,
                "quad": "A",
            },
            {
                "num": 102,
                "title": "New issue",
                "labels": [],
                "milestone": "NA",
                "cost": 1,
                "benefit": 9,
                "quad": "A",
            },
        ]

        changes = scoring.summarize_run_changes(scored, previous_payload)

        self.assertEqual(changes["previous_run"], "2026-05-29")
        self.assertEqual(changes["opened_count"], 1)
        self.assertEqual(changes["closed_count"], 1)
        self.assertEqual(changes["quadrant_changed_count"], 1)
        self.assertEqual(changes["opened_issue_numbers"], [102])
        self.assertEqual(changes["closed_issue_numbers"], [999])
        self.assertEqual(changes["quadrant_changed_issue_numbers"], [101])

    def test_generate_markdown_puts_methodology_at_end(self):
        scored = [
            {
                "num": 101,
                "title": "Low-cost high-benefit fix",
                "labels": ["PRIORITY HIGH", "BUG"],
                "milestone": "v3.2022.2",
                "cost": 1,
                "benefit": 10,
                "quad": "A",
            },
            {
                "num": 202,
                "title": "High-cost low-benefit refactor",
                "labels": ["refactor"],
                "milestone": "NA",
                "cost": 8,
                "benefit": 1,
                "quad": "D",
            },
        ]

        markdown = scoring.generate_markdown(
            scored,
            cost_med=4,
            benefit_med=6,
            generated_date="2026-06-20",
        )

        previous_run_idx = markdown.index("### Previous-run comparison")
        matrix_idx = markdown.index("## 2×2 Priority Matrix")
        full_table_idx = markdown.index("## Full Table")
        milestones_idx = markdown.index("## Issues by Milestone")
        how_ranking_idx = markdown.index("## How Ranking was Done")
        dimensions_idx = markdown.index(
            "Each issue is scored independently on two dimensions:"
        )
        score_ranges_idx = markdown.index("### Score ranges")
        rank_labels_idx = markdown.index(
            "### GitHub rank labels for a later update task"
        )
        scoring_factors_idx = markdown.index("### Scoring Factors")

        self.assertLess(previous_run_idx, matrix_idx)
        self.assertLess(matrix_idx, full_table_idx)
        self.assertLess(full_table_idx, milestones_idx)
        self.assertLess(milestones_idx, how_ranking_idx)
        self.assertLess(how_ranking_idx, dimensions_idx)
        self.assertLess(dimensions_idx, score_ranges_idx)
        self.assertLess(score_ranges_idx, rank_labels_idx)
        self.assertLess(rank_labels_idx, scoring_factors_idx)

        later_top_level = markdown.find("\n## ", how_ranking_idx + 1)
        self.assertEqual(later_top_level, -1)

        issue_bullets = [
            line for line in markdown.splitlines()
            if line.startswith("- [#")
        ]
        self.assertEqual(
            issue_bullets,
            [
                "- [#101](https://github.com/Public-Environmental-Data-Partners/"
                "EJAM/issues/101) — Low-cost high-benefit fix",
                "- [#202](https://github.com/Public-Environmental-Data-Partners/"
                "EJAM/issues/202) — High-cost low-benefit refactor",
            ],
        )
        self.assertTrue(all("Cost " not in line for line in issue_bullets))
        self.assertTrue(all("milestone" not in line for line in issue_bullets))
        self.assertTrue(all("PRIORITY" not in line for line in issue_bullets))
        self.assertNotIn("────────────────", markdown)
        self.assertIn(
            "| **LOW Cost**<br>cost < median | "
            "**C — Might As Well**<br>0 issues | "
            "**A — BEST CANDIDATES**<br>1 issue |",
            markdown,
        )
        self.assertIn("| v3.2022.2 | 1 |", markdown)
        self.assertIn("| NA | 1 |", markdown)

    def test_score_issues_extracts_milestone_title_and_na(self):
        issues = [
            {
                "number": 101,
                "title": "Milestoned issue",
                "labels": [],
                "body": "",
                "milestone": {"title": "v3.2022.2"},
            },
            {
                "number": 102,
                "title": "Unmilestoned issue",
                "labels": [],
                "body": "",
                "milestone": None,
            },
        ]

        scored, _, _ = scoring.score_issues(issues)

        self.assertEqual(scored[0]["milestone"], "v3.2022.2")
        self.assertEqual(scored[1]["milestone"], "NA")

    def test_renderer_applies_issue_table_column_layout(self):
        html = """<!doctype html>
<html><head></head><body>
<table>
<colgroup><col style="width: 50%" /><col style="width: 50%" /></colgroup>
<thead><tr><th>Metric</th><th>Value</th></tr></thead>
</table>
<table>
<colgroup><col style="width: 14%" /><col style="width: 14%" /></colgroup>
<thead><tr><th>#</th><th>Issue</th><th>Cost</th><th>Benefit</th>
<th>Milestone</th><th>Priority</th><th>Labels (key)</th></tr></thead>
</table>
</body></html>"""
        with tempfile.TemporaryDirectory() as tmp:
            html_path = Path(tmp) / "report.html"
            html_path.write_text(html, encoding="utf-8")

            renderer.style_issue_tables(html_path)

            styled = html_path.read_text(encoding="utf-8")

        self.assertEqual(styled.count('class="issue-details"'), 1)
        self.assertIn('<col style="width: 5%" />', styled)
        self.assertIn('<col style="width: 18%" />', styled)
        self.assertIn('<col style="width: 9%" />', styled)
        self.assertIn('<col style="width: 16%" />', styled)
        self.assertIn('<col style="width: 20%" />', styled)
        self.assertIn("min-width: 64em", styled)
        self.assertIn("td:first-child", styled)
        self.assertIn("white-space: nowrap", styled)
        self.assertIn("<th>Metric</th>", styled)


if __name__ == "__main__":
    unittest.main()
