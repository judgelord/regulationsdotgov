# Function to grab metadata for the first 5,000 comments on a document

library(httr)
library(jsonlite)
library(purrr)
library(dplyr)

#############################
# REQUIRES HELPER FUNCTIONS #
#############################
source("R/make_path_commentOnId.R")
source("R/make_dataframe.R")
source("R/format_date.R")

#get_comments_batch <- function(commentOnId,
#                               lastModifiedDate = Sys.time(),
#                               api_keys){
  
  api_key <- api_keys[1]

  lastModifiedDate <- format_date(lastModifiedDate)

  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_commentOnId(commentOnId, lastModifiedDate, api_key)

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
    Sys.sleep(6)
  }

  # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
  remaining <<-  map(result, headers) |>
    tail(1) |>
    pluck(1, "x-ratelimit-remaining") |>
    as.numeric()

  if(remaining < 2){
    
    message(paste("|", Sys.time()|> format("%X"), "| Hit rate limit, will continue after one minute |", remaining, "remaining"))
    
    # ROTATE KEYS
    api_keys <<- c(tail(api_keys, -1), head(api_keys, 1))
    api_key <- api_keys[1]
    #api_key <<- apikeys[runif(1, min=1, max=3.999) |> floor() ]
    message(paste("Rotating api key to", api_key))
    
    Sys.sleep(60)
  }

 # map the content of successful api results into a list
  metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))

  # print unsuccessful api calls (might be helpful to know which URLs are failing)

  purrr::walk2(result,
               path,
               function(response, url) {
    if (status_code(response) != 200) {
      message(paste(status_code(response),
                  "Failed URL:",
                  url)
            )
    }
  }
  )

  # map the list into a dataframe with the information we care about
  d <- map_dfr(metadata, make_dataframe)

  # add back in the id for the document being commented on
  d$commentOnId <- commentOnId

  return(d)
}
#

get_comments_batch <- function(commentOnId, # MAYA'S ATTEMPT AT REPLACING MAP WITH A WHILE LOOP, NOT WORKING 
                               lastModifiedDate = Sys.time(),
                               api_keys){
  
  api_key <- api_keys[1]
  
  lastModifiedDate <- format_date(lastModifiedDate)
  
  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_commentOnId(commentOnId, lastModifiedDate, api_key)
  
  metadata <- list()
  lastPage <- NULL
  
  for (i in seq_along(path)) {
    
    while (is.null(lastPage) || !lastPage) {
      
      result <- GET(path[i])
      
      # report result status
      status <- result$status_code
      url <- result$url
      
      if(status != 200){
        message(paste(Sys.time() |> format("%X"),
                      "| Status", status,
                      "| URL:", url))
        
        # small pause to give user a chance to cancel
        Sys.sleep(6)
      }
      
      # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
      remaining <<- result$headers$`x-ratelimit-remaining` %>% as.numeric()
      
      if(remaining < 2){
        
        message(paste("|", Sys.time()|> format("%X"), "| Hit rate limit, will continue after one minute |", remaining, "remaining"))
        
        # ROTATE KEYS
        api_keys <<- c(tail(api_keys, -1), head(api_keys, 1))
        api_key <- api_keys[1]
        #api_key <<- apikeys[runif(1, min=1, max=3.999) |> floor() ]
        message(paste("Rotating api key to", api_key))
        
        Sys.sleep(60)
      }
      
      if(status == 200){
        response_content <- fromJSON(rawToChar(result$content))
        metadata[[i]] <- response_content
        
        # Update lastPage
        lastPage <- pluck(response_content, "meta", "lastPage") 
      }
    }
  }
  
  # print unsuccessful api calls (might be helpful to know which URLs are failing)
  
  purrr::walk2(result,
               path,
               function(response, url) {
                 if (status_code(response) != 200) {
                   message(paste(status_code(response),
                                 "Failed URL:",
                                 url)
                   )
                 }
               }
  )
  
  # map the list into a dataframe with the information we care about
  d <- map_dfr(metadata, make_dataframe)
  
  # add back in the id for the document being commented on
  d$commentOnId <- commentOnId
  
  return(d)
}


#get_comments_batch <- function(commentOnId, # MAYA'S ATTEMPT AT REPLACING MAP WITH A WHILE LOOP, NOT WORKING 
#                               lastModifiedDate = Sys.time(),
#                               api_keys){
  
  api_key <- api_keys[1]
  
  lastModifiedDate <- format_date(lastModifiedDate)
  
  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_commentOnId(commentOnId, lastModifiedDate, api_key)
  
  metadata <- list()
  lastPage <- NULL
  
  for (i in seq_along(path)) {
    
    while (is.null(lastPage) || !lastPage) {
      
      result <- GET(path[i])
      
      # report result status
      status <- result$status_code
      url <- result$url
      
      if(status != 200){
        message(paste(Sys.time() |> format("%X"),
                      "| Status", status,
                      "| URL:", url))
        
        # small pause to give user a chance to cancel
        Sys.sleep(6)
      }
      
      # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
      remaining <<- result$headers$`x-ratelimit-remaining` %>% as.numeric()
      
      if(remaining < 2){
        
        message(paste("|", Sys.time()|> format("%X"), "| Hit rate limit, will continue after one minute |", remaining, "remaining"))
        
        # ROTATE KEYS
        api_keys <<- c(tail(api_keys, -1), head(api_keys, 1))
        api_key <- api_keys[1]
        #api_key <<- apikeys[runif(1, min=1, max=3.999) |> floor() ]
        message(paste("Rotating api key to", api_key))
        
        Sys.sleep(60)
      }
      
      if(status == 200){
        response_content <- fromJSON(rawToChar(result$content))
        metadata[[i]] <- response_content
        
        # Update lastPage
        lastPage <- pluck(response_content, "meta", "lastPage") 
      }
    }
  }
  
  # print unsuccessful api calls (might be helpful to know which URLs are failing)
  
  purrr::walk2(result,
               path,
               function(response, url) {
                 if (status_code(response) != 200) {
                   message(paste(status_code(response),
                                 "Failed URL:",
                                 url)
                   )
                 }
               }
  )
  
  # map the list into a dataframe with the information we care about
  d <- map_dfr(metadata, make_dataframe)
  
  # add back in the id for the document being commented on
  d$commentOnId <- commentOnId
  
  return(d)
}
#
#