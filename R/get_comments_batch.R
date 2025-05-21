#' @keywords internal

get_comments_batch <- function(objectId = NULL, 
                               agencyId = NULL,
                               lastModifiedDate,
                               lastModifiedDate_mod = "le", #c("le", "ge", "NULL")
                               api_keys){

  api_key <- sample(api_keys, 1)

  metadata <- list()

  for (i in 1:20){

    #message(paste("Page", i))

    path <- make_path_commentOnId(objectId,
                                  agencyId,
                                  lastModifiedDate,
                                  lastModifiedDate_mod,
                                  page = i,
                                  api_key = api_key)
    
    #message("Trying: ", path |> stringr::str_replace("&api_key=.+(.{4})", "&api_key=XXX\\1"))

    # map GET function over pages
    result <- httr::GET(path)

    # report result status
    status <- result$status_code
    url <- result$url

    # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
    remaining <<- result$headers$`x-ratelimit-remaining` |> as.numeric()
    
    message(paste("|", "Trying:", ifelse(is.null(objectId), agencyId, objectId),
                  "| status:", status,
                  "| limit-remaining", remaining, "|"))
    
    if(status != 200 & status != 429){
      message(paste(Sys.time() |> format("%X"),
                    "| Status", status,
                    "| Failed URL:", path |> stringr::str_replace("&api_key=.+(.{4})", "&api_key=XXX\\1")))
      
      # small pause to give user a chance to cancel
      Sys.sleep(6)
    }
    
    # if previously failed due to rate limit, try again
    while(status == 429 ){
      
      message(paste(Sys.time() |> format("%X"),
                    "| Status", status,
                    "| Failed URL:", path |> stringr::str_replace("&api_key=.+(.{4})", "&api_key=XXX\\1")))
      
      message(paste("|", Sys.time()|> format("%X"),
                    "| Hit rate limit |",
                    remaining, "remaining | api key ending in",
                    api_key |> stringr::str_replace(".+(.{4})", "XXX\\1")))
      
      # ROTATE KEYS
      api_key <- sample(api_keys, 1)
      message(paste("Rotating to api key ending in", api_key |> stringr::str_replace(".+(.{4})", "XXX\\1")))
      
      # try again
      path <- make_path_commentOnId(objectId,
                                    agencyId,
                                    lastModifiedDate,
                                    lastModifiedDate_mod,
                                    page = i,
                                    api_key = api_key)
      result <- httr::GET(path)
      
      status <- result$status_code
      
      remaining <- result$headers$`x-ratelimit-remaining` |> as.numeric()

      message(paste("|", "Trying:", ifelse(is.null(objectId), agencyId, objectId),"again",
                    "| now:", status,
                    "| limit-remaining", remaining, "|"))
      
      # pause to reset rate limit
      if(status == 429 | remaining < 2){
        message(paste(Sys.time()|> format("%X"), "- Hit rate limit again, will continue after one minute"))
        Sys.sleep(60)
      }
    }
    
    if(status == 200){
      content <- jsonlite::fromJSON(rawToChar(result$content))
      metadata[[i]] <- content
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

