"""Read the minimum R version from the package being tested, before R is installed."""

from pathlib import Path
import re
import sys


def minimum_r_version(description):
    depends = []
    reading_depends = False
    for line in description.splitlines():
        if line.startswith("Depends:"):
            reading_depends = True
            depends.append(line.split(":", 1)[1])
        elif reading_depends:
            if line[:1].isspace():
                depends.append(line.strip())
            else:
                break

    requirements = [
        match.group(1)
        for entry in " ".join(depends).split(",")
        if (match := re.fullmatch(r"\s*R\s*\(\s*>=\s*(\d+\.\d+(?:\.\d+)?)\s*\)\s*", entry))
    ]
    if len(requirements) != 1:
        raise ValueError("DESCRIPTION Depends must declare one R (>= x.y[.z]) requirement")
    version = requirements[0]
    # setup-r interprets x.y as the latest patch; the declared minimum is x.y.0.
    return version if version.count(".") == 2 else version + ".0"


if __name__ == "__main__":
    description = Path(sys.argv[1] if len(sys.argv) > 1 else "DESCRIPTION")
    try:
        version = minimum_r_version(description.read_text())
    except ValueError as error:
        sys.exit(str(error))
    print(f"version={version}")
