# Function to grab metadata for the first 5,000 comments on a document
#' @keywords internal

# the batch function
get_searchTerm_batch <- function(searchTerm,
                                 documents,
                                 # docket, #TODO feature to search comments on a specific docket or document
                                 #commentOnId, #TODO feature to search comments on a specific docket or document
                                 lastModifiedDate,
                                 api_keys){

  api_key <- sample(api_keys, 1)

  i <- 1
  metadata <- list()

  message(paste0(documents,' containing "', searchTerm,
                 '" posted before ',lastModifiedDate)
          )

  for (i in 1:20){

    message(paste("Page", i))

    path <- make_path_searchTerm(searchTerm,
                               documents,
                               lastModifiedDate,
                               page = i,
                               api_key)


    result <- httr::GET(path)

    # report result status
    status <- result$status_code
    url <- result$url

   #FIXME TRY FAILED ATTEMPTS AGAIN


  if(status == 200){
      content <- jsonlite::fromJSON(rawToChar(result$content))
      metadata[[i]] <- content
  }
    else {
    # message with error codes if not successful
      message(paste(Sys.time() |> format("%X"),
                    "| Status", status,
                    "| Failed URL:", url
                    #,"Prior codes:", paste(status_codes, collapse = ",")
                    #TODO add back in prior codes
      ))

      # small pause to give user a chance to cancel
      Sys.sleep(6)
    }

    # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
    remaining <<- result$headers$`x-ratelimit-remaining` |> as.numeric()

    if(remaining < 20){

      message(paste("|", Sys.time()|> format("%X"),
                    "| Hit rate limit |",
                    remaining, "remaining | api key ending in",
                    api_key |> stringr::str_replace(".{35}", "...")))

      # ROTATE KEYS
      api_key <- sample(api_keys, 1)
      message(paste("Rotating to api key ending in", api_key |> stringr::str_replace(".{35}", "...")))

      Sys.sleep(.60)
    }


    content$meta$lastPage

    if(!is.null(content$meta$lastPage)){
      if(content$meta$lastPage == TRUE){break} # breaks loop when last page is reached
    }
  }

  # map the list into a dataframe with the information we care about
  d <- purrr::map_dfr(metadata, make_dataframe)

  # if there was none, make an empty dataframe
  if(nrow(d)==0){
    d <- tibble(lastpage = TRUE)
  }

  # add back in the search term
  d$searchTerm <- searchTerm

  return(d)
}

# FOR TESTING
if(F){

  get_searchTerm_batch(searchTerm,
                       documents,
                       api_keys = api_keys)

}
