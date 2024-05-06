# This script builds a function that pulls all documents related to a single docket 
# This function will be used as a helper function for pulling comments

# currently just pulls the metadata with no pdf or supporting content - should be updated

# source("api-key.R") 

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

get_docket4 <- function(docketId,
                        lastModifiedDate = Sys.time(), 
                        endpoint){
    
    # backwards integration with v3 functions 
    #endpoint = ifelse(documenttype %in% c("Public Submission", "comments"), "comments", "documents") 
    # do we want to build one function that can pull either comments/documents/dockets (three available endpoints) or 
    # seperate functions for each 
  
    #default settings
    url  <- "https://api.regulations.gov"
    rpp <- 250 # results per page
    sortby <- "-postedDate" # decending posted date 
    lastModifiedDate = Sys.time() %>% str_replace_all("[A-Z]", " ") %>%  str_squish()
    
    path <- paste0("/v4/",
                   endpoint, 
                   "?filter[docketId]=",docketId,
                   "&page[size]=250", 
                   "&page[number]=", 1:20,
                   "&api_key=", api_key)
    
    # inspect path 
    urls <- str_c("https://api.regulations.gov", path)
    
    metadata <- purrr::map(urls, ~(GET(.x)))
    
    content <- purrr::map(metadata, ~fromJSON(rawToChar(.x$content)))
    
    docket_metadata <- map_dfr(content, ~{ # left off here, need to use map to get all the attributes and join
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

    return(docket_metadata)
}

### TEST CODE - DELETE
#
#docketId <- "OMB-2023-0001"
#endpoint <- "documents"
#pages <- 1:20
#
#
#data <- get_docket4(docketId = "OMB-2023-0001", endpoint = "documents")
#
#get_comments4 <- function(lastModifiedDate = Sys.time(), 
#                          endpoint = "comments"){
#  
#  commentIds <- data$objectId}


#d <- GET("https://api.regulations.gov/v4/comments/HHS-OCR-2018-0002-5313?include=attachments&api_key=9azbQEqsdmKb7d3sb4ThbELXxMIk5CeYMhlUSd8o")
#d2 <- fromJSON(rawToChar(d$content))
