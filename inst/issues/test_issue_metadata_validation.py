import unittest
from unittest.mock import patch
from types import SimpleNamespace
import json

from issue_metadata_validation import audit_issues, validate_issue


class MetadataTests(unittest.TestCase):
    def issue(self):
        return {'number': 776, 'state': 'open', 'labels': ['PRIORITY MEDIUM', 'enhancement',
                'Affects Web App'], 'type': {'name': 'Feature'}}

    def test_native_priority_not_projects(self):
        issue = self.issue()
        issue['issue_field_values'] = [{'issue_field_name': 'Priority',
            'single_select_option': {'name': 'Medium'}}]
        response = SimpleNamespace(returncode=0, stdout=json.dumps(issue))
        with patch('issue_metadata_validation.subprocess.run', return_value=response) as run:
            self.assertEqual(audit_issues([issue]), 0)
        self.assertEqual(run.call_args.args[0], ['gh', 'api',
            'repos/Public-Environmental-Data-Partners/EJAM/issues/776'])

    def test_high_bug_requires_urgent(self):
        issue = self.issue()
        issue.update(labels=['PRIORITY HIGH', 'BUG', 'Affects Web App'],
                     type={'name': 'Bug'})
        self.assertTrue(validate_issue(issue, ['High']))
        self.assertEqual(validate_issue(issue, ['Urgent']), [])

    def test_missing_and_duplicate_values(self):
        self.assertTrue(validate_issue(self.issue(), []))
        self.assertTrue(validate_issue(self.issue(), ['Medium', 'Medium']))

    def test_closed_issue_is_not_fetched_or_reported(self):
        issue = self.issue()
        issue['state'] = 'closed'
        with patch('issue_metadata_validation.subprocess.run') as run, patch('builtins.print') as output:
            self.assertEqual(audit_issues([issue]), 0)
        run.assert_not_called()
        output.assert_called_once_with('Metadata audit: 0 open issues checked; 0 with discrepancies or unavailable metadata.')

    def test_issue_closed_after_initial_fetch_is_not_reported(self):
        closed = dict(self.issue(), state='closed')
        response = SimpleNamespace(returncode=0, stdout=json.dumps(closed))
        with patch('issue_metadata_validation.subprocess.run', return_value=response), patch('builtins.print') as output:
            self.assertEqual(audit_issues([self.issue()]), 0)
        output.assert_called_once_with('Metadata audit: 0 open issues checked; 0 with discrepancies or unavailable metadata.')


if __name__ == '__main__':
    unittest.main()
