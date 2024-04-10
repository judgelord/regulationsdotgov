# This script builds a function that pulls all material related to a single docket
# source("api-key.R") 

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
docketId <- "OMB-2023-0001"
endpoint <- "comments"
pages <- 1:20

get_docket4 <- function(docketId,
                        lastModifiedDate = Sys.time(), 
                        endpoint, 
                        pages){
    
    # backwards integration with v3 functions 
    #endpoint = ifelse(documenttype %in% c("Public Submission", "comments"), "comments", "documents") 
    # do we want to build one function that can pull either comments/documents/dockets (three available endpoints) or 
    # seperate functions for each 
  
    #default settings
    url  <- "https://api.regulations.gov"
    rpp <- 25 # results per page
    sortby <- "-postedDate" # decending posted date 
    lastModifiedDate = Sys.time() %>% str_replace_all("[A-Z]", " ") %>%  str_squish()
    
    path <- paste0("/v4/",
                   endpoint, 
                   "?filter[docketId]=",docketId,
                   "&page[size]=250", 
                   "&page[number]=", pages,
                   "&api_key=", api_key)
    
    # inspect path 
    urls <- str_c("https://api.regulations.gov", path)
    
    metadata <- purrr::map(urls, ~(GET(.x)))
    
    content <- purrr::map(metadata, ~fromJSON(rawToChar(.x$content)))
    
    data_frame_list <- map(content, ~{ # left off here, need to use map to get all the attributes and join
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
    
    data <- bind_rows(data_frame_list)
    
    return(data)
}


d <- GET("https://api.regulations.gov/v4/comments/HHS-OCR-2018-0002-5313?include=attachments&api_key=9azbQEqsdmKb7d3sb4ThbELXxMIk5CeYMhlUSd8o")
d2 <- fromJSON(rawToChar(d$content))

data2 <- get_docket4(docketId = "OMB-2023-0001", pages = 1:20, endpoint = "comments")

get_comments4 <- function(lastModifiedDate = Sys.time(), 
                          endpoint = "comments"){
  
  commentIds <- data$objectId}



