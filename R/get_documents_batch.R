
#' @keywords internal

get_documents_batch <- function(agencyId = NULL,
                        docketId = NULL,
                        lastModifiedDate,
                        lastModifiedDate_mod = "le", #c("le", "ge", "NULL")
                        documentType = NULL, #c("Notice", "Rule", "Proposed Rule", "Supporting & Related Material", "Other")
                        api_keys){
  
  api_key <- sample(api_keys, 1)
  
  metadata <- list()
  
  for (i in 1:20){
    
    path <- make_path_documents(agencyId,
                                docketId,
                                lastModifiedDate,
                                lastModifiedDate_mod, 
                                documentType, 
                                page = i,
                                api_key = api_key)
    
    message("Trying:", path)

    result <- httr::GET(path)

    # report result status
    status <- result$status_code
    url <- result$url

    while(status != 200){
      message(paste(Sys.time() |> format("%X"),
                    "| Status", status,
                    "| Failed URL:", path |> stringr::str_replace("&api_key=.+(.{4})", "&api_key=XXX\\1")))

      # remake path with other key
      path <- make_path_documents(agencyId,
                                  docketId,
                                  lastModifiedDate,
                                  lastModifiedDate_mod, 
                                  documentType, 
                                  page = i,
                                  api_key = api_key)

      message("Trying again in 1 minute")

      # small pause to give user a chance to cancel
      Sys.sleep(60)

      # Try again
      result <- httr::GET(path)

    }

    if(status == 200){
      content <- jsonlite::fromJSON(rawToChar(result$content))
      metadata[[i]] <- content
    }

    # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
    remaining <<- result$headers$`x-ratelimit-remaining` |> as.numeric()

    message(paste("|", Sys.time()|> format("%X"),
                  "| Page", i,
                  "| limit-remaining", remaining, "|"))

    if(remaining < 2){

      message(paste("|", Sys.time()|> format("%X"),
                    "| Hit rate limit | Pausing |"))

      # # ROTATE KEYS
      # api_key <- sample(api_keys, 1)
      # message(paste("Rotating to api key ending in", api_key |> stringr::str_replace(".{35}", "...")))

      Sys.sleep(6)
    }

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

  return(d)
}



