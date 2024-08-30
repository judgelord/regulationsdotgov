library(httr)
library(jsonlite)
library(purrr)
library(dplyr)

#############################
# REQUIRES HELPER FUNCTIONS #
#############################
source("R/make_path_documents.R")
source("R/make_dataframe.R")
source("R/format_date.R")

get_documents_batch <- function(docketId,
                                lastModifiedDate, api_keys){

  api_key <- api_keys[1]
  
  lastModifiedDate <- format_date(lastModifiedDate)

  path <- make_path_documents(docketId, lastModifiedDate, api_key)

  # map GET function over pages
  result <- purrr::map(path, GET)

  # report result status
  status <<- map(result, status_code) |> tail(1) %>% as.numeric()

  url <- result[[20]][1]$url

  if(status != 200){
    message(paste(Sys.time() |> format("%X"),
                  "| Status", status,
                  "| URL:", url))

    # small pause to give user a chance to cancel
    Sys.sleep(3)
  }

  # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
  remaining <<-  map(result, headers) |>
    tail(1) |>
    pluck(1, "x-ratelimit-remaining") |>
    as.numeric()

  if(remaining < 2){

    message(paste("|", Sys.time()|> format("%X"), "| Hit rate limit, will continue after one minute |", remaining, "remaining"))

    # ROTATE KEYS
    keys <<- c(tail(keys, -1), head(keys, 1))
    api_key <- keys[1]
    #api_key <<- apikeys[runif(1, min=1, max=3.999) |> floor() ]
    message(paste("Rotating api key to", api_key))

    Sys.sleep(60)
  }


  # map the content of successful api results into a list
  document_metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))

  metadata <- map_dfr(document_metadata, make_dataframe)


  return(metadata)

}



