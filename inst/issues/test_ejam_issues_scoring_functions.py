import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parent))

import ejam_issues_scoring_functions as scoring


class IssueRankingTest(unittest.TestCase):

    def test_markdown_escapes_dollar_signs_that_would_start_pandoc_math(self):
        """A "$" in a title opened an inline-math span that ate later rows.

        Titles like doaggregate()$results_bybg_people and "vs input$ ?" left an
        unclosed <span class="math inline">, swallowing three following table
        rows into one cell -- so those issues vanished from the rendered HTML.
        """
        scored = [
            {
                "num": 31,
                "title": "fix distance_avg in doaggregate()$results_bybg_people",
                "labels": ["BUG"],
                "milestone": "NA",
                "cost": 4,
                "benefit": 9,
                "quad": "B",
            },
            {
                "num": 32,
                "title": "a title with a | pipe that would end a table cell",
                "labels": ["BUG"],
                "milestone": "NA",
                "cost": 4,
                "benefit": 9,
                "quad": "B",
            },
        ]

        markdown = scoring.generate_markdown(
            scored, cost_med=4, benefit_med=6, generated_date="2026-06-20"
        )

        # no bare "$" or in-title "|" survives into the Markdown
        self.assertNotIn("doaggregate()$results", markdown)
        self.assertIn(r"doaggregate()\$results\_bybg\_people", markdown)
        self.assertIn(r"a title with a \| pipe", markdown)

        # and the escaping is applied everywhere a title is written:
        # the bullet list, the quadrant table, and the full table
        self.assertEqual(markdown.count(r"doaggregate()\$results\_bybg\_people"), 3)

    def test_md_escape_leaves_ordinary_titles_untouched(self):
        plain = "check/ fix Distance and Site Count summary stats"
        self.assertEqual(scoring.md_escape(plain), plain)

    def test_generate_markdown_keeps_rank_labels_visible_when_list_is_truncated(self):
        scored = [
            {
                "num": 595,
                "title": "Improve API documentation vignette",
                "labels": [
                    "Affects R users only - NOT web app users",
                    "documentation",
                    "Affects API",
                    "something else",
                    "another label",
                    "yet another label",
                    "rank:C-low-value-low-cost",
                ],
                "milestone": "NA",
                "cost": 0,
                "benefit": 7,
                "quad": "A",
            }
        ]

        markdown = scoring.generate_markdown(
            scored,
            cost_med=4,
            benefit_med=6,
            generated_date="2026-06-20",
        )

        self.assertIn("rank:C-low-value-low-cost", markdown)
        self.assertIn(
            "| [595](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/595) | "
            "Improve API documentation vignette | 0 (🟢 Very Low) | 7 (🟦 Medium) | "
            "NA | — | `rank:A-high-value-low-cost` | "
            "rank:C-low-value-low-cost, Affects R users only - NOT web app users, "
            "documentation, Affects API |",
            markdown,
        )
        self.assertNotIn("another label", markdown)

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

        matrix_idx = markdown.index("## 2×2 Priority Matrix")
        full_table_idx = markdown.index("## Full Table")
        milestones_idx = markdown.index("## Issues by Milestone")
        how_ranking_idx = markdown.index("## How Ranking was Done")
        dimensions_idx = markdown.index(
            "Each issue is scored independently on two dimensions:"
        )
        score_ranges_idx = markdown.index("### Score ranges")
        focus_rule_idx = markdown.index("### Focus shortlist rule")
        rank_labels_idx = markdown.index(
            "### GitHub rank labels for a later update task"
        )
        scoring_factors_idx = markdown.index("### Scoring Factors")

        self.assertLess(matrix_idx, full_table_idx)
        self.assertLess(full_table_idx, milestones_idx)
        self.assertLess(milestones_idx, how_ranking_idx)
        self.assertLess(how_ranking_idx, dimensions_idx)
        self.assertLess(dimensions_idx, score_ranges_idx)
        self.assertLess(score_ranges_idx, focus_rule_idx)
        self.assertLess(focus_rule_idx, rank_labels_idx)
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
            "**C — Other Low-Cost Work**<br>0 issues | "
            "**A — Focus Shortlist (max 20)**<br>1 issue |",
            markdown,
        )
        self.assertIn("| v3.2022.2 | 1 |", markdown)
        self.assertIn("| NA | 1 |", markdown)
        self.assertIn(
            "| # | Issue | Cost | Benefit | Milestone | Priority | Proposed rank | "
            "Current GitHub labels (key) |",
            markdown,
        )
        self.assertNotIn("Previous-run comparison", markdown)
        self.assertNotIn("Score payload", markdown)
        self.assertNotIn("JSON payload", markdown)

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

    def test_cap_quadrant_a_keeps_only_the_top_twenty_candidates(self):
        scored = [
            {
                "num": number,
                "cost": number % 3,
                "benefit": 30 - number,
                "quad": "A",
            }
            for number in range(1, 23)
        ]

        scoring.cap_quadrant_a(scored)

        self.assertEqual([issue["num"] for issue in scored if issue["quad"] == "A"], list(range(1, 21)))
        self.assertEqual([issue["num"] for issue in scored if issue["quad"] == "C"], [21, 22])

    def test_publish_ranking_comment_adopts_and_updates_legacy_comment(self):
        calls = []

        def request(method, path, token, payload=None):
            calls.append((method, path, token, payload))
            if method == "GET":
                return [{
                    "id": 6750491750,
                    "body": f"{scoring.RANKING_REPORT_HEADING}\n\nOld report",
                }]
            return {"html_url": "https://github.com/example/issues/715#comment"}

        url = scoring.publish_ranking_comment(
            "# New report", issue_number=715, token="test-token", request=request
        )

        self.assertEqual(url, "https://github.com/example/issues/715#comment")
        self.assertEqual(calls[1][0], "PATCH")
        self.assertEqual(calls[1][1], "/issues/comments/6750491750")
        self.assertTrue(calls[1][3]["body"].startswith(
            f"{scoring.RANKING_COMMENT_MARKER}\n\n# New report"
        ))

    def test_publish_ranking_comment_creates_comment_when_missing(self):
        calls = []

        def request(method, path, token, payload=None):
            calls.append((method, path, token, payload))
            if method == "GET":
                return []
            return {"html_url": "https://github.com/example/issues/715#new"}

        scoring.publish_ranking_comment(
            "# New report", issue_number=715, token="test-token", request=request
        )

        self.assertEqual(calls[1][0], "POST")
        self.assertEqual(calls[1][1], "/issues/715/comments")

    def test_find_ranking_comment_rejects_duplicate_markers(self):
        comments = [
            {"id": 1, "body": scoring.RANKING_COMMENT_MARKER},
            {"id": 2, "body": scoring.RANKING_COMMENT_MARKER},
        ]

        with self.assertRaisesRegex(RuntimeError, "More than one ranking comment"):
            scoring.find_ranking_comment(comments)

    def test_publish_ranking_comment_ignores_quoted_marker_and_updates_report(self):
        calls = []
        instructions = (
            "To find the report, look for this line:\n\n"
            f"```\n{scoring.RANKING_COMMENT_MARKER}\n```"
        )

        def request(method, path, token, payload=None):
            calls.append((method, path, token, payload))
            if method == "GET":
                return [
                    {"id": 111, "body": instructions},
                    {
                        "id": 222,
                        "body": f"{scoring.RANKING_COMMENT_MARKER}\n\nOld report",
                    },
                ]
            return {"html_url": "https://github.com/example/issues/715#report"}

        scoring.publish_ranking_comment(
            "# New report", issue_number=715, token="test-token", request=request
        )

        self.assertEqual(len(calls), 2)
        self.assertEqual(calls[1][0], "PATCH")
        self.assertEqual(calls[1][1], "/issues/comments/222")

    def test_publish_ranking_comment_creates_report_when_only_quoted_marker_exists(self):
        calls = []

        def request(method, path, token, payload=None):
            calls.append((method, path, token, payload))
            if method == "GET":
                return [{
                    "id": 111,
                    "body": f"The report starts with {scoring.RANKING_COMMENT_MARKER}",
                }]
            return {"html_url": "https://github.com/example/issues/715#new"}

        scoring.publish_ranking_comment(
            "# New report", issue_number=715, token="test-token", request=request
        )

        self.assertEqual(len(calls), 2)
        self.assertEqual(calls[1][0], "POST")
        self.assertEqual(calls[1][1], "/issues/715/comments")

    def test_default_issue_number_is_715(self):
        self.assertEqual(scoring.DEFAULT_ISSUE_NUMBER, 715)


if __name__ == "__main__":
    unittest.main()
