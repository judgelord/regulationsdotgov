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

  if(length(id) != length(id |> unique()) ){
    message("Duplicate ids dropped to save API calls (result will be shorter than length of id vector)")
  }


  content <- purrr::map(id |> unique(),
                        possibly(get_comment_details_content,
                                 otherwise = content_init) # FIXME replace with NULL, and then drop NULLs before next step? We might also be able to try the failed ones again.
  )
  # save(content, file = "data/content_temp2.rdata")


  # nulls are 404 errors on comment ids
  nulls <- purrr::map(content, ~.x$data$id) |> map_lgl(is.null )

  message(paste("404 error:", paste(id[nulls], collapse = ",")))

  # drop null
  content <- content[!nulls]



  # note that document call return attachment file names in attributes, but comments are in included
  metadata <- purrr::map_dfr(content, ~.x |> pluck("data", "attributes")) |> # purrr::map_dfr(content, ~.x$data$attributes) |>
    select(-starts_with("display")) |>
    distinct()

  #FIXME ISSUE #6
  # add id back in (we could just use the ids supplied to the function,  but the API returns more than one row for a single supplied document ID (at least for documents other than comments, it seems). I am hoping that by extracting it back out of the result, we get a vector of the correct length)
  #ids1 <- map(content, ~.x |> pluck("data", "id")) |>
  # FIXME? hopefully by discarding nulls, we get the same length as metadata....no this did not seem to work...
  #discard(is.null) |>
  #as.character()

  # NONE OF THIS WORKED, BUT I WORRY ABOUT THE ABOVE
  # IDEALLY WE WOULD USE THE SAME METHOD FOR BOTH
  #metadata1 <- purrr::map(content, ~.x |> pluck("data", "attributes")) |>
    #modify(~ifelse(is.null(.x), NA, .x)) |>
    #map_dfr(~.x)
    #list_rbind()
    #map(flatten) |>
    #purrr::map_depth(1, ~ifelse(is.null(.x), NA, .x) ) |>
    #map_dfr(~ .x)

  # ids <- modify(content, ~ifelse(is.null(.x), NA, .x) ) %>% .[[4872]]  #map_chr(content, ~.x$data$id)

  # ids <- purrr::map(content, ~.x$data$id) |> as.character()
  ids <- map_chr(content, ~.x |> pluck("data", "id"))

  metadata$id <- ids # |> unique()

  #extract attachment file urls from included$attributes
  # attachments <- purrr::map_dfr(content, ~.x$included$attributes$fileFormats)
  attachments <- purrr::map(content, ~.x |> pluck("included", "attributes", "fileFormats"))

  metadata$attachments <- attachments #|> unique()

  # NO LONGER NEED THIS NOW THAT WE ARE USING PLUCK
  # # if some comments have attachments, then extract ids from the urls and nest all file url into one list per comment id
  # if(nrow(attachments) > 0){
  #   attachments_with_urls <- attachments |>
  #     mutate(id = str_remove_all(fileUrl, ".*gov/|/attach.*")) |>
  #     distinct(id, fileUrl) |>
  #     nest(.by = "id", .key = "attachments")
  #
  #   # join in the attachment lists by id
  #   # comments with no attachments will be null
  #   metadata <- left_join(metadata, attachments_with_urls, by = "id")
  # }

  return(metadata)
}

