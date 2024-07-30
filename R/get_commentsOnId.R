library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

source("R/get_comments_batch.R")

get_commentsOnId <- function(commentOnId){

  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_comments_batch(commentOnId, lastModifiedDate = Sys.time())

  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of comments using the last modified date
    nextbatch <- get_comments_batch(commentOnId,
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


