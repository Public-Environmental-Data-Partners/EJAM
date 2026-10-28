library(rmarkdown)

# 1. Set up directory paths
wd <- getwd()
sourcePath <- file.path(wd, "vignettes", "env-indicators", "utilities", "archived_html", "htmlScrubbed")
destPath   <- file.path(wd, "vignettes", "env-indicators", "utilities", "archived_html", "pandocMarkdown")

# 2. Ensure the destination directory exists
if (!dir.exists(destPath)) {
  dir.create(destPath, recursive = TRUE)
}

# 3. Get list of all HTML files in the source folder
html_files <- list.files(sourcePath, pattern = "\\.html$", full.names = TRUE)

# 4. Loop through each file and convert to markdown
for (fromFile in html_files) {
  # Swap .html extension for .md
  md_name <- sub("\\.html$", ".md", basename(fromFile))
  toFile  <- file.path(destPath, md_name)
  
  cat("Converting:", basename(fromFile), "\n")
  
  pandoc_convert(
    input  = fromFile,
    to     = "markdown",
    from   = "html",
    output = toFile
  )
}

cat("Conversion complete!\n")