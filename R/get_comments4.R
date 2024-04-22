# This script builds a function that pulls all comments related to a docket
# This function uses the get_docket4 function 

# just pulls the metadata, no detail about individual comments

# source("api-key.R") 

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

get_comments4 <- function(docketId,
                        lastModifiedDate = Sys.time(),
                        pages){
  
  objectId <- get_docket4(docketId = docketId, endpoint = "documents", pages = 1:20) %>%
    filter(complete.cases(commentEndDate, commentStartDate)) %>%
    pull(objectId)
  
  path <- purrr::map(objectId, ~{
    paste0("https://api.regulations.gov",
           "/v4/",
           "comments", 
           "?filter[commentOnId]=", .x,
           "&page[size]=250",
           "&page[number]=", 1:20,
           "&sort=-lastModifiedDate,documentId",
           "&api_key=", api_key)}) %>%
    unlist()
  
  result <- purrr::map(path, ~(GET(.x)))
  
  metadata <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))
  
  first5k <- map_dfr(metadata, ~{ 
    data <- .x$data
    meta <- .x$meta
    data_frame <- data$attributes %>%
      as_tibble() %>%
      mutate(id = data$id,
             type = data$type,
             links = data$links$self,
             lastpage = meta$lastPage)
    return(data_frame)
  }) # this currently doesn't record the objectId of which notice the comments are coming from

 ## NEXT STEP IS GRABBING THE NEXT 5K LOOPING OVER LAST MODIFIED DATE
  
  lastModifiedDate <- first5k$lastModifiedDate %>%
    tail(1) %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    gsub(" ", "%20", .)
  
  path <- purrr::map(objectId, ~{
    paste0("https://api.regulations.gov",
           "/v4/",
           "comments", 
           "?filter[commentOnId]=", .x,
           "&filter[lastModifiedDate][ge]=",lastModifiedDate,
           "&page[size]=250",
           "&page[number]=", 1:20,
           "&sort=lastModifiedDate,documentId",
           "&api_key=", api_key)}) %>%
    unlist()
  
  result <- purrr::map(path, ~(GET(.x)))
  
  metadata <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))
  
  next5k <- map_dfr(metadata, ~{ 
    data <- .x$data
    meta <- .x$meta
    data_frame <- data$attributes %>%
      as_tibble() %>%
      mutate(id = data$id,
             type = data$type,
             links = data$links$self,
             lastpage = meta$lastPage)
    return(data_frame)
  })
  
  return(next5k)
}

## code to pull first 10k  but major issues:
## 1) pulling duplicates because I can't maintain the object IDs
## 2) need to merge the dataframes 
## 3) needs a loop that is dependent on whether the last page has been reached

#next5k <- get_comments4(docketId = "OMB-2023-0001")
#
#check <- get_comments4(docketId = "OMB-2023-0001")
#
#c <- get_docket4(docketId = "OMB-2023-0001",endpoint="documents",pages = 1:20)


