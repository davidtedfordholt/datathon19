install_requirements <- function(file = "requirements.txt") {
    pkgs <- readLines(file)
    for (i in pkgs) {
        if (i)
        if (!require(i)) install.packages(i)
    }
}

create_connection <- function() {
    return(
        odbc::dbConnect(odbc::odbc(),
                        Driver = "SQL Server",
                        Server = "freightwaves.ctaqnedkuefm.us-east-2.rds.amazonaws.com",
                        Database = "Warehouse",
                        UID = "fwdbview",
                        PWD = "p$t:n7dtvnAcs?B<",
                        Port = 1433,
                        quiet = FALSE)
    )
}

list_tables <- function() {
    return(create_connection() %>%
               odbc::dbListTables() %>%
               .[1:(which(. == "trace_xe_action_map") - 1)])
    odbc::dbDisconnect()
}


load_tables <- function(tables, drop_previous_pull = FALSE) {
    ## This file allows for the data environment to be set up
    ## consistently for different users. All raw data will live in
    ## the /data/raw folder
    
    # REQUIRED PACKAGES
    require(odbc); require(readr); require(feather)
    
    
    if (!is.vector(tables) & !is.list(tables)) {
        stop("Please provide a vector or list of table names in Warehouse.dbo.")
    }
    
    # create SQL Server connection
    connection <- create_connection()
    
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
    }
    
    # return the working directory to the repo folder
    setwd("../..")
    
    dbDisconnect(connection)
    # rm(connection, classes, tables, filename_csv, filename_feather, i)
}

check_if_NA_above_threshold <- function(column, threshold = 1) {
    return(sum(is.na(column))/length(column) >= threshold)
}

####    this is in progress and NOT WORKING     ####

# create_reports <- function(tables, NA_threshold = 1) {
#     for (i in tables) {
#         tmp <- get(i)
#         
#         tmp <- tmp[, sapply(tmp, class) %in% 
#                        c("integer", "logical", "numeric", "double", "character")]
#         
#         tmp <- tmp[, !sapply(tmp, check_if_NA_above_threshold, NA_threshold)]
#         
#         config <- list(
#             "introduce" = list(),
#             "plot_str" = list(
#                 "type" = "diagonal",
#                 "fontSize" = 35,
#                 "width" = 1000,
#                 "margin" = list("left" = 350, "right" = 250)
#             ),
#             "plot_missing" = list(),
#             "plot_histogram" = list(),
#             "plot_qq" = list(sampled_rows = 1000L),
#             "plot_bar" = list(),
#             # "plot_correlation" = list("cor_args" = list("use" = "pairwise.complete.obs")),
#             # "plot_prcomp" = list(),
#             "plot_boxplot" = list(),
#             "plot_scatterplot" = list(sampled_rows = 1000L)
#         )
#         
#         try(DataExplorer::
#                 create_report(tmp, 
#                               output_file = paste0(i, ".html"), 
#                               output_dir = "./reports/",
#                               output_format = "html_document",
#                               config = config)
#         )
#     }
#     rm(i); rm(tmp)
# }

