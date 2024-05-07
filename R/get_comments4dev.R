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
commentOnId = "09000064856107a5"

# keeping this here temporarily, but it is a helper function with its own script
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

# keeping this here temporarily, but it is a helper function with its own script
make_comment_dataframe <- function(metadata){
  data <- metadata$data
  meta <- metadata$meta

  data_frame <- data$attributes %>%
    as_tibble() %>%
    mutate(id = data$id,
           # type = data$type,
           # links = data$links$self, # can easily reconstruct from id
           lastpage = meta$lastPage)
  return(data_frame)
}


# the batch function
get_comments4_batch <- function(commentOnId,
                                lastModifiedDate = Sys.time()){

  path <- make_path_commentOnId(commentOnId, lastModifiedDate)

  # map GET Function over pages
  result <- purrr::map(path, GET)

  metadata <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))

  d <- map_dfr(metadata, make_comment_dataframe)

  d$commentOnId <- commentOnId

  return(d)
}


## NEXT STEP IS GRABBING THE NEXT 5K LOOPING OVER LAST MODIFIED DATE

lastModifiedDate1 <- Sys.time()%>%
  #ymd_hms() %>%
  with_tz(tzone = "America/New_York") %>%
  gsub(" ", "%20", .) %>%
  str_remove("\\..*")

# first batch
first5k <- get_comments4_batch(commentOnId, lastModifiedDate = lastModifiedDate1)


## NEXT STEP IS GRABBING THE NEXT 5K LOOPING OVER LAST MODIFIED DATE

  lastModifiedDate <<- next5k$lastModifiedDate %>%
    tail(1) %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    gsub(" ", "%20", .)


# second batch
next5k <- get_comments4_batch(commentOnId, lastModifiedDate = lastModifiedDate)

# test
anti_join(first5k, next5k)


# this should be somewhat aligned, continueing a countdown
tail(first5k$id)
head(next5k$id)

 next5k$lastpage |> unique()

d <- full_join(first5k, next5k)

# while loop
#FIXME needs better error handeling and warnings
while(lastpage == F){

  next5k <- get_comments4_batch(commentOnId, lastModifiedDate = lastModifiedDate)


  if(nrow(next5k) < 1){
    warning(paste("ended at", lastModifiedDate))
    Sys.sleep(30)
    }

  if(nrow(next5k) > 0){
  d <<- full_join(d, next5k )

  lastModifiedDate <<- d$lastModifiedDate %>%
    tail(1) %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    gsub(" ", "%20", .)

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


# loop over documents on a docket in a different function that calls the one above inside it
objectId <- get_docket4(docketId = docketId, endpoint = "documents") %>%
  #filter(complete.cases(commentEndDate, commentStartDate)) %>%
  pull(objectId) |>
  unique()

## code to pull first 10k  but major issues:
## 1) pulling duplicates because I can't maintain the object IDs
## 2) need to merge the dataframes
## 3) needs a loop that is dependent on whether the last page has been reached

#next5k <- get_comments4(docketId = "OMB-2023-0001")
#
#check <- get_comments4(docketId = "OMB-2023-0001")
#
#c <- get_docket4(docketId = "OMB-2023-0001",endpoint="documents",pages = 1:20)


