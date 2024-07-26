# this helper that does the work for each comment
# keeping just the content, not the full results, in memory while the main loop runs
get_comment_details_content <- function(id,
                                        lastModifiedDate = Sys.time(),
                                        api_keys){


  path <- make_path_comment_details(id, api_keys[1])

  result <- GET(path)

  remaining <- result$headers$`x-ratelimit-remaining` |> as.numeric()

  message(paste("|", id,
                "| status:", result$status_code,
                "| limit-remaining", remaining)) #FIXME add status code and API limit remaining


  if( remaining < 2 ){ # if we set it to 0, we often get a 429 because the reported rate limit lags the true limit remaining. Even at <2, we occassionally get 429, but not often

    message(paste(Sys.time()|> format("%X"), "- Hit rate limit, will continue after one minute"))

    # ROTATE KEYS
    api_keys <<- c(tail(api_keys, -1), head(api_keys, 1))
    message(paste("Rotating to api key", api_keys[1]))

    # pause to reset rate limit
    Sys.sleep(60)
  }

  # if previously failed due to rate limit, try again
  if( result$status_code == 429 ){
    result <- GET(path)

    message(paste("429 | trying", id, "again",
                  "| now", result$status_code,
                  "| limit-remaining", remaining)) #FIXME add status code and API limit remaining

    Sys.sleep(3) # small pause to make up for extra request
  }

  Sys.sleep(0.1) # very small pause to allow rate limit reported to be more accurate

  # return content (small object than result)
  content <-  fromJSON(rawToChar(result$content))

  return(content)
}

if(F){
  get_comment_details_content(id = "CEQ-2019-0003-197917", api_keys = api_keys)
}
