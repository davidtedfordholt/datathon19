if (!require(pacman)) install.packages("pacman"); require(pacman)
pacman::p_load(tidyverse, lubridate, feather)

# READ IN RAW/EXT DATA
data <- read_feather("./data/raw/")
# data <- read_csv("./data/raw/")
# ext <- read_csv("./data/external/")


Transformations





# SAVE PROCESSED DATA
write_feather(final_data, "./data/processed/")
# write_csv(final_data, "./data/processed")