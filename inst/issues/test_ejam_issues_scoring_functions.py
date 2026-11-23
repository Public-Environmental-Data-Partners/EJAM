import sys
import unittest
from unittest.mock import patch
from io import BytesIO
from types import SimpleNamespace
import json
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parent))

import ejam_issues_scoring_functions as scoring


class IssueRankingTest(unittest.TestCase):

    def test_cross_repo_prs_require_explicit_ejam_target(self):
        self.assertEqual(scoring.open_pr_issue_references({'body': 'Fixes #791'}, 'EJAM-API'), set())
        for repo in ('EJAM-API', 'EJScreen'):
            self.assertEqual(scoring.open_pr_issue_references(
                {'body': 'Closes Public-Environmental-Data-Partners/EJAM#791'}, repo), {791})
            self.assertEqual(scoring.open_pr_issue_references(
                {'body': 'Fixes https://github.com/Public-Environmental-Data-Partners/EJAM/issues/791'}, repo), {791})
            self.assertEqual(scoring.pr_link(repo + '#12'),
                f'[{repo}#12](https://github.com/Public-Environmental-Data-Partners/{repo}/pull/12)')

    def test_collects_and_distinguishes_pr_numbers_across_repos(self):
        with patch.object(scoring, '_fetch_repository_pr_links',
                          side_effect=[{791: [12]}, {791: [12]}, {791: [12]}]):
            self.assertEqual(scoring.fetch_pr_links('token'),
                             {791: [12, 'EJAM-API#12', 'EJScreen#12']})

    def test_pr_links_exclude_unmerged_closed_prs(self):
        batch = [dict(number=792, state='closed', merged_at='2026-11-21', body='Closes #791'),
                 dict(number=9, state='open', body='Fixes #791'),
                 dict(number=10, state='closed', merged_at=None, body='Closes #791')]
        closing = {'pageInfo': {'hasNextPage': False}, 'nodes': []}
        response = SimpleNamespace(stdout=json.dumps({'data': {'repository': {
            'p792': {'closingIssuesReferences': closing},
            'p9': {'closingIssuesReferences': closing}}}}))
        with patch('urllib.request.urlopen', return_value=BytesIO(json.dumps(batch).encode())), \
             patch.object(scoring.subprocess, 'run', return_value=response) as run:
            self.assertEqual(scoring._fetch_repository_pr_links('EJAM', 'token'), {791: [9, 792]})
        self.assertNotIn('p10:', run.call_args.args[0][-1])

    def test_merged_pr_closure_reference(self):
        pr = {'number': 792, 'state': 'closed', 'merged_at': '2026-11-21',
              'body': 'Closes #791'}
        self.assertEqual(scoring.open_pr_issue_references(pr), {791})

    def test_github_linked_closures_include_merged_pr_targets(self):
        pr = {'closingIssuesReferences': {'nodes': [
            {'number': 791, 'repository': {'nameWithOwner': 'Public-Environmental-Data-Partners/EJAM'}},
            {'number': 22, 'repository': {'nameWithOwner': 'another/repo'}}]}}
        self.assertEqual(scoring.open_pr_issue_references(pr), {791})

    def test_all_quadrants_share_one_unbroken_table(self):
        rows = [dict(num=i, title='Example', milestone='NA', cost=2,
                     benefit=8, quad=q, labels=[]) for i, q in enumerate('ABCD', 1)]
        md = scoring.generate_markdown(rows, 3, 6)
        table = md.split(scoring.ISSUE_TABLE_HEADER, 1)[1].split('\n\n', 1)[0]
        self.assertEqual(md.count(scoring.ISSUE_TABLE_HEADER), 1)
        self.assertTrue(all(line.startswith('|') for line in table.splitlines() if line))
        for q in 'ABCD':
            self.assertIn('| **' + q + '** |', table)
        for row in rows:
            self.assertEqual(md.count(scoring.issue_table_row(row)), 1)

    def test_increased_exact_bug_and_app_weights(self):
        self.assertEqual(scoring.benefit_score('', ['BUG'], ''), 7)
        self.assertEqual(scoring.benefit_score('', ['Affects Web App'], ''), 4)
        self.assertEqual(scoring.benefit_score('', ['Affects R users only - NOT web app users'], ''), 0)
        self.assertEqual(scoring.benefit_score('', ['PRIORITY HIGH-ish but not a bug'], ''), 6)

    def test_open_pr_explicit_references_only(self):
        pr = {'number': 9, 'body': 'Closes #11. Related #12.\nPart of Public-Environmental-Data-Partners/EJAM#13'}
        self.assertEqual(scoring.open_pr_issue_references(pr), {11, 13})
        row = {'num': 11, 'title': 'Example', 'labels': [], 'milestone': 'NA',
               'cost': 1, 'benefit': 1, 'quad': 'C', 'prs': [9, 10]}
        self.assertIn('[#9](https://github.com/Public-Environmental-Data-Partners/EJAM/pull/9)', scoring.issue_table_row(row))

    def test_key_labels_filter_and_twelve_character_lines(self):
        rendered = scoring.table_key_labels(['documentation', 'speed / performance',
                                            'custom indicators', 'Affects API'])
        lines = rendered.replace('&nbsp;', ' ').split('<br>')
        self.assertEqual(lines[0].strip(), 'speed...')
        self.assertTrue(all(len(line) == 12 for line in lines))
        self.assertNotIn('documentation', rendered)
        self.assertIn('custom', rendered)
        self.assertIn('API', rendered)

    def test_score_symbol_above_text(self):
        self.assertEqual(scoring.table_score(9, scoring.benefit_tier(9)),
                         '🟩🟦<br>9&nbsp;H')

    def test_title_has_two_bounded_lines_and_ellipsis(self):
        title = scoring.table_title('create a way to share an interactive map ' * 5)
        lines = title.replace('&nbsp;', ' ').split('<br>')
        self.assertEqual(len(lines), 2)
        self.assertTrue(all(len(line) == scoring.TITLE_WIDTH for line in lines))
        self.assertTrue(lines[1].rstrip().endswith('...'))
        self.assertEqual(len(scoring.table_title('Short').split('<br>')), 2)

    def test_no_proposed_rank_or_old_headers(self):
        self.assertNotIn('Proposed rank', scoring.ISSUE_TABLE_HEADER)
        self.assertNotIn('Affects Web App', scoring.ISSUE_TABLE_HEADER)
        self.assertIn('| PR | Cost | Benefit | Priority | App |', scoring.ISSUE_TABLE_HEADER)
        self.assertNotIn('| Quad |', scoring.ISSUE_TABLE_HEADER)

    def test_compact_score_tiers_preserve_thresholds(self):
        self.assertEqual([scoring.cost_tier(n).split()[-1]
                          for n in [0, 1, 2, 3, 4, 6, 7, 10, 11]],
                         ['L-', 'L-', 'L', 'L', 'M', 'M', 'H', 'H', 'H+'])
        self.assertEqual([scoring.benefit_tier(n).split()[-1]
                          for n in [0, 1, 2, 4, 5, 8, 9, 12, 13]],
                         ['L-', 'L-', 'L', 'L', 'M', 'M', 'H', 'H', 'H+'])

    def test_compact_table_columns_and_label_filters(self):
        row = {'num': 1, 'title': 'Example', 'milestone': 'v4',
               'cost': 12, 'benefit': 15, 'quad': 'B',
               'labels': ['BUG', 'enhancement', 'Affects Web App',
                          'Affects R users only - NOT web app users',
                          'PRIORITY HIGH-ish but not a bug',
                          'rank:A-high-value-low-cost', 'rank:custom', 'API']}
        cells = scoring.issue_table_row(row).split(' | ')
        self.assertEqual(cells[2:9], ['v4', '', '⛔<br>12&nbsp;H+',
                         '🟩🟩<br>15&nbsp;H+', 'HIGH-ish', '✓', '✓'])
        self.assertEqual(cells[-1], scoring.table_key_labels(['API']) + ' |')
        self.assertNotIn('(', cells[4] + cells[5])
        markdown = scoring.generate_markdown([row], 4, 6)
        self.assertEqual(markdown.count(scoring.ISSUE_TABLE_HEADER), 1)
        self.assertEqual(markdown.count(scoring.issue_table_row(row)), 1)
        self.assertNotIn('## Full Table', markdown)

    def test_live_rank_labels_do_not_add_a_quad_column(self):
        row = {'num': 1, 'title': 'Example', 'milestone': 'NA',
               'cost': 1, 'benefit': 1, 'quad': 'A', 'labels': []}
        original = scoring.issue_table_row(row)
        row['labels'] = [scoring.RANK_LABELS['A'], scoring.RANK_LABELS['B']]
        self.assertEqual(scoring.issue_table_row(row), original)

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
        self.assertIn(r"a title with a \| pipe", markdown.replace('&nbsp;', ' '))

        # and the escaping is applied everywhere a title is written:
        # the bullet list, the quadrant table, and the full table
        self.assertEqual(markdown.count(scoring.table_title(scored[0]['title'])), 1)

    def test_md_escape_leaves_ordinary_titles_untouched(self):
        plain = "check/ fix Distance and Site Count summary stats"
        self.assertEqual(scoring.md_escape(plain), plain)

    def test_generate_markdown_separates_live_quad_from_proposed_rank(self):
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

        self.assertNotIn("rank:C-low-value-low-cost", scoring.issue_table_row(scored[0]))
        self.assertIn(
            "| [595](https://github.com/Public-Environmental-Data-Partners/EJAM/issues/595) | "
            + scoring.table_title(scored[0]['title']) + " | NA |  | 🟢<br>0&nbsp;L- | 🟦<br>7&nbsp;M | "
            "— |  |  | "
            + scoring.table_key_labels(['Affects API']) + ' |',
            markdown,
        )
        self.assertNotIn("yet another label", markdown)

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

        self.assertLess(matrix_idx, milestones_idx)
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
            [],
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
            scoring.ISSUE_TABLE_HEADER,
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
