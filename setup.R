## This file allows for the data environment to be set up
## consistently for different users. All data will live in
## the /data/ folder

# REQUIRED PACKAGES

if(!require(pacman)) install.packages("pacman"); require(pacman)
pacman::p_load(tidyverse, lubridate, odbc)


# REQUIRED TABLES

tables <- c(
    "DIBI_Permits", "A4A_Monthly_Cargo_Traffic"
)












# create SQL Server connection
connection <- dbConnect(odbc(),
                        Driver = "SQL Server",
                        Server = "freightwaves.ctaqnedkuefm.us-east-2.rds.amazonaws.com",
                        Database = "Warehouse",
                        UID = "fwdbmain",
                        PWD = "7AC?Ls9_z3W#@XrR",
                        Port = 1433)

# set working directory to the data folder
setwd("./data/")
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
        
        read_csv(filename) %>%
            assign(i, value = .)
        
    }
}

# return the working directory to the repo folder
setwd("..")


dbDisconnect(connection)
rm(connection)
