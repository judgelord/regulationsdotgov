##############
# REQUIRES HELPER FUNCTIONS #
####################
library(magrittr)
library(stringr)
library(tidyverse)
library(httr)
source("R/make_path_dockets.R")
source("R/make_dataframe.R")
source("R/format_date.R")

get_dockets_batch <- function(agency, 
                        lastModifiedDate = Sys.time(), 
                        api_keys){
  
  lastModifiedDate <- format_date(lastModifiedDate) 
  
  path <- make_path_dockets(agency, lastModifiedDate)
  
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
  docket_metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))
  
  d <- map_dfr(docket_metadata, make_dataframe)
  
  
  return(d)
  
}
