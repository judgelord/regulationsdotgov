#' @keywords internal

get_comments_batch <- function(objectId,
                               lastModifiedDate = Sys.time(),
                               api_keys){

  api_key <- api_keys[1]

  # call the make path function to make paths for the first 20 pages of 250 results each
  metadata <- list()

  for (i in 1:20){

    message(paste("Page", i))

    path <- make_path_commentOnId(objectId,
                                  lastModifiedDate,
                                  page = i,
                                  api_key)

    # map GET function over pages
    result <- httr::GET(path)

    # report result status
    status <- result$status_code
    url <- result$url

    while(status != 200){
      message(paste(Sys.time() |> format("%X"),
                    "| Status", status,
                    "| Failed URL:", url))

      # small pause to give user a chance to cancel
      Sys.sleep(60)

      result <- httr::GET(path)

    }

    if(status == 200){
      content <- jsonlite::fromJSON(rawToChar(result$content))
      metadata[[i]] <- content
    }

    # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
    remaining <<- result$headers$`x-ratelimit-remaining` |> as.numeric()
    
    if(remaining < 2){

      message(paste("|", Sys.time()|> format("%X"), "| Hit rate limit |", remaining, "remaining"))

      # ROTATE KEYS
      api_keys <<- c(tail(api_keys, -1), head(api_keys, 1))
      api_keys <- c(tail(api_keys, -1), head(api_keys, 1))
      api_key <- api_keys[1]
      #api_key <<- apikeys[runif(1, min=1, max=3.999) |> floor() ]
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
    d <- dplyr::tibble(lastpage = TRUE)
  }

  # add back in the id for the document being commented on
  d$objectId <- objectId

  return(d)
}

