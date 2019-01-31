load_tables <- function(tables) {
    ## This file allows for the data environment to be set up
    ## consistently for different users. All data will live in
    ## the /data/ folder
    
    # REQUIRED PACKAGES
    
    if(!require(odbc)) install.packages("odbc"); require(odbc)
    if(!require(readr)) install.packages("readr"); require(readr)
    
    
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
                            Port = 1433)
    
    # set working directory to the data folder
    setwd("./data/raw/")
    for (i in tables) {
        
        filename <- paste0(i, ".csv")
        
        if (!file.exists(filename)) {
            
            # execute SQL query for all data in the table
            tmp <- dbGetQuery(connection, paste0("SELECT * FROM Warehouse.dbo.", i))
            
            # write a .csv of the data in the /data/ folder
            write_csv(tmp, path = filename)
            
            # store the data into memory
            assign(i, value = tmp)
            rm(tmp)
            
        } else {
            
            tmp <- read_csv(filename)
            assign(i, value = tmp)
            rm(tmp)
            
        }
    }
    
    # return the working directory to the repo folder
    setwd("../..")
    
    
    dbDisconnect(connection)
    rm(connection)
}


