pause = function(seconds = 1) {
  x <- FALSE
  x <- try({Sys.sleep(seconds); TRUE}, silent = TRUE)
  if (inherits(x, "try-error")) {
    start = Sys.time()
    while (Sys.time() - start < seconds) { }
  }
  return(NULL)
}
