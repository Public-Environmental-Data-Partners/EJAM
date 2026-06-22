import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parent))

import ejam_issues_scoring_functions as scoring


class IssueScorePayloadTest(unittest.TestCase):
    def test_build_score_payload_includes_rank_label_and_comment_payload(self):
        scored = [
            {
                "num": 101,
                "title": "Lat/lon uploads over the point cap need a clear error",
                "labels": ["PRIORITY HIGH", "bug"],
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
                "cost": 2,
                "benefit": 17,
                "quad": "A",
            },
            {
                "num": 102,
                "title": "New issue",
                "labels": [],
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

    def test_generate_markdown_puts_methodology_after_full_table(self):
        scored = [
            {
                "num": 101,
                "title": "Low-cost high-benefit fix",
                "labels": ["PRIORITY HIGH", "BUG"],
                "cost": 1,
                "benefit": 10,
                "quad": "A",
            },
            {
                "num": 202,
                "title": "High-cost low-benefit refactor",
                "labels": ["refactor"],
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

        full_table_idx = markdown.index("## Full Table")
        score_ranges_idx = markdown.index("### Score ranges")
        scoring_factors_idx = markdown.index("## Scoring Factors")

        self.assertLess(full_table_idx, score_ranges_idx)
        self.assertLess(score_ranges_idx, scoring_factors_idx)

        later_top_level = markdown.find("\n## ", scoring_factors_idx + 1)
        self.assertEqual(later_top_level, -1)


if __name__ == "__main__":
    unittest.main()
