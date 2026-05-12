if (basename(getwd()) != "EJAM") {stop("must start in root of source folder")}

library(EJAM)

info = capture.output({
  EJAM:::pkgdown_update(doask = F,
                        doclean_man = F, doclean_docs = TRUE,
                        dodocument = TRUE, doinstall = F, doloadall_not_library = T,
                        doyamlcheck = T,
                        dotests = F, testinteractively = F
  )
})
print(info)
EJAM:::rmost(notremove = "info")
beepr::beep()
