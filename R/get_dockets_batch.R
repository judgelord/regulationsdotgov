

#' @keywords internal

get_dockets_batch <- function(agency,
                        lastModifiedDate,
                        api_keys){

  api_key <- api_keys[1]
  
  lastModifiedDate <- format_date(lastModifiedDate)

  path <- make_path_dockets(agency, lastModifiedDate, api_key)
  
  metadata <- list()

  for (i in path){
    
    # map GET function over pages
    result <- GET(i)

    # report result status
    status <- result$status_code
    url <- result$url
    
    if(status != 200){
      message(paste(Sys.time() |> format("%X"),
                    "| Status", status,
                    "| Failed URL:", url))

    # small pause to give user a chance to cancel
    Sys.sleep(6)
    }
    
    if(status == 200){
      metadata[[i]] <- fromJSON(rawToChar(result$content))
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
    
    if(metadata[[url]]$meta$lastPage == TRUE){break} # breaks loop when last page is reached
  }

  d <- map_dfr(docket_metadata, make_dataframe)


  return(d)

}
