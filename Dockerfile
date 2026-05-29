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

RUN mkdir -p /home/epic
WORKDIR /home/epic

# Install R packages — sourced from DESCRIPTION Imports + runtime-relevant Suggests
# Explicit pre-install avoids install_local having to resolve everything from scratch
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

# Copy app files
ADD . /home/epic/

# Install local package
RUN R -e "remotes::install_local('/home/epic/', dependencies = TRUE)" && \
    rm -rf /tmp/downloaded_packages /tmp/*.rds

# Download ejamdata arrow files from GitHub release
# Must run AFTER install_local so the data/ folder is not overwritten by the installer
# EJAMDATA_VERSION: leave unset (or pass empty string) to auto-resolve to the latest
#   release of ejamdata, or pin to a specific tag (e.g. --build-arg EJAMDATA_VERSION=v2.32.8.001)
ARG EJAMDATA_VERSION
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

WORKDIR /home/epic
CMD ["R", "-e", "httpuv::startServer('0.0.0.0', 2001, list(call = function(req) { list(status = 200, body = 'OK', headers = list('Content-Type' = 'text/plain')) })); library(EJAM); EJAM::run_app(isPublic = TRUE, options = list(host = '0.0.0.0', port = 2000))"]