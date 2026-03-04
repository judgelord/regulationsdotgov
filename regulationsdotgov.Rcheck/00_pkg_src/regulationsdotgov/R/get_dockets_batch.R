

#' @keywords internal

get_dockets_batch <- function(agency, lastModifiedDate, api_keys) {
  
  api_key <- api_keys[1]
  
    for (i in 1:20) {
      message(paste("Page", i))
      
      # Build the API path and make the GET request
      path <- make_path_dockets(agency, lastModifiedDate, page = i, api_key)
      result <- httr::GET(path)
      status <- result$status_code
      url <- result$url
      
      if (status != 200) {
        message(paste(Sys.time() |> format("%X"), "| Status", status, "| Failed URL:", url))
        Sys.sleep(60)  # Pause before retrying - 
        #TODO retry path that failed
      }
      
      # Parse and store the content if the status is 200
      if(status == 200){
        content <- jsonlite::fromJSON(rawToChar(result$content))
        metadata[[i]] <- content 
      }
      
      # Extract rate limit and pause if necessary
      remaining <- as.numeric(result$headers$`x-ratelimit-remaining`)
      if (!is.na(remaining) && remaining < 2) {
        message(paste("|", Sys.time() |> format("%X"), "| Hit rate limit, will continue after one minute |", remaining, "remaining"))
        
        # Rotate API keys
        api_keys <- c(tail(api_keys, -1), head(api_keys, 1)) 
        api_key <- api_keys[1]
        message(paste("Rotating API key to", api_key))
        
        Sys.sleep(60)
      }
      
      # Break loop if the last page is reached
      if (!is.null(content$meta) && content$meta$lastPage == TRUE) {
        break
      }
      
    }
  
  d <- purrr::map_dfr(metadata, make_dataframe)
  
  if(nrow(d)==0){
    d <- tibble(lastpage = TRUE)}
  
  return(d) 
}

