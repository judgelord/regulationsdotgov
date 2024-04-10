# This script builds a function that pulls all docket ID's and information for specific agencies 
# source("api-key.R") 


library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)


# defaults 
url  <- "https://api.regulations.gov"
rpp <- 250 # results per page
sortby <- "-postedDate" # decending posted date 
page <- 1:20
lastModifiedDate = Sys.time() %>% str_replace_all("[A-Z]", " ") %>%  str_squish()
agency <- "CFPB"

search_agency4 <- function(page = 1, 
                           agency,
                           endpoint = "dockets"){
  
  # backwards integration with v3 functions 
  #endpoint = ifelse(documenttype %in% c("Public Submission", "comments"), "comments", "documents") 
  # do we want to build one function that can pull either comments/documents/dockets (three available endpoints) or 
  # seperate functions for each 
  
  path <- paste0("/v4/",
                 "dockets", 
                 "?filter[agencyId]=", agency,
                 "&page[size]=250", 
                 "&page[number]=", page,
                 "&sort=-lastModifiedDate",
                 "&api_key=", api_key)
  
  # inspect path 
  str_c("https://api.regulations.gov", path)
  
  raw.result <- GET(url = url, path = path)
  
  content <- fromJSON(rawToChar(raw.result$content))
  
  d <- content$data$attributes %>%  as_tibble()  %>%
    mutate(id = content$data$id,
           type = content$data$type,
           links = content$data$links$self,
           lastpage = content$meta$lastPage)
  
  return(d)
}

output <- map_dfr(.x = c(1:25),
              .f = search_agency4, agency = "OMB")




