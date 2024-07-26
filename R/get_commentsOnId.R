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



if(F){
  #commentOnId = "09000064856107a5" # this is https://www.regulations.gov/document/OMB-2023-0001-0001
  commentOnId = "090000648592bfcc" #https://www.regulations.gov/document/OMB-2023-0001-12471 - less pages / calls
  commentOnId = "09000064824e36b7"
commentOnId = "09000064856107a5"

n <- get_commentsOnId(commentOnId)

c <- unique(n$objectId)


}
