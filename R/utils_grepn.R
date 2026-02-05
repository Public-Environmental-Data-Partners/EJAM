
# how many matches within each element of x vector?

# Also see EJAM:::find_in_files()
#
# Undocumented related functions:
# EJAM:::found_in_files()
# EJAM:::found_in_N_files_T_times()
# EJAM:::grab_hits()
# EJAM:::grepn()

grepn = function(pattern, x) {

  info = gregexec(pattern = pattern, text = x)
  sapply(info, function(z) ifelse(z[1] == -1, 0, length(z)))
}
