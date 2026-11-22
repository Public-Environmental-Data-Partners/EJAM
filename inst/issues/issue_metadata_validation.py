"""Read-only consistency checks; labels are authoritative, never inferred."""

import json
import subprocess

PRIORITIES = {
    "PRIORITY LOW": {"Low"},
    "PRIORITY MEDIUM": {"Medium"},
    "PRIORITY HIGH-ish but not a bug": {"High"},
    "PRIORITY HIGH": {"High", "Urgent"},
}


def validate_issue(issue, priority_values=None, metadata_error=None):
    """Return actionable discrepancies, including unavailable metadata."""
    labels = [x if isinstance(x, str) else x['name']
              for x in issue.get('labels', [])]
    problems = []
    priorities = [x for x in labels if x.startswith('PRIORITY')]
    if len(priorities) != 1 or priorities[0] not in PRIORITIES:
        problems.append(f'expected exactly one recognized PRIORITY label; found {priorities}')
    kinds = [x for x in labels if x in ('BUG', 'enhancement')]
    if len(kinds) != 1:
        problems.append(f'expected exactly one BUG/enhancement label; found {kinds}')
    issue_type = issue.get('type') or {}
    name = issue_type.get('name') if isinstance(issue_type, dict) else issue_type
    if name not in ('Bug', 'Feature', 'Task'):
        problems.append(f'expected Type Bug, Feature, or Task; found {name!r}')
    elif kinds == ['BUG'] and name != 'Bug':
        problems.append(f'BUG label requires Type Bug, not {name}')
    elif kinds == ['enhancement'] and name not in ('Feature', 'Task'):
        problems.append(f'enhancement label requires Type Feature or Task, not {name}')
    affects = [x for x in labels if x == 'Affects Web App' or x.startswith('Affects R users')]
    if len(affects) != 1:
        problems.append(f'expected exactly one Web App/R users impact label; found {affects}')
    if metadata_error:
        problems.append(f'Priority field could not be verified: {metadata_error}')
    elif priority_values is None or len(priority_values) != 1 or priority_values[0] not in ('Low', 'Medium', 'High', 'Urgent'):
        problems.append(f'expected exactly one Priority field value; found {priority_values}')
    elif len(priorities) == 1 and priorities[0] in PRIORITIES:
        expected = PRIORITIES[priorities[0]]
        if priorities[0] == 'PRIORITY HIGH' and 'BUG' in labels:
            expected = {'Urgent'}
        if priority_values[0] not in expected:
            problems.append(f'Priority {priority_values[0]!r} disagrees with labels; expected {sorted(expected)}')
    return problems


def audit_issues(issues):
    """Read native issue fields, not similarly named Projects fields."""
    failures = 0
    checked = 0
    for issue in issues:
        if issue.get('state') != 'open' or 'pull_request' in issue:
            continue
        endpoint = f"repos/Public-Environmental-Data-Partners/EJAM/issues/{issue['number']}"
        result = subprocess.run(['gh', 'api', endpoint],
                                capture_output=True, text=True)
        values, error = [], None
        if result.returncode:
            error = 'GitHub issue metadata request failed'
        else:
            payload = json.loads(result.stdout)
            issue = payload
            # An issue may have been closed since the initial open-issue fetch.
            if issue.get('state') != 'open' or 'pull_request' in issue:
                continue
            if 'issue_field_values' not in payload:
                error = 'GitHub response omitted issue_field_values'
            else:
                values = [field.get('single_select_option', {}).get('name')
                          for field in (payload['issue_field_values'] or [])
                          if field.get('issue_field_name') == 'Priority']
        checked += 1
        problems = validate_issue(issue, values, error)
        if problems:
            failures += 1
            print(f"Issue #{issue['number']}: " + '; '.join(problems))
    print(f'Metadata audit: {checked} open issues checked; {failures} with discrepancies or unavailable metadata.')
    return failures
