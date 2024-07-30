# Function to grab metadata for the first 5,000 comments on a document

#source("~/api-key.R")

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr) # FIXME lets make this not a dependency
library(lubridate)

source("R/make_path_commentOnId.R")
source("R/make_dataframe.R")

# FOR TESTING
if(F){
#commentOnId = "09000064856107a5" # this is https://www.regulations.gov/document/OMB-2023-0001-0001
commentOnId = "090000648592bfcc" #https://www.regulations.gov/document/OMB-2023-0001-12471 - less pages / calls
# commentOnId = "09000064824e36b7"
}

# the batch function
get_comments_batch <- function(commentOnId,
                                lastModifiedDate = Sys.time(),
                               api_keys){


  # fixing lastMdifiedDate inside the function so that we do not need to do format dates for the API before providing them to the function (this also allows us to set sys.time as a default, which requires formatting as well)
  lastModifiedDate <- lastModifiedDate  %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    # replace spaces with unicode
    gsub(" ", "%20", .) %>%
    str_remove("\\..*")

  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_commentOnId(commentOnId, lastModifiedDate)

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

  if(remaining == 0){

    message(paste(Sys.time()|> format("%X"), "- Hit rate limit, will continue after one minute"))

    Sys.sleep(60)
  }


 # map the content of successful api results into a list
  metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))

  # print unsuccessful api calls (might be helpful to know which URLs are failing)

  purrr::walk2(result,
               path,
               function(response, url) {
    if (status_code(response) != 200) {
      message(paste(status_code(response),
                  "Failed URL:",
                  url)
            )
    }
  }
  )

  # map the list into a dataframe with the information we care about
  d <- map_dfr(metadata, make_dataframe)

  # add back in the id for the document being commented on
  d$commentOnId <- commentOnId

  return(d)
}


# TESTING
if(F){
n <- get_comments4_batch(commentOnId)
}

