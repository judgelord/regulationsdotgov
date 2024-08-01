

##############
# REQUIRES HELPER FUNCTIONS #
####################
library(magrittr)
library(stringr)
library(lubridate)
library(tidyverse)
library(httr)
source("R/get_dockets_batch.R")


get_dockets <- function(agency, 
                        lastModifiedDate = Sys.time(), 
                        api_keys){
  
  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_dockets_batch(agency, lastModifiedDate = Sys.time())
  
  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {
    
    # Fetch the next batch of comments using the last modified date
    nextbatch <- get_dockets_batch(agency,
                                   lastModifiedDate = tail(metadata$lastModifiedDate,
                                                           n = 1)
    )
    message(paste(nrow(metadata), "+", nrow(nextbatch)))
    
    # Append next batch to comments
    metadata <- suppressMessages(
      full_join(metadata, nextbatch)
    )
    
    message(paste(" = ", nrow(metadata)))
    
  }
  
  return(metadata)
  
}

# get_dockets(agency = "OMB")

