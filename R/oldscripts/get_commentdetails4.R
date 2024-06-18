# pulling first 5k comments
# I wrote this for my own use but it could be helpful in the future and its working

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

source("~/api-key.R")

#NOTRUN
if(F){
  load(here::here("data", "comment_metadata_09000064856107a5.rdata"))
commentIds <- comment_metadata$id[1:200]
}
# the second one has an attachment
commentIds <- c("OMB-2023-0001-15386", "OMB-2023-0001-14801")

commentId <- commentIds



# keeping this here temporarily, but moved to separate script
fetch_with_delay <- function(path, delay_seconds = 3) {
  Sys.sleep(delay_seconds)
  message(paste(Sys.time()|> format("%X") , ":",
                path |> str_remove_all(".*/|\\?.*")
                ))

  result <- GET(path)
  return(result)
}

# keeping this here temporarily, but moved to separate script
make_path <- function(id, api_key = api_key){
  path = paste0("https://api.regulations.gov/v4/comments/",
       id,
       "?",
       "include=attachments&",
       "api_key=", api_key)
  return(path)
}


# a default for possibly to return if the call fails
path = make_path(commentId[1], api_key)
result_init <- GET(path)
content_init <- fromJSON(rawToChar(result_init$content))


# main function for this script
get_commentdetails4 <- function(commentId,
                                lastModifiedDate = Sys.time(),
                                pages,
                                delay_seconds = 3.6) {

  path <- map_chr(commentId, make_path, api_key = api_key)


  #result <- purrr::map(path, ~slowly(fetch_with_delay, rate = rate_delay(delay_seconds))(.x)) # Devin's note: this seems to delay twice, once inside the fetch_with_delay function and again in `slowly`
  result <- purrr::map(path,
                       possibly(
                         fetch_with_delay,# delay_seconds = 3.6,
                         otherwise = result_init) # Devin's note: this seems gets the same result without `slowly`
  )

  content <- purrr::map(result,
                        possibly(
                          ~fromJSON(rawToChar(.x$content)),
                                 otherwise = content_init)
                        )

  # note that document call return attachment file names in attributes, but comments are in included
  metadata <- purrr::map_dfr(content, ~.x$data$attributes)

  # add id back in (we could just use the ids supplied to the function,  but the API returns more than one row for a single supplied document ID (at least for documents other than comments, it seems). I am hoping that by extracting it back out of the result, we get a vector of the correct length)
  id <- purrr::map_chr(content, ~.x$data$id)
  metadata$id <- id

  #this works, but might not be the best solution

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
    metadata <- left_join(metadata, attachments)
  }

  return(metadata)
}




################
# TESTING #####
###############

# for a notice (the API appears to return the same document details with /comments/ instead of /documents/ in the path)
# however, it does not return the same included list
document_details1 <- get_commentdetails4(commentId = "OMB-2023-0001-12471")

######################################
# for comments on that notice

# one comment
comment_details1 <- get_commentdetails4(commentId = c("OMB-2023-0001-18154"))


# one comment
comment_details2 <- get_commentdetails4(commentId = c("OMB-2023-0001-15386",
                                                      "OMB-2023-0001-14801"))

# a vector
commentIds <- setdiff(commentIds, comment_details)
comment_details <- get_commentdetails4(commentId = commentIds)#[1:1000])

save(comment_deatils, file = here::here("data", "comment_details.rdata"))

comment_deatils %<>% distinct()

comments_with_attachments <- comment_details |> unnest(attachments)
