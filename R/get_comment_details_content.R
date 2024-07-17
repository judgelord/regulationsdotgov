# this helper that does the work for each comment
# keeping just the content, not the full results, in memory while the main loop runs
get_comment_details_content <- function(id,
                                        lastModifiedDate = Sys.time()
                                        ){


  path <- make_path_comment_details(id[2], api_key)

  result <- GET(path)

  message(paste("|", id,
                "| status:", result$status_code,
                "| limit-remaining", result$headers$`x-ratelimit-remaining`)) #FIXME add status code and API limit remaining

  content <-  fromJSON(rawToChar(result$content))

  if(result$headers$`x-ratelimit-remaining` == 0){

    message(paste(Sys.time()|> format("%X"), "- Hit rate limit, will continue after one minute"))

    Sys.sleep(60)
  }

  return(content)
}
