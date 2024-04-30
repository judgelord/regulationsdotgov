# pulling first 5k comments 
# I wrote this for my own use but it could be helpful in the future and its working

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

commentids <- d$id[1:1000]
  
get_commentdetails4 <- function(commentId,
                                  lastModifiedDate = Sys.time(),
                                  pages){
    
    path <- lapply(commentId, function(id) {
      paste0("https://api.regulations.gov/v4/comments/", 
             id,
             "?include=attachments",
             "&api_key=", api_key)
    })
  
  result <- purrr::map(path, ~(GET(.x)))
  
  metadata <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))
  
  first5k <- purrr::map_dfr(metadata, ~{
    data <- .x$data$attributes
    })
  
  return(first5k)
  }

attachment <- get_commentdetails4(commentId = "OMB-2023-0001-18154")
 