# pulling first 5k comments
# I wrote this for my own use but it could be helpful in the future and its working

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

source("~/api-key.R")

#NOTRUN
if(F){
  # load saved comment metadata for testing
  load(here::here("data", "comment_metadata_09000064856107a5.rdata"))

  # to get all
  ids <- comment_metadata$id

  # for testing with 200
  ids <- comment_metadata$id[1:200]
}

# or test with just two
# the second one has an attachment
id <- c("OMB-2023-0001-15386", "OMB-2023-0001-14801")




##############
# HELPER FUNCTIONS #
####################

# keeping this here temporarily, but moved to separate script
make_path <- function(id, api_key = api_key){
  path = paste0("https://api.regulations.gov/v4/comments/",
       id,
       "?",
       "include=attachments&",
       "api_key=", api_key)
  return(path)
}

# the helper that does the work for each comment
# keeping just the content, not the full results, in memory while the main loop runs
get_commentdetails4_content <- function(id,
                                lastModifiedDate = Sys.time(),
                                delay_seconds = 3) {

  message(paste(Sys.time()|> format("%X") , ":", id))

  path <- make_path(id, api_key)

  result <- GET(path)

  content <-  fromJSON(rawToChar(result$content))

  Sys.sleep(delay_seconds)

  return(content)
}


#FIXME we need better error handling, for now using possibly(..., otherwise = content_init)
# a default for possibly to return if the call fails
path <- make_path(id[1], api_key)
result_init <- GET(path)
content_init <- fromJSON(rawToChar(result_init$content))


# main function for this script to loop over a vector of comments
get_commentdetails4 <- function(id,
                                lastModifiedDate = Sys.time(),
                                delay_seconds = 3) {

  content <- purrr::map(id,
                        possibly(get_commentdetails4_content,
                                 otherwise = content_init)
  )

  # note that document call return attachment file names in attributes, but comments are in included
  metadata <- purrr::map_dfr(content, ~.x$data$attributes)

  # add id back in (we could just use the ids supplied to the function,  but the API returns more than one row for a single supplied document ID (at least for documents other than comments, it seems). I am hoping that by extracting it back out of the result, we get a vector of the correct length)
  id <- purrr::map_chr(content, ~.x$data$id)

  metadata$id <- id

  #extract attachment file urls from included$attributes
  attachments <- purrr::map_dfr(content, ~.x$included$attributes$fileFormats)

  # if some comments have attachments, then extract ids from the urls and nest all file url into one list per comment id
  if(nrow(attachments) > 0){
    attachments <- attachments |>
      mutate(id = str_remove_all(fileUrl, ".*gov/|/attach.*")) |>
      select(id, fileUrl) |>
      nest(.by = "id", .key = "attachments")

    # join in the attachment lists by id
    # comments with no attachments will be null
    metadata <- left_join(metadata, attachments, by = "id")
  }

  return(metadata)
}




################
# TESTING #####
###############

# for a notice (the API appears to return the same document details with /comments/ instead of /documents/ in the path)
# however, it does not return the same included list
document_details1 <- get_commentdetails4(id = "OMB-2023-0001-12471")

######################################
# for comments on that notice

# one comment
comment_details1 <- get_commentdetails4(id = c("OMB-2023-0001-18154"))


# one comment
comment_details2 <- get_commentdetails4(id = c("OMB-2023-0001-15386",
                                                      "OMB-2023-0001-14801"))

# a vector
ids <- setdiff(ids, comment_details$id)
comment_details <- get_commentdetails4(id = ids)#[1:1000])
d <- comment_details

if(F){
  load(here::here("data", "comment_details.rdata"))
  comment_details %<>% full_join(d)
  save(comment_deatils, file = here::here("data", "comment_details.rdata"))
}
comment_details %<>% distinct()

# comments with no attachments are dropped by unnest
comments_with_attachments <- comment_details |> unnest(attachments)
