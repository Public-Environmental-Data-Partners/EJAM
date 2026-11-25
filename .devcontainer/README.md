# Running EJAM in a GitHub Codespace

This folder lets anyone with a GitHub account run EJAM's R functions in a web
browser, with nothing installed on their own computer. GitHub starts a private
Linux machine in the cloud, installs R, RStudio and EJAM on it, and shows it in
a browser tab. That machine is a "codespace".

## Start one

1. On the repository page, click the green **Code** button, then the
   **Codespaces** tab, then **Create codespace** on the branch you want.
2. Wait for setup to finish. The first start installs EJAM and downloads its
   large datasets, which takes a while. Later starts of the same codespace are
   quick.
3. Open the **Ports** tab at the bottom of the window and click the globe icon
   next to **RStudio** (port 8787). RStudio opens in a new browser tab, with no
   password to enter.
4. In RStudio, run:

   ```r
   library(EJAM)
   out <- ejamit(testpoints_10, radius = 1)
   ejam2report(out)
   ```

The window that opens first is VS Code. It also has an R terminal, so RStudio is
optional.

## Size and cost

- The default machine has 2 cores and 8 GB of memory. For an analysis of
  thousands of sites, pick a larger machine (4 cores, 16 GB) under
  **Code > Codespaces > ... > New with options**.
- Time is billed to the person who creates the codespace, not to this project.
  GitHub gives each personal account a free monthly allowance. A larger machine
  uses that allowance proportionally faster.
- A codespace stops when it has been idle for a while and is deleted after a
  longer period without use. Download any results you want to keep.

## What is not set up

- **R code completion in VS Code.** The helper that provides it is switched
  off, because it used about 3 GB of memory and left too little for an EJAM
  analysis on the default machine. RStudio has its own code completion.
- **PDF reports.** A headless Chrome browser is not installed, so functions
  that print a report to PDF or take a snapshot of a map will not work. HTML
  reports, tables, plots and interactive maps do not need it.
- **A Census API key.** Functions that download American Community Survey data
  need a key. Set it for the session with `Sys.setenv(CENSUS_API_KEY = "...")`.
- **Prebuilt codespaces.** Every new codespace runs the whole setup. GitHub can
  build codespaces ahead of time so they start quickly, at a storage cost to the
  repository owner. That is not turned on.

## Files

- `devcontainer.json`: the machine image, RStudio Server, the system libraries,
  and the commands that run at startup.
- `setup.sh`: installs EJAM from the checked-out branch and downloads its data.
