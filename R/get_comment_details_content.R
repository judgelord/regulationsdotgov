#' @keywords internal

# this helper that does the work for each comment
# keeping just the content, not the full results, in memory while the main loop runs
get_comment_details_content <- function(id,
                                        lastModifiedDate,
                                        api_keys){


  path <- make_path_comment_details(id, sample(api_keys, 1) )

  result <- httr::GET(path)

  remaining <- result$headers$`x-ratelimit-remaining` |> as.numeric()

  message(paste("|", id,
                "| status:", result$status_code,
                "| limit-remaining", remaining, "|"))


  if( remaining < 2 ){ # if we set it to 0, we often get a 429 because the reported rate limit lags the true limit remaining. Even at <2, we occassionally get 429, but not often
  }

  # if previously failed due to rate limit, try again
  while( result$status_code == 429 ){

      message(paste("|", Sys.time()|> format("%X"),
                    "| Hit rate limit |",
                    remaining, "remaining | api key ending in",
                    api_key |> stringr::str_replace(".{35}", "...")))

      # ROTATE KEYS
      api_key <- sample(api_keys, 1)
      message(paste("Rotating to api key ending in", api_key |> stringr::str_replace(".{35}", "...")))

    # try again
    path <- make_path_comment_details(id, api_key)
    result <- httr::GET(path)

    remaining <- result$headers$`x-ratelimit-remaining` |> as.numeric()

    message(paste("| Trying", id, "again",
                  "| now", result$status_code, "|",
                  remaining, "remaining |"))

    # pause to reset rate limit
    if(result$status_code == 429 | remaining < 2){
    message(paste(Sys.time()|> format("%X"), "- Hit rate limit again, will continue after one minute"))
    Sys.sleep(60)
    }
  }

  # Sys.sleep(0.01) # very small pause to allow rate limit reported to be more accurate

  # return content (small object than result)
  content <-  jsonlite::fromJSON(rawToChar(result$content))

  return(content)
}


