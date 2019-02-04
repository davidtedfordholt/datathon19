if (!require(pacman)) install.packages("pacman"); require(pacman)
pacman::p_load(tidyverse, lubridate, feather)

# READ IN RAW/EXT DATA
data <- read_feather("./data/raw/")
# data <- read_csv("./data/raw/")
# ext <- read_csv("./data/external/")




# MISSING DATA:
#     IF you're going to impute:
#       KNN, trees, linear, MICE, missForest, Hmisc, mi, Amelia
#     Otherwise, consider encoding missingness
# 
# CATEGORICAL:
#     Factors or Dummy variables
#     Hashing
#     Compress rare
#     Effect/Likelihood encoding
#     
# ORDINAL:
#     Polynomial contrast
#     
# NUMERIC:
#     Transformations (Box-Cox, smoothing, )
#     Expansions (splines/knots, loess/GAM, hinge, binning)
#     Multi-dimensional (linear projection, PCA/ICA/Kernel PCA, autoencoders, matrix factorization, distance/depth)
#     
# INTERACTIONS:
#     LASSO
#     Two-stage modeling
#     Trees
#     Cubist



# Is your data centered & scaled?


# SAVE PROCESSED DATA
write_feather(final_data, "./data/processed/")
# write_csv(final_data, "./data/processed")