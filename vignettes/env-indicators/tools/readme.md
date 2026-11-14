The scripts in this folder have been used to pull wayback archived
pages, clean the html, convert it to .md, and then promote it to
valid .Rmd files ready to be handled by the RStudio build.

They aren't production scripts, just one-offs generated almost 
100% by my AI tools as I walked through the process one time.
But they seem worth retaining, for at least a while, as references
in case we decide to do more repatriating of archived web pages 
into our own repo.

Meantime, steps are:
- build a list of the wayback URLs you want to readopt in a text file, 
one per line
- run retrieve_wayback.py specifying that text file as input
- your downloaded files will appear in the archived_html subfolder
- copy those files to archived_html/asDownloaded
- run scrub_archived_html.py (no commandline input needed) 
- scrubbed files will appear in archive_html/htmlScrubbed
- from R studio, run the pandoc html->markdown conversion, html2markdown.R. 
The converted files will appear in archive_html/pandocMarkdown
- from Python commandline again, run build_indiator_rmd.py
Files will be written to the archive_html/Rmd folder
- Move the new .Rmd files to their appropriate locations in 
the folder tree and update _pkgdown.yml so they will get built by R studio
- Update the .Rmd files that had links to the old wayback versions
