library(httr)
library(jsonlite)
library(purrr)
library(dplyr)

#############################
# REQUIRES HELPER FUNCTIONS #
#############################
source("R/get_dockets_batch.R")


get_dockets <- function(agency,
                        lastModifiedDate = Sys.time(),
                        api_keys){

  lastModifiedDate <- format_date(lastModifiedDate)


  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_dockets_batch(agency, lastModifiedDate)

  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of comments using the last modified date
    lastModifiedDate = tail(metadata$lastModifiedDate,  n = 1) |>
    format_date2()

    nextbatch <- get_dockets_batch(agency,
                                   lastModifiedDate
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

# TESTING
if(F){
n <- get_dockets(agency = "OMB")
}

