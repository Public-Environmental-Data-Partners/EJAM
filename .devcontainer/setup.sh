#!/usr/bin/env bash
# Install EJAM and its data inside a dev container (for example a GitHub Codespace).
# devcontainer.json runs this when the container is created and again when the
# checked-out branch changes. See the article vignettes/dev-codespaces.Rmd.
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

echo "==> Making RStudio attach EJAM when it starts"
# Adds a few lines to an R startup file so that each new RStudio session runs
# library(EJAM). R started any other way (the terminal, Rscript) is unaffected.
MARK="# EJAM dev container: attach EJAM when RStudio starts"
SNIPPET="
${MARK}
if (interactive() && Sys.getenv(\"RSTUDIO\") == \"1\") {
  setHook(\"rstudio.sessionInit\", function(newSession) {
    if (newSession) try(library(EJAM))
  }, action = \"append\")
}
"
SITE_PROFILE="$(R RHOME)/etc/Rprofile.site"
if grep -qsF "${MARK}" "${SITE_PROFILE}" "${HOME}/.Rprofile"; then
  echo "    already set up"
elif printf '%s' "${SNIPPET}" >> "${SITE_PROFILE}" 2>/dev/null; then
  echo "    added to ${SITE_PROFILE}"
elif printf '%s' "${SNIPPET}" | sudo -n tee -a "${SITE_PROFILE}" > /dev/null 2>&1; then
  echo "    added to ${SITE_PROFILE}"
else
  printf '%s' "${SNIPPET}" >> "${HOME}/.Rprofile"
  echo "    added to ${HOME}/.Rprofile"
fi
