################
# TESTING #####
# install regulationsdotgov
devtools::load_all()
# keys saved up one directory
load("../keys.rda")

library(tidyverse)
library(httr)
library(jsonlite)
library(magrittr)

if(F){
  get_comment_details_content(id = "CEQ-2019-0003-197917", api_keys = api_keys)
}

comment_details <- get_comment_details(id = "EPA-HQ-OA-2004-0002-0001")

  # load saved comment metadata for testing
  #load(here::here("data", "comment_metadata_09000064856107a5.rdata"))
load(here::here("data",
                "search",
                "environmental justice",
                "environmental justices_comments.rda"))

comment_metadata <- d

  # to get all
  ids <- comment_metadata$id

  # for testing with 200
  ids <- comment_metadata$id#[1:200]


  # for a notice (the API appears to return the same document details with /comments/ instead of /documents/ in the path)
  # however, it does not return the same included list
  document_details1 <- get_comment_details(id = "OMB-2023-0001-12471")


  ######################################
  # for comments on that notice

  # one comment
  comment_details1 <- get_comment_details(id = c("OMB-2023-0001-18154"))


  # one comment
  comment_details2 <- get_comment_details(id = c("OMB-2023-0001-15386",
                                                 "OMB-2023-0001-14801"))


  comment_details$attachments  |> unnest(cols = c(fileUrl, format, size))
  comment_details$attachments  |> unnest(cols = c(fileUrl, format, size))


  ############### FOR DEVIN'S DATA ####################
  load(here::here("data", "comments_coded_details.rdata"))
  if(updating){
    d <- comments_coded_details
  }

  # a vector
  ids <- comments_coded$document_id
  # remove ones we already have
  ids <- setdiff(ids, d$id) |> unique()

  comments_coded_details_temp <- get_comment_details(id = ids)#[1:1000])

  # add new ones to ones we already had
  d %<>% full_join(comments_coded_details_temp) %>% distinct()
  #d <- comment_details


    comments_coded_details <- d

    save(comments_coded_details, file = here::here("data", "comments_coded_details.rdata"))

  # comments with no attachments are dropped by unnest
  details %>% mutate(attachments = flatten(attachments))

  attachments <- details$attachments

  setdiff(attachments[[1]]$fileUrl, attachments$fileUrl)

  details %<>% mutate(alength = lengths(attachments))

  details$alength %>% unique()

  comment_attachments <- details |> filter(alength > 0) |> pull(attachments) |> map(as.list)  #map(class)

  head(comment_attachments) |> flatten()
  to_download <- comment_attachments  |> flatten() |> flatten() |> flatten() |> as.character()
  tail(to_download)

  to_download <- to_download[str_detect(to_download, "http")] |> unique()

map_dfr(comment_attachments, ~.x)


  comment_attachments |> map_chr(~.x)





  # THIS IS ALL YOU SHYOULD NEED GOING FORWARD
  comments_with_attachments <- details |> unnest(attachments) %>% distinct()

  to_download <- comments_with_attachments$fileUrl


  d <- get_comment_details(toget)

  details %<>% full_join(d)
  comments_coded_details2 %<>% full_join(d)

  comments_coded_details <- comments_coded_details2

  toget <- setdiff(comments_coded$document_id, comments_coded_details2$id)



  ids <- comments_coded$document_id |> unique()

  comments_coded_details <- get_comment_details(ids)
  ##################



  if(F){
    d < - get_commentsOnId(id = "", api_keys = api_keys)

    # not to self: what I really need is the biden era comments
    details5k <- get_comment_details(id = d$id[1:5000],
                                     api_keys = keys)
    details10k <- get_comment_details(id = d$id[5000:10000],
                                      api_keys = api_keys)
    details15k <- get_comment_details(id = d$id[10000:15000],
                                      api_keys = api_keys)
    details20k <- get_comment_details(id = d$id[15000:20000],
                                      api_keys = api_keys)

    details <- full_join(details5k, details10k) |> full_join(details15k) | full_join(details20k)

    save(details, file = here::here("data", "details_temp.rda"))
  }
