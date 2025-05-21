

#' @keywords internal

get_dockets_batch <- function(agency,
                              lastModifiedDate,
                              lastModifiedDate_mod = "le", #c("le", "ge")
                              docketType = NULL, #c("Rulemaking", "Nonrulemaking")
                              api_keys){

  api_key <- sample(api_keys, 1)
  
  metadata <- list()
  failed_paths <- list()

  for (i in 1:20) {
    message(paste("Page", i))

    # Build the API path and make the GET request
    path <- make_path_dockets(agency, 
                              lastModifiedDate, 
                              lastModifiedDate_mod =  lastModifiedDate_mod,
                              page = i, 
                              api_key = api_key)
    
    result <- httr::GET(path)
    status <- result$status_code
    url <- result$url
    remaining <- as.numeric(result$headers$`x-ratelimit-remaining`)

    
    if(status != 200 & status != 429){
      message(paste(Sys.time() |> format("%X"),
                    "| Status", status,
                    "| Failed URL:", path |> stringr::str_replace("&api_key=.+(.{4})", "&api_key=XXX\\1")))
      
      failed_paths[[i]] <- path
    
      # small pause to give user a chance to cancel
      Sys.sleep(6)
    }
    
    #if previously failed due to rate limit, try again
    while(status == 429){
      
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
      path <- make_path_dockets(agency, 
                                lastModifiedDate, 
                                lastModifiedDate_mod =  lastModifiedDate_mod,
                                page = i, 
                                api_key = api_key)
      
      result <- httr::GET(path)
      
      status <- result$status_code
      
      remaining <- result$headers$`x-ratelimit-remaining` |> as.numeric()
      
      message(paste("|", "Trying:", agency ,"again",
                    "| now:", status,
                    "| limit-remaining", remaining, "|"))
      
      # pause to reset rate limit
      if(status == 429 | remaining < 2){
        message(paste(Sys.time()|> format("%X"), "- Hit rate limit again, will continue after one minute"))
        Sys.sleep(60)
      }
    }
    
    # Parse and store the content if the status is 200
    if(status == 200){
      content <- jsonlite::fromJSON(rawToChar(result$content))
      metadata[[i]] <- content
    }

    # Break loop if the last page is reached
    if(!is.null(content$meta$lastPage)){
      if(content$meta$lastPage == TRUE){break} # breaks loop when last page is reached
    }
    
  }

  d <- purrr::map_dfr(metadata, make_dataframe)
  
  if(length(failed_paths > 0)){
    message("Failed paths:", failed_paths)
  }

  #if(nrow(d)==0){
  #  d <- tibble::tibble(lastpage = TRUE)}

  return(d)
}
