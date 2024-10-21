# Function to grab metadata for the first 5,000 comments on a document



#' @keywords internal

get_comments_batch <- function(commentOnId,
                               lastModifiedDate = Sys.time(),
                               api_keys){
  
  api_key <- api_keys[1]

  lastModifiedDate <- format_date(lastModifiedDate)

  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_commentOnId(commentOnId, lastModifiedDate, api_key)
  
  metadata <- list()
  
  for (i in path){
      
    # map GET function over pages
    result <- httr::GET(i)

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
    
    ## print unsuccessful api calls (might be helpful to know which URLs are failing)
    #I don't think we need this? Repetitive? 
    #purrr::walk2(result,
    #             path,
    #             function(response, url) {
    #               if (status_code(response) != 200) {
    #                 message(paste(status_code(response),
    #                               "Failed URL:",
    #                               url)
    #                 )
    #               }
    #             }
    #)
    
    if(status == 200){
      metadata[[i]] <- jsonlite::fromJSON(rawToChar(result$content))
    }
    
    # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
    remaining <<- result$headers$`x-ratelimit-remaining` |> as.numeric()
    
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

  # map the list into a dataframe with the information we care about
  d <- purrr::map_dfr(metadata, make_dataframe)

  # add back in the id for the document being commented on
  d$commentOnId <- commentOnId

  return(d)
}

