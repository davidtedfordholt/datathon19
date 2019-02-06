# pacman::p_load(tidyverse, lubridate, feather)

# READ IN RAW/EXT DATA
load_tables(c("HNP_StatsCountry", "HNP_StatsCountry-Series", 
              "HNP_StatsData", "HNP_StatsFootNote",
              "HNP_StatsSeries", "HNP_StatsSeries-Time"))
# data <- read_feather("./data/raw/")
# data <- read_csv("./data/raw/")
# ext <- read_csv("./data/external/")



# JOIN ALL THE THINGS!!!



# SAVE INTERIM DATA
# write_feather(data, "./data/interim//")
# write_csv(data, "./data/interim")