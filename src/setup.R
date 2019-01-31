load_tables <- function(tables) {
    ## This file allows for the data environment to be set up
    ## consistently for different users. All data will live in
    ## the /data/ folder
    
    # REQUIRED PACKAGES
    
    if(!require(odbc)) install.packages("odbc"); require(odbc)
    if(!require(readr)) install.packages("readr"); require(readr)
    if(!require(feather)) install.packages("feather"); require(feather)
    
    
    if (!is.vector(tables) & !is.list(tables)) {
        stop("Please provide a vector or list of table names in Warehouse.dbo.")
    }
    
    # create SQL Server connection
    connection <- dbConnect(odbc(),
                            Driver = "SQL Server",
                            Server = "freightwaves.ctaqnedkuefm.us-east-2.rds.amazonaws.com",
                            Database = "Warehouse",
                            UID = "fwdbview",
                            PWD = "p$t:n7dtvnAcs?B<",
                            Port = 1433,
                            quiet = FALSE)
    
    # set working directory to the data folder
    setwd("./data/raw/")
    for (i in tables) {
        
        filename_feather <- paste0(i, ".feather")
        filename_csv <- paste0(i, ".csv")
        
        # if the table has previously been downloaded,
        # load from the file
        if (file.exists(filename_feather)) {
            tmp <- read_feather(filename_feather)
            assign(i, value = tmp, pos = .GlobalEnv)
            rm(tmp)
        } else if (file.exists(filename_csv)) {
            tmp <- read_csv(filename_csv)
            assign(i, value = tmp, pos = .GlobalEnv)
            rm(tmp)
            
        # if the table hasn't been downloaded,
        # download and store the table
        } else {
            # execute SQL query for all data in the table
            tmp <- dbGetQuery(connection, paste0("SELECT * FROM Warehouse.dbo.", i))
            
            # store as binary, if possible
            # otherwise, use csv 
            classes <- lapply(tmp, class)
            if (!("list" %in% classes | "blob" %in% classes)) {
                write_feather(tmp, path = filename_feather)
            } else {
                write_csv(tmp, path = filename_csv)
            }
            
            # place the table into memory
            assign(i, value = tmp, pos = .GlobalEnv)
            
            # clear tmp
            rm(tmp)
        }
    }
    
    # return the working directory to the repo folder
    setwd("../..")
    
    
    dbDisconnect(connection)
    # rm(connection, classes, tables, filename_csv, filename_feather, i)
}
