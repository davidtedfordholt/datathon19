if (!require(pacman)) install.packages("pacman"); require(pacman)
pacman::p_load(tidyverse, lubridate, feather)

# READ IN RAW/EXT DATA
data <- read_feather("./data/raw/")
# data <- read_csv("./data/raw/")
# ext <- read_csv("./data/external/")



# JOIN ALL THE THINGS!!!



# SAVE INTERIM DATA
write_feather(data, "./data/interim//")
# write_csv(data, "./data/interim")