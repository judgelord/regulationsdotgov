# pulling first 5k comments
# I wrote this for my own use but it could be helpful in the future and its working

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

#NOTRUN
if(F){
commentIds <- d$id[1:2]

# the second one has an attachment
commentIds <- c("OMB-2023-0001-15386", "OMB-2023-0001-14801")

commentId <- commentIds
}


# keeping this here temporarily, but moved to separate script
fetch_with_delay <- function(path, delay_seconds = 3.6) {
  Sys.sleep(delay_seconds)
  GET(path)
}

# keeping this here temporarily, but moved to separate script
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

  content <- purrr::map(result, ~fromJSON(rawToChar(.x$content)))

  # note that document call return attachment file names in attributes, but comments are in included
  metadata <- purrr::map_dfr(content, ~.x$data$attributes)

  # add id back in (we could just use the ids supplied to the function,  but the API returns more than one result for a single supplied ID. I am hoping that by extracting it back out of the result, we get a vector of the correct length)
  id <- purrr::map_chr(content, ~.x$data$id)
  metadata$id <- id


  #TODO, since comment attachment ids/urls are in the included list, we need to merge this in. However, it contains nothing to merge on. Thus, we may need to do this one comment at a time, rather than having this function process many commmens
  if(F){
    included <- purrr::map_dfr(content, ~.x$included)

    included$id
    included$type
    included$links
    included$attributes
    included$attributes$fileFormats |> paste()

    # relationships
    relationships <- purrr::map_dfr(content, ~.x$data$relationships)

    attachment_id <- relationships$attachments[[3]]$id

    links <- relationships$attachments$links$self
  }

  #TODO this works, but only if some results contain attachments; otherwise, it breaks
  attachments <- purrr::map_dfr(content, ~.x$included$attributes$fileFormats)

  if(nrow(attachments) > 0){
    attachments <- attachments |>
      mutate(id = str_remove_all(fileUrl, ".*gov/|/attach.*")) |>
      select(id, fileUrl) |>
      nest(.by = "id", .key = "attachments")

    metadata <- left_join(metadata, attachments)
  }



  return(metadata)
}


# for a notice (the API appears to return the same document details with /comments/ instead of /documents/ in the path)
# however, it does not return the same included list
document_details1 <- get_commentdetails4(commentId = "OMB-2023-0001-12471")

# for comments on that notice

# one comment
comment_details1 <- get_commentdetails4(commentId = "OMB-2023-0001-18154")

# a vector
comment_details2 <- get_commentdetails4(commentId = commentIds)
