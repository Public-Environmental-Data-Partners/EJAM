FROM rocker/rstudio:latest

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libudunits2-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libproj-dev \
    libgdal-dev \
    libmagick++-dev \
    libnode-dev \
    texlive \
    texlive-latex-extra \
    texlive-fonts-extra \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome stable (chromium-browser on Ubuntu 22.04+ is a snap stub — won't work in Docker)
RUN curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb && \
    apt-get update && apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb && \
    rm -rf /var/lib/apt/lists/*

# Wrapper adds --no-sandbox flags required when running as root in a container
RUN printf '#!/bin/bash\nexec /usr/bin/google-chrome-stable --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage "$@"\n' \
    > /usr/local/bin/chrome-wrapper && chmod +x /usr/local/bin/chrome-wrapper

# Point chromote/pagedown/webshot2 at the wrapper
ENV CHROMOTE_CHROME=/usr/local/bin/chrome-wrapper

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws

ARG GITHUB_PAT

# EJAM package version to install: a released git tag. Pinned by default to the
# current release; override with --build-arg EJAM_VERSION=vX.Y.Z. Mirrors the
# EJAM-API image's EJAM_VERSION build-arg so both deploys pin EJAM the same way,
# and makes the deployed version EXPLICIT (rather than implicitly tied to whatever
# source happens to be checked out on this deploy branch).
ARG EJAM_VERSION=v3.2022.1
ENV EJAM_VERSION=${EJAM_VERSION}

WORKDIR /root

# Install R packages — sourced from DESCRIPTION Imports + runtime-relevant Suggests
# Explicit pre-install avoids the EJAM install having to resolve everything from scratch
# and improves Docker layer caching (this layer only rebuilds if the list changes).
RUN install2.r --error \
    \
    `# --- Spatial / geo ---` \
    s2 \
    sf \
    geojsonio \
    terra \
    units \
    sp \
    \
    `# --- Core data / tidyverse ---` \
    tidyverse \
    arrow \
    collapse \
    data.table \
    dplyr \
    tidyr \
    readxl \
    writexl \
    openxlsx \
    \
    `# --- HTTP / GitHub ---` \
    curl \
    httr2 \
    gh \
    piggyback \
    \
    `# --- Shiny / UI ---` \
    shiny \
    shinycssloaders \
    shinydisconnect \
    shinyjs \
    golem \
    htmltools \
    htmlwidgets \
    DT \
    rhandsontable \
    leaflet \
    leaflet.extras \
    leaflet.extras2 \
    plotly \
    viridis \
    ggplot2 \
    ggridges \
    \
    `# --- Reporting ---` \
    rmarkdown \
    knitr \
    gt \
    pagedown \
    webshot \
    webshot2 \
    \
    `# --- Utilities ---` \
    fs \
    glue \
    magrittr \
    methods \
    jsonlite \
    XML \
    desc \
    pkgload \
    config \
    pdist \
    SearchTrees \
    \
    `# --- Census / geographic data ---` \
    tidycensus \
    tigris \
    tidygeocoder \
    rnaturalearth \
    mapview \
    \
    `# --- Suggests (runtime-relevant) ---` \
    beepr \
    fipio \
    rvest \
    remotes \
    \
    `# --- Legacy / extra (not in DESCRIPTION but kept for compatibility) ---` \
    DBI \
    RMySQL \
    pins \
    \
    && rm -rf /tmp/downloaded_packages /tmp/*.rds

# GitHub packages
RUN R -e "remotes::install_github('mikejohnson51/AOI')" && \
    R -e "remotes::install_github('hrbrmstr/hrbrthemes')" && \
    rm -rf /tmp/downloaded_packages /tmp/*.rds

# Install the EJAM package from its pinned GitHub release tag (EJAM is a public
# repo, so no token is needed). Installing a released tag -- rather than the local
# build context -- makes the deployed version explicit and reproducible. The
# package's data/*.rda ship in the release tarball; the large ejamdata arrow files
# are fetched separately below. (Container entrypoint runs the installed
# EJAM::ejamapp(), so no local app source is needed in the image.)
RUN R -e "remotes::install_github(paste0('Public-Environmental-Data-Partners/EJAM@', Sys.getenv('EJAM_VERSION')), dependencies = TRUE, upgrade = 'never')" && \
    rm -rf /tmp/downloaded_packages /tmp/*.rds

# Download ejamdata arrow files from GitHub release
# Must run AFTER the EJAM package install so the data/ folder is not overwritten by the installer
# EJAMDATA_VERSION: pinned by default to v3.2022.0 -- the ejamdata release that
#   EJAM v3.2022.1 requires (its DESCRIPTION `ejamdata_required_tag`). Keep this in
#   sync with EJAM_VERSION when bumping releases; override with
#   --build-arg EJAMDATA_VERSION=vX.Y.Z. (An explicit empty string falls back to the
#   latest ejamdata release via the GitHub API below.)
ARG EJAMDATA_VERSION=v3.2022.0
RUN RESOLVED_VERSION="${EJAMDATA_VERSION:-$(curl -fsSL \
      -H "Authorization: token ${GITHUB_PAT}" \
      "https://api.github.com/repos/Public-Environmental-Data-Partners/ejamdata/releases/latest" \
      | grep '"tag_name"' | head -1 | cut -d'"' -f4)}" && \
    echo "==> Downloading ejamdata ${RESOLVED_VERSION}" && \
    mkdir -p /usr/local/lib/R/site-library/EJAM/data && \
    for FILE in blockpoints blockwts quaddata bgej bgid2fips blockid2fips frs frs_by_programid frs_by_naics frs_by_sic frs_by_mact; do \
      curl -fSL \
        -H "Authorization: token ${GITHUB_PAT}" \
        -H "Accept: application/octet-stream" \
        "https://github.com/Public-Environmental-Data-Partners/ejamdata/releases/download/${RESOLVED_VERSION}/${FILE}.arrow" \
        -o "/usr/local/lib/R/site-library/EJAM/data/${FILE}.arrow"; \
    done && \
    echo "${RESOLVED_VERSION}" > /usr/local/lib/R/site-library/EJAM/data/ejamdata_version.txt

EXPOSE 2000 2001

WORKDIR /root
# EJAM v3.x exports ejamapp() as the app launcher; run_app() is no longer exported
# (calling it here made every ECS task exit 1 with "'run_app' is not an exported
# object from 'namespace:EJAM'"). ejamapp(isPublic=...) is supported and its
# options= list is passed to shinyApp() for host/port.
CMD ["R", "-e", "httpuv::startServer('0.0.0.0', 2001, list(call = function(req) { list(status = 200, body = 'OK', headers = list('Content-Type' = 'text/plain')) })); library(EJAM); EJAM::ejamapp(isPublic = TRUE, options = list(host = '0.0.0.0', port = 2000))"]