#!/usr/bin/env bash
# Install EJAM and its data inside a dev container (for example a GitHub Codespace).
# devcontainer.json runs this when the container is created and again when the
# checked-out branch changes. See .devcontainer/README.md.
set -euo pipefail

# Run from the repository root, wherever this script was called from.
cd "$(dirname "$0")/.."

# pak and piggyback read GITHUB_PAT. A Codespace provides GITHUB_TOKEN, which
# avoids the low rate limit GitHub applies to requests made without a token.
if [ -z "${GITHUB_PAT:-}" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  export GITHUB_PAT="${GITHUB_TOKEN}"
fi

echo "==> Installing EJAM from this checkout, with the packages it needs"
Rscript -e '
  options(timeout = 600)
  if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
  # Same call as the "Installing the EJAM R package" article: required packages
  # only, and no upgrades of packages the image already has.
  pak::pkg_install("local::.", dependencies = NA, upgrade = FALSE)
'

echo "==> Downloading the large EJAM datasets (block and facility tables)"
# Attaching EJAM downloads the block tables it always needs. The second call
# fetches the rest now, so that the first analysis does not have to wait for them.
Rscript -e '
  options(timeout = 1800)
  suppressPackageStartupMessages(library(EJAM))
  EJAM::download_latest_arrow_data(varnames = "all")
  cat("EJAM", as.character(utils::packageVersion("EJAM")), "is ready.\n")
'

echo "==> Removing downloaded package files that are no longer needed"
# The copies pak keeps of what it downloaded take over 1 GB of a small disk.
Rscript -e '
  try(pak::cache_clean(), silent = TRUE)
  try(pak::meta_clean(force = TRUE), silent = TRUE)
' || true
