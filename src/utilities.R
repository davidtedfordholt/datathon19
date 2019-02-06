install_requirements <- function(file = "requirements.txt") {
    if (!require(pacman)) install.packages("pacman")
    pkgs <- readLines(file)
    pkgs <- pkgs[which(substr(pkgs, 1, 1) != "#" & pkgs != "")]
    pacman::p_load(pkgs)
}

create_connection <- function() {
    return(
        odbc::dbConnect(odbc::odbc(),
                        Driver = "SQL Server",
                        Server = "",
                        Database = "",
                        UID = "",
                        PWD = "",
                        Port = ,
                        quiet = FALSE)
    )
}

list_tables <- function() {
    return(create_connection() %>%
               odbc::dbListTables())
    odbc::dbDisconnect()
}


load_tables <- function(tables, drop_previous_pull = FALSE) {
    ## This file allows for the data environment to be set up
    ## consistently for different users. All raw data will live in
    ## the /data/raw folder
    
    # REQUIRED PACKAGES
    require(odbc); require(readr); require(feather)
    
    
    if (!is.vector(tables) & !is.list(tables)) {
        stop("Please provide a vector or list of table names")
    }
    
    # set working directory to the data folder
    setwd("./data/raw/")
    for (i in tables) {
        
        if (!exists(i)) {
            filename_feather <- paste0(i, ".feather")
            filename_csv <- paste0(i, ".csv")
            
            if (drop_previous_pull == TRUE) {
                if (file.exists(filename_feather)) file.remove(filename_feather)
                if (file.exists(filename_csv)) file.remove(filename_csv)
            }
            
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
                # create SQL Server connection
                if (!exists("connection")) connection <- create_connection()
                
                # execute SQL query for all data in the table                
                tmp <- dbGetQuery(connection, paste0("SELECT * FROM dbo.", i))
                
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
    }
    
    # return the working directory to the repo folder
    setwd("../..")
    
    if (exists("connection")) dbDisconnect(connection)
    # rm(connection, classes, tables, filename_csv, filename_feather, i)
}