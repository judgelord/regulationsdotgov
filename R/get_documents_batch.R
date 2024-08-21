library(httr)
library(jsonlite)
library(purrr)
library(dplyr)

#############################
# REQUIRES HELPER FUNCTIONS #
#############################
source("R/helper_functions/make_path_documents.R")
source("R/helper_functions/make_dataframe.R")
source("R/helper_functions/format_date.R")

get_documents_batch <- function(docketId, 
                                lastModifiedDate = Sys.time(), 
                                api_keys = api_keys){
  
  lastModifiedDate <- format_date(lastModifiedDate) 
  
  path <- make_path_documents(docketId, lastModifiedDate)
  
  # map GET function over pages
  result <- purrr::map(path, GET)
  
  # report result status
  status <<- map(result, status_code) |> tail(1) %>% as.numeric()
  
  url <- result[[20]][1]$url
  
  if(status != 200){
    message(paste(Sys.time() |> format("%X"),
                  "| Status", status,
                  "| URL:", url))
    
    # small pause to give user a chance to cancel
    Sys.sleep(6)
  }
  
  # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
  remaining <<-  map(result, headers) |>
    tail(1) |>
    pluck(1, "x-ratelimit-remaining")
  
  if(remaining < 2){
    
    message(paste(Sys.time()|> format("%X"), "- Hit rate limit, will continue after one minute"))
    
    Sys.sleep(60)
  }
  
  
  # map the content of successful api results into a list
  document_metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))
  
  d <- map_dfr(document_metadata, make_dataframe)
  
  
  return(d)
  
}

docketId <- "USPC-2021-0005"

d <- GET("https://api.regulations.gov/v4/documents?filter[docketId]=USPC-2021-0005&filter[lastModifiedDate][le]=2024-08-15%2019:00:30&page[size]=250&page[number]=1&sort=-lastModifiedDate,documentId&api_key=9azbQEqsdmKb7d3sb4ThbELXxMIk5CeYMhlUSd8o")
