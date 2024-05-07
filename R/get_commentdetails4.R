# pulling first 5k comments
# I wrote this for my own use but it could be helpful in the future and its working

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

commentIds <- d$id[1:2]

commentIds <- c("OMB-2023-0001-15386", "OMB-2023-0001-15399")

commentId <- commentids


# keeping this here temporarily, but moved to seperate script
fetch_with_delay <- function(path, delay_seconds = 3.6) {
  Sys.sleep(delay_seconds)
  GET(path)
}

# keeping this here temporarily, but moved to seperate script
make_path <- function(id, api_key){
  path = paste0("https://api.regulations.gov/v4/comments/",
       id,
       "?",
       "include=attachments&",
       "api_key=", api_key)
  return(path)
}


# main function for this script
get_commentdetails4 <- function(commentId,
                                lastModifiedDate = Sys.time(),
                                pages,
                                delay_seconds = 3.6) {

  path <- map_chr(commentId, make_path, api_key = api_key)

  result <- purrr::map(path, ~slowly(fetch_with_delay, rate = rate_delay(delay_seconds))(.x)) # Devin's note: this seems to delay twice, once inside the fetch_with_delay function and again in `slowly`

  metadata <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))

  first5k <- purrr::map_dfr(metadata, ~.x$data$attributes)

  #oddly, the api does not include the original called document/comment id, so we need to add it back in

  # flatten(document_details)

  first5k$id <- commentId

  return(first5k)
}

document_details1 <- get_commentdetails4(commentId = "OMB-2023-0001-12471")

comment_details1 <- get_commentdetails4(commentId = "OMB-2023-0001-18154")
comment_details2 <- get_commentdetails4(commentId = commentId)
