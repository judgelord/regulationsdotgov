# install regulationsdotgov
devtools::load_all()
# keys saved up one directory
load("../keys.rda")

library(tidyverse)
library(httr)
library(jsonlite)
library(magrittr)

docket <- "IRS-2024-0026"
documents <- get_documents(docket, api_keys = keys)
documents |> count(documentType)

documents |> filter(documentType == "Proposed Rule") |> select(commentEndDate, withdrawn, subtype, objectId)

# subset to proposed rules
d <- documents |>
  filter(documentType == "Proposed Rule") |>
  select(objectId,  withdrawn, subtype, commentStartDate, commentEndDate, frDocNum, title) |>
  drop_na(commentStartDate)


 # get comments
 c <- map_dfr( d$objectId, get_commentsOnId, api_keys = keys)

 # join back in document metadata
 c %<>% left_join(d)


# Testing objectId vs documentId

objectId <- "090000648551e28a"
documentId <- "EPA-HQ-OAR-2021-0317-1460"

library(purrr)
library(dplyr)

c <- map_dfr(check, get_commentsOnId, api_keys = api_keys)

c <- get_commentsOnId(commentOnId, api_keys = api_keys)

c2 <- get_commentsOnId(commentOnId = documentId, api_keys = api_keys)






  #commentOnId = "09000064856107a5" # this is https://www.regulations.gov/document/OMB-2023-0001-0001
  commentOnId = "090000648592bfcc" #https://www.regulations.gov/document/OMB-2023-0001-12471 - less pages / calls
  commentOnId = "09000064824e36b7"
  commentOnId = "09000064856107a5"
  commentOnId <- "0900006484e4bd65"
  commentOnId <- "09000064855c8190"

  n <- get_commentsOnId(objectId = commentOnId, api_keys = keys)

  c <- unique(n$objectId)

  # are objectIds and documentIds any different? Yes

  #FBI_one <- get_commentsOnId(commentOnId = "09000064865d514a", api_keys = api_keys)
  #FBI_two <- get_commentsOnId(commentOnId = "FBI-2024-0001-0001", api_keys = api_keys)

