library(httr)
library(jsonlite)
library(purrr)
library(dplyr)

#############################
# REQUIRES HELPER FUNCTIONS #
#############################
source("R/get_documents_batch.R")


get_documents <- function(docketId,
                          lastModifiedDate = Sys.time(),
                          api_keys = keys){

  lastModifiedDate <- format_date(lastModifiedDate)


  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_documents_batch(docketId,
                                  lastModifiedDate,
                                  apikeys = api_keys)

  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of comments using the last modified date
    nextbatch <- get_documents_batch(agency,
                                   lastModifiedDate = tail(metadata$lastModifiedDate,
                                                           n = 1) |>
                                     str_replace("T", "%20") |>
                                     str_remove_all("[A-Z]"),
                                   apikeys = api_keys
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
  n <- get_documents(docketId = "USPC-2021-0005")
}

