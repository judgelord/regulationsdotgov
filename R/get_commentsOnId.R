library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

source("R/get_comments4_mk.R")

get_commentsOnId <- function(commentOnId){
  
  # Fetch the initial 5k and establish the base dataframe
  comments <- get_comments4_batch(commentOnId, lastModifiedDate = Sys.time())
 
  # Loop until lastpage is TRUE
  while (!comments$lastpage[1]) {
    # Fetch the next batch of comments using the last modified date
    nextbatch <- get_comments4_batch(commentOnId, lastModifiedDate = tail(comments$lastModifiedDate, n = 1))
    
    # Append nextbatch to comments
    comments <- bind_rows(comments, nextbatch)
  }
  
  return(comments)
}



if(F){ 
commentOnId = "09000064856107a5" 

n <- get_commentsOnId(commentOnId) 

c <- unique(n$objectId)

}
