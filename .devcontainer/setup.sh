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

# Append a few lines of R to a startup file that every R session reads, unless
# they are already there. $1 is a comment line that marks the lines, $2 the R code.
add_r_startup() {
  local mark="$1" snippet
  snippet="$(printf '\n%s\n%s\n' "$1" "$2")"
  local site_profile
  site_profile="$(R RHOME)/etc/Rprofile.site"
  if grep -qsF "${mark}" "${site_profile}" "${HOME}/.Rprofile"; then
    echo "    already set up"
  elif printf '%s\n' "${snippet}" >> "${site_profile}" 2>/dev/null; then
    echo "    added to ${site_profile}"
  elif printf '%s\n' "${snippet}" | sudo -n tee -a "${site_profile}" > /dev/null 2>&1; then
    echo "    added to ${site_profile}"
  else
    printf '%s\n' "${snippet}" >> "${HOME}/.Rprofile"
    echo "    added to ${HOME}/.Rprofile"
  fi
}

echo "==> Making RStudio attach EJAM when it starts"
# Each new RStudio session runs library(EJAM). R started any other way (the
# terminal, Rscript) is unaffected.
add_r_startup "# EJAM dev container: attach EJAM when RStudio starts" \
'if (interactive() && Sys.getenv("RSTUDIO") == "1") {
  setHook("rstudio.sessionInit", function(newSession) {
    if (newSession) try(library(EJAM))
  }, action = "append")
}'

echo "==> Letting PDF reports start the Chromium browser"
# pagedown::chrome_print(), which turns a report into a PDF, starts Chromium
# without the options it needs inside a container and then fails with "Cannot
# find headless Chrome". A small launcher adds those options, and the
# PAGEDOWN_CHROME variable points pagedown at it. A problem here must not stop
# the rest of the setup, so nothing in this part is allowed to fail the script.
CHROMIUM="$(command -v chromium || command -v chromium-browser || true)"
if [ -z "${CHROMIUM}" ]; then
  echo "    no Chromium found, so PDF reports will not work"
else
  LAUNCHER_TEXT="$(printf '#!/bin/bash\nexec %s --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage "$@"\n' "${CHROMIUM}")"
  LAUNCHER=""
  for candidate in /usr/local/bin/ejam-chrome-wrapper "${HOME}/ejam-chrome-wrapper"; do
    if { printf '%s\n' "${LAUNCHER_TEXT}" > "${candidate}" && chmod 755 "${candidate}"; } 2>/dev/null; then
      LAUNCHER="${candidate}"; break
    elif printf '%s\n' "${LAUNCHER_TEXT}" | sudo -n tee "${candidate}" > /dev/null 2>&1 \
        && sudo -n chmod 755 "${candidate}" 2>/dev/null; then
      LAUNCHER="${candidate}"; break
    fi
  done
  if [ -z "${LAUNCHER}" ]; then
    echo "    could not write the launcher, so PDF reports will not work"
  else
    echo "    launcher written to ${LAUNCHER}"
    add_r_startup "# EJAM dev container: Chromium launcher for PDF reports" \
"if (!nzchar(Sys.getenv(\"PAGEDOWN_CHROME\")) && file.exists(\"${LAUNCHER}\")) {
  Sys.setenv(PAGEDOWN_CHROME = \"${LAUNCHER}\")
}" || echo "    could not add the R startup lines, so PDF reports will not work"
  fi
fi
