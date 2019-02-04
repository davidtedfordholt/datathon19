if (!require(pacman)) install.packages("pacman"); require(pacman)
pacman::p_load(tidyverse, lubridate, feather, caret, mlbench)

# READ IN PROCESSED DATA
data <- read_feather("./data/processed/")
# data <- read_csv("./data/processed/")


# CREATE A MODEL
# set.seed(1500)
model <- 

    

# SAVE THE MODEL    
saveRDS(model, "./models/model.rds")