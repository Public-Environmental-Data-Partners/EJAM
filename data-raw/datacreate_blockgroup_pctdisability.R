###################################################### #

# datacreate_blockgroup_pctdisability  -  TAKES A WHILE TO DOWNLOAD THE CENSUS DATA FOR EVERY STATE !!

# to get counts, first need tract counts and then apportion to blockgroup counts:

###################################################### #

datacreate_blockgroup_pctdisability <- function(yr = acs_endyear(guess_census_has_published = TRUE) )  {

  # yr = EJAM:::acs_endyear(guess_census_has_published = TRUE) # e.g., 2022, 2023, or 2024
  cat("end year to use: ", yr, '\n')
  ###################################################### #
  # - download tract level acs for B18101

  tracts <- ACSdownload::get_acs_new(tables = "B18101", fips = "tract", yr = yr)
  tracts <- tracts[[1]]

  # - use formulas_ejscreen_acs_disability to get ONLY disability and disab_universe calculated in each tract, not the percentages by tract, or at least we wont use those % by tract
  # formulas_ejscreen_acs_disability <- formulas_ejscreen_acs_disability[c(3,2,1),]

  tracts <- calc_ejam(tracts, formulas = formulas_ejscreen_acs_disability$formula,
                      keep.old = "fips", keep.new = 'all')
  tracts$pctdisability <- NULL
  data.table::setnames(tracts, old = "fips", new = "tractfips")
  data.table::setnames(tracts, old = "disability", new = "tract_disability")
  data.table::setnames(tracts, old = "disab_universe", new = "tract_disab_universe")
  ###################################################### #
  # using a census API key already set in renviron or wherever,
  # - get tract and bg census 2000 pop counts, and with them create a table that is each bg with tractfips, bgfips and bgwt, where bgwt is the Census 2000 pop as fraction of tractwide Census 2000 pop.
  c2k = list()
  for (i in 1:length(stateinfo$ST)) {
    c2k[[i]] = tidycensus::get_decennial(state = stateinfo$ST[i], geography = "block group", variables = 'P1_001N', geometry = FALSE, year = 2020)
  }
  c2k2 = data.table::rbindlist(c2k)
  bgwts = c2k2[, .(bgfips = GEOID, pop = value)]
  bgwts[, tractfips := substr(bgfips, 1, 11)]
  bgwts[ , tractpop := sum(pop), by = "tractfips"]
  bgwts[, bgwt := ifelse(tractpop == 0, 0, pop / tractpop)]
  bgwts[, pop := NULL]
  bgwts[, tractpop := NULL]
  ###################################################### #
  # - take the bgwt, bgfips, tractfips data.table and
  # join it to tract table of tractfips and disability counts,
  # to get bg_disability table that has  tractwide counts of disability and disab_universe in each bg for each count variable

  bg_disability = tracts[bgwts, .(bgfips, bgwt, tract_disability, tract_disab_universe), on = "tractfips"]

  # - create blockgroup count in each bg, for each count variable, calculated from tractwide count times the bgwt

  bg_disability[, disability := tract_disability * bgwt]
  bg_disability[, disab_universe := tract_disab_universe * bgwt]

  # round to nearest person in each blockgroup only after calculating percent with disability

  # bg_disability[, disability := round(disability, 0)]
  # bg_disability[, disab_universe := round(disab_universe, 0)]

  # - finally take that bg_disability table and apply formulas_ejscreen_acs_disability to it, to calculate bg scale pctdisability
  # formulas_ejscreen_acs_disability$formula
  # or just use the formula directly
  bg_disability[, pctdisability := ifelse(disab_universe == 0, 0, as.numeric(disability) / disab_universe)]

  # drop extra columns now
  bg_disability$tract_disab_universe <- NULL
  bg_disability$tract_disability <- NULL
  bg_disability$bgwt <- NULL

  # as.data.frame(bg_disability)[bg_disability$bgfips == "010730144081", grepl("disa", names(bg_disability))]
  #      disability disab_universe pctdisability
  # 1866   103.5074        1945.26    0.05321009
  # > as.data.frame(blockgroupstats)[blockgroupstats$bgfips == "010730144081", grepl("disa", names(blockgroupstats))]
  #      disab_universe disability pctdisability
  # 1865           1945        104    0.05321009 # ok

  # > as.data.frame(blockgroupstats)[blockgroupstats$bgfips == "010730144082", grepl("disa", names(blockgroupstats))]
  # disab_universe disability pctdisability
  # 1866              0          0    0.05321009  # strange case - ejscreen data says 0.05 even though it shows 0/0
  # > as.data.frame(bg_disability)[bg_disability$bgfips == "010730144082", grepl("disa", names(bg_disability))]
  # disability disab_universe pctdisability
  # 1867          0              0             0

  # ROUND NOW,
  bg_disability[, disability := round(disability, 0)]
  bg_disability[, disab_universe := round(disab_universe, 0)]

  ##################################################################### #

  # for acs2022, validate against old ejscreen release from late 2024...

  # > dim(blockgroupstats)
  # [1] 242336    150
  # > dim(bg_disability)
  # [1] 242335      4
  inboth = blockgroupstats$bgfips[bg_disability$bgfips %in% blockgroupstats$bgfips]
  bs = blockgroupstats[blockgroupstats$bgfips %in% inboth, .(bgfips, pctdisability, disab_universe, disability)]
  bd = bg_disability[bg_disability$bgfips %in% inboth, ]

  ratios = bs$disab_universe / bd$disab_universe[match(bs$bgfips, bd$bgfips)]
  ratios[bs$disab_universe == 0]  <- 1
  summary(ratios)
  #   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 0.9968  1.0000  1.0000  1.0000  1.0000  1.0034   not exact but essentially replicates

  ratios = bs$disability / bd$disability[match(bs$bgfips, bd$bgfips)]
  ratios[bs$disability == 0]  <- 1
  summary(ratios)
  #    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 0.9861  1.0000  1.0000  1.0000  1.0000  1.0263    not exact but almost replicates

  ratios = bs$pctdisability / bd$pctdisability[match(bs$bgfips, bd$bgfips)]
  ratios[bs$pctdisability == 0]  <- 1
  summary(ratios)
  # Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 1       1       1     Inf       1     Inf   # IF ROUND BEFORE RATIO DONE, REPLICATES EXCEPT Inf glitch
  #   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  # 0.4899  0.9986  1.0000     Inf  1.0015     Inf   ## IF ROUNDED BEFORE RATIO, percentage calculation not replicated.   need to get ratio before rounding counts

  ##################################################################### #
  ## note that it does include Puerto Rico:
  table(fips2stateabbrev(   bg_disability$bgfips) )
  ##################################################################### #
  return(bg_disability)
}
##################################################################### ###################################################################### #
##################################################################### ###################################################################### #

# for now, save the work in progress
save(bg_disability, file = "./data-raw/bg_disability_2022.rda") # 2.3 MB

# if looks ok, join bg_disability into blockgroupstats

warning('do manually next steps if actually ready')

blockgroupstats[bg_disability, disability := disability, on = "bgfips"]
blockgroupstats[bg_disability, disab_universe := disab_universe, on = "bgfips"]
blockgroupstats[bg_disability, pctdisability := pctdisability, on = "bgfips"]

EJAM:::metadata_add_and_use_this(blockgroupstats)

##################################################################### ###################################################################### #
