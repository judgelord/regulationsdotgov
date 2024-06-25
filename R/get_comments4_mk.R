# Function to grab metadata for the first 5,000 comments on a document

source("~/api-key.R")

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

source("R/make_path_commentOnId.R")
source("R/make_comment_dataframe.R")

# FOR TESTING
#commentOnId = "09000064856107a5" # this is https://www.regulations.gov/document/OMB-2023-0001-0001
#commentOnId = "090000648592bfcc" #https://www.regulations.gov/document/OMB-2023-0001-12471 - less pages / calls
commentOnId = "09000064824e36b7"

# the batch function
get_comments4_batch <- function(commentOnId,
                                lastModifiedDate = Sys.time()){
  
  
  # fixing lastMdifiedDate inside the function so that we do not need to do format dates for the API before providing them to the function (this also allows us to set sys.time as a default, which requires formatting as well)
  lastModifiedDate <- lastModifiedDate  %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    gsub(" ", "%20", .) %>%
    str_remove("\\..*")
  
  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_commentOnId(commentOnId, lastModifiedDate)
  
  # map GET function over pages
  result <- purrr::map(path, GET)
  
  # map the content of successful api results into a list
  metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))
  
  # print unsuccessful api calls (might be helpful to know which URLs are failing)
  
  purrr::walk2(result, path, function(response, url) {
    if (status_code(response) != 200) {
      print(paste("Failed URL:", url))
    }
  })
  
  # map the list into a dataframe with the information we care about 
  d <- map_dfr(metadata, make_comment_dataframe)
  
  # add back in the id for the document being commented on
  d$commentOnId <- commentOnId
  
  return(d)
}


n <- get_comments4_batch(commentOnId)

