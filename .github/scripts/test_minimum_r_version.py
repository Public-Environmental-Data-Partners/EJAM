"""Regression checks for resolving the declared minimum without installing R."""

from pathlib import Path
from runpy import run_path
import subprocess
import sys
import tempfile
import unittest

HELPER = Path(__file__).with_name("minimum-r-version.py")
minimum_r_version = run_path(str(HELPER))["minimum_r_version"]


class MinimumRVersionTests(unittest.TestCase):
    def test_continued_depends_field(self):
        self.assertEqual(minimum_r_version(
            "Package: example\nDepends:\n    methods,\n    R (>= 4.2.1),\n    stats\nImports: foo\n"), "4.2.1")

    def test_inline_depends_field(self):
        self.assertEqual(minimum_r_version("Depends: R (>= 4.2.1)\n"), "4.2.1")

    def test_changed_minimum_requires_no_workflow_edit(self):
        description = "Depends: R (>= 4.2.1)\n"
        self.assertEqual(minimum_r_version(description.replace("4.2.1", "4.8.2")), "4.8.2")

    def test_two_component_minimum_is_first_patch(self):
        self.assertEqual(minimum_r_version("Depends: R (>= 4.8)\n"), "4.8.0")

    def test_other_fields_cannot_supply_the_minimum(self):
        with self.assertRaises(ValueError):
            minimum_r_version("Depends: methods\nSuggests: R (>= 4.2.1)\n")

    def test_invalid_or_ambiguous_requirements_fail(self):
        for depends in ["", "R", "R (> 4.2.1)", "R (>= invalid)", "R (>= 4.2.1), R (>= 4.8.2)"]:
            with self.subTest(depends=depends), self.assertRaises(ValueError):
                minimum_r_version("Depends: " + depends + "\n")

    def test_cli_reads_description_in_working_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            Path(directory, "DESCRIPTION").write_text("Depends: R (>= 4.8.2)\n")
            result = subprocess.run([sys.executable, str(HELPER)], cwd=directory,
                                    check=True, capture_output=True, text=True)
            self.assertEqual(result.stdout, "version=4.8.2\n")


if __name__ == "__main__":
    unittest.main()
