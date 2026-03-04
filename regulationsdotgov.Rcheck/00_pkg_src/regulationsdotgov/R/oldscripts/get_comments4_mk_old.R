
## trying to incorporate a while loop for last page - I might have lost the plot 

source("~/api-key.R")

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

source("R/fetch_with_delay.R")
source("R/make_path_commentOnId.R")
source("R/make_comment_dataframe.R")
source("R/make_call.R")

# FOR TESTING
#commentOnId = "09000064856107a5" # this is https://www.regulations.gov/document/OMB-2023-0001-0001
#commentOnId = "090000648592bfcc" #https://www.regulations.gov/document/OMB-2023-0001-12471 - less pages / calls
commentOnId = "09000064824e36b7"

get_comments4_batch <- function(commentOnId,
                                lastModifiedDate = Sys.time()){
  
  d <- list()
  lastpage <- FALSE
  
  # fixing lastMdifiedDate inside the function so that we do not need to do format dates for the API before providing them to the function (this also allows us to set sys.time as a default, which requires formatting as well)
  lastModifiedDate <- lastModifiedDate  %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    gsub(" ", "%20", .) %>%
    str_remove("\\..*")
  
  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_commentOnId(commentOnId, lastModifiedDate)
  
    for (url in path){
    
      df <- make_call(url)
    
    if (!is.null(df)) {
      d <- append(d, list(df))
    }
      
      lastpage <- tail(d$lastpage)
  } 
  
  combined_df <- bind_rows(d)
 
  combined_df$commentOnId <- commentOnId
  
  return(combined_df)
}



n <- get_comments4_batch(commentOnId)




