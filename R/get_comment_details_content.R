#' @keywords internal

# this helper that does the work for each comment
# keeping just the content, not the full results, in memory while the main loop runs
get_comment_details_content <- function(id,
                                        lastModifiedDate,
                                        api_keys){


  path <- make_path_comment_details(id, api_keys[1])

  result <- GET(path)

  remaining <- result$headers$`x-ratelimit-remaining` |> as.numeric()

  message(paste("|", id,
                "| status:", result$status_code,
                "| limit-remaining", remaining, "|"))


  if( remaining < 2 ){ # if we set it to 0, we often get a 429 because the reported rate limit lags the true limit remaining. Even at <2, we occassionally get 429, but not often
  }

  # if previously failed due to rate limit, try again
  while( result$status_code == 429 ){

    # ROTATE KEYS
    api_keys <<- api_keys <- c(tail(api_keys, -1), head(api_keys, 1))

    message(paste("429 - rotating to api key ending in", api_keys[1] |> str_remove(".{35}")))

    # try again
    path <- make_path_comment_details(id, api_keys[1])
    result <- GET(path)

    remaining <- result$headers$`x-ratelimit-remaining` |> as.numeric()

    message(paste("| Trying", id, "again",
                  "| now", result$status_code, "|",
                  remaining, "remaining |"))

    # pause to reset rate limit
    if(result$status_code == 429 | remaining < 2){
    message(paste(Sys.time()|> format("%X"), "- Hit rate limit, will continue after one minute"))
    Sys.sleep(60)
    }
  }

  Sys.sleep(0.01) # very small pause to allow rate limit reported to be more accurate

  # return content (small object than result)
  content <-  fromJSON(rawToChar(result$content))

  return(content)
}


