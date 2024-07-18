# pulling first 5k comments
# I wrote this for my own use but it could be helpful in the future and its working

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)

source("~/api-key.R")

##############
# REQUIRES HELPER FUNCTIONS #
####################
source("R/make_path_comment_details.R")
source("R/get_comment_details_content.R")


# loop over a vector of comment ids, return a dataframe of comment details
get_comment_details <- function(id,
                                lastModifiedDate = Sys.time(),
                                delay_seconds = 60) {

  #FIXME we need better error handling, for now using possibly(..., otherwise = content_init)
  # a default for possibly to return if the call fails
  path <- make_path_comment_details(id[1], api_key)
  result_init <- GET(path)
  content_init <- fromJSON(rawToChar(result_init$content))


  content <- purrr::map(id,
                        possibly(get_comment_details_content,
                                 otherwise = content_init) # FIXME replace with NULL, and then drop NULLs before next step? We might also be able to try the failed ones again.
  )

  # note that document call return attachment file names in attributes, but comments are in included
  metadata <- purrr::map_dfr(content, ~.x$data$attributes)

  # add id back in (we could just use the ids supplied to the function,  but the API returns more than one row for a single supplied document ID (at least for documents other than comments, it seems). I am hoping that by extracting it back out of the result, we get a vector of the correct length)
  ids <- map(content, ~.x |> pluck("data", "id")) |>
    discard(is.null) |>  # FIXME? hopefully by discarding nulls, we get the same length as metadata
    as.character()

  metadata$id <- ids

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

#NOTRUN
if(F){
  details <- get_comment_details(comments_coded$document_id)
  save(details, file = "data/comments_coded_details.rda")

  # load saved comment metadata for testing
  load(here::here("data", "comment_metadata_09000064856107a5.rdata"))

  # to get all
  ids <- comment_metadata$id

  # for testing with 200
  ids <- comment_metadata$id[1:200]


# or test with just two
# the second one has an attachment
id <- c("OMB-2023-0001-15386", "OMB-2023-0001-14801")
}


if(F){

# for a notice (the API appears to return the same document details with /comments/ instead of /documents/ in the path)
# however, it does not return the same included list
document_details1 <- get_comment_details(id = "OMB-2023-0001-12471")


######################################
# for comments on that notice

# one comment
comment_details1 <- get_commentdetails4(id = c("OMB-2023-0001-18154"))


# one comment
comment_details2 <- get_commentdetails4(id = c("OMB-2023-0001-15386",
                                                      "OMB-2023-0001-14801"))

# a vector
ids <- comments_coded$document_id
# remove ones we already have
ids <- setdiff(ids, d$id)

comment_details <- get_comment_details(id = ids)#[1:1000])

# add new ones to ones we already had
d %<>% full_join(comment_details)
#d <- comment_details

if(F){
  load(here::here("data", "comment_details.rdata"))
  comment_details %<>% full_join(d)
  save(comment_deatils, file = here::here("data", "comment_details.rdata"))
}
comment_details %<>% distinct()

# comments with no attachments are dropped by unnest
comments_with_attachments <- comment_details |> unnest(attachments)

}
