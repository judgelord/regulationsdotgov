# pulling first 5k comments 
# I wrote this for my own use but it could be helpful in the future and its working

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

commentids <- d$id[1000:2000]

get_commentdetails4 <- function(commentId,
                                lastModifiedDate = Sys.time(),
                                pages,
                                delay_seconds = 3.6) { 
  
  path <- lapply(commentId, function(id) {
    paste0("https://api.regulations.gov/v4/comments/", 
           id,
           "?include=attachments",
           "&api_key=", api_key)
  })
  
  fetch_with_delay <- function(path) {
    Sys.sleep(delay_seconds)  
    GET(path)
  }
  
  result <- purrr::map(path, ~slowly(fetch_with_delay, rate = rate_delay(delay_seconds))(.x))
  

  metadata <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))
  

  first5k <- purrr::map_dfr(metadata, ~.x$data$attributes)

  return(first5k)
}

attachment <- get_commentdetails4(commentId = "OMB-2023-0001-18154")
c2 <- get_commentdetails4(commentId = commentids)
 