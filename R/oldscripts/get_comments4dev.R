# This script builds a function that pulls all comments related to a docket
# This function uses the get_docket4 function

# just pulls the metadata, no detail about individual comments

source("~/api-key.R")

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)


# FOR TESTING
commentOnId = "09000064856107a5" # this is https://www.regulations.gov/document/OMB-2023-0001-0001

# keeping this here temporarily, but it is a helper function that needs to be in its own script
make_path_commentOnId <- function(commentOnId, lastModifiedDate = Sys.time()){
  paste0("https://api.regulations.gov",
         "/v4/",
         "comments",
         "?",
         "filter[commentOnId]=", commentOnId, "&",
         "filter[lastModifiedDate][le]=", lastModifiedDate, "&", #less than or equal to (vs [ge] in the api docs)
         "page[size]=250", "&",
         "page[number]=", 1:20, "&", #FIXME replace with 2 with 20 when done testing
         "sort=-lastModifiedDate,documentId", "&",
         "api_key=", api_key)
}

# test
make_path_commentOnId(commentOnId )

# keeping this here temporarily, but it is a helper function that needs to be in its own script. It could use a better name
make_comment_dataframe <- function(metadata){
  data <- metadata$data
  meta <- metadata$meta

  data_frame <- data$attributes %>%
    as_tibble() %>%
    mutate(id = data$id,
           # type = data$type, # we already ahve documentType = Public Submission, so this adds no new info
           # links = data$links$self, # can easily reconstruct from id
           lastpage = meta$lastPage)
  return(data_frame)
}


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

  # map the content of there api results into a list
  metadata <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))

  # mape the list into a dataframe with the information we care about (defined in the make_comment_dataframe function)
  d <- map_dfr(metadata, make_comment_dataframe)

  # add back in the id for the document being commmented on
  d$commentOnId <- commentOnId

  return(d)
}


# first batch, using sys.time default to start collecting the most recent comments and going back
first5k <- get_comments4_batch(commentOnId)


## NEXT STEP IS GRABBING THE NEXT 5K LOOPING OVER LAST MODIFIED DATE


#TEST IT OUT (WE CAN DELETE THIS WHEN WE ARE DONE WITH THE LOOP)
lastModifiedDate <<- tail(first5k$lastModifiedDate, 1)

# second batch
next5k <- get_comments4_batch(commentOnId, lastModifiedDate = lastModifiedDate)

# test for overlap
anti_join(first5k, next5k)


# this should be somewhat aligned, continueing a countdown
tail(first5k$id)
head(next5k$id)

 next5k$lastpage |> unique()

d <- full_join(first5k, next5k)

###################################
# while loop
#FIXME needs better error handling and warnings

# as long as the results say it is not the last page, keep collecting another 5k
while(lastpage == F){

  # single arrows inside the function mean that this object will not be altered in the broader environment
  next5k <- get_comments4_batch(commentOnId, lastModifiedDate = lastModifiedDate)


  # basic error catch. Probably should use tryCatch
  if(nrow(next5k) < 1){
    warning(paste("ended at", lastModifiedDate))
    Sys.sleep(30)
    }

  # if their are results, merge them in
  if(nrow(next5k) > 0){

  # double arrow ("<<-") modeifies object beyond the loop, so d will keep growing as the loop continues
  d <<- full_join(d, next5k )

  # double arrow updates last modified date so that it can be used at the top of the next run
  lastModifiedDate <<- d$lastModifiedDate %>%
    tail(1) %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    gsub(" ", "%20", .)

  # double arrow updates the last page indicator to tell the while loop to keep going or to stop
  lastpage <<- d$lastpage |> unique()
  }
}

# save rdata
comment_metadata <- d
save(comment_metadata,
     file = here::here(
       "data", paste0("comment_metadata_", commentOnId, ".rdata")
       )
     )


###################
# NEXT STEP
# Make a higher-level function that will loop over all documents in a docket, applying the above to each document and returing all of the comments on that docket

get_comments_docket <- function(docketId){
  #TODO

  # loop over documents on a docket in a different function that calls the one above inside it
  objectId <- get_docket4(docketId = docketId, endpoint = "documents") %>%
    #filter(complete.cases(commentEndDate, commentStartDate)) %>%
    pull(objectId) |>
    unique()
}


## code to pull first 10k  but major issues:
## 1) pulling duplicates because I can't maintain the object IDs
## 2) need to merge the dataframes
## 3) needs a loop that is dependent on whether the last page has been reached

#next5k <- get_comments4(docketId = "OMB-2023-0001")
#
#check <- get_comments4(docketId = "OMB-2023-0001")
#
#c <- get_docket4(docketId = "OMB-2023-0001",endpoint="documents",pages = 1:20)


