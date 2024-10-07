

#' @keywords internal

get_dockets_batch <- function(agency,
                        lastModifiedDate,
                        api_keys){

  api_key <- api_keys[1]
  
  lastModifiedDate <- format_date(lastModifiedDate)

  path <- make_path_dockets(agency, lastModifiedDate, api_key)

  # map GET function over pages
  result <- purrr::map(path, GET)

  # report result status
  status <<- map(result, status_code) |> tail(1) %>% as.numeric()

  url <- result[[20]][1]$url

  if(status != 200){
    message(paste(Sys.time() |> format("%X"),
                  "| Status", status,
                  "| URL:", url))

    # small pause to give user a chance to cancel
    Sys.sleep(6)
  }

  # EXTRACT THE MOST RECENT x-ratelimit-remaining and pause if it is 0
  remaining <<-  map(result, headers) |>
    tail(1) |>
    pluck(1, "x-ratelimit-remaining") |>
    as.numeric()

  if(remaining < 2){

    message(paste("|", Sys.time()|> format("%X"), "| Hit rate limit, will continue after one minute |", remaining, "remaining"))

    # ROTATE KEYS
    api_keys <<- c(tail(api_keys, -1), head(api_keys, 1))
    api_key <- api_keys[1]
    #api_key <<- apikeys[runif(1, min=1, max=3.999) |> floor() ]
    message(paste("Rotating api key to", api_key))

    Sys.sleep(60)
  }


  # map the content of successful api results into a list
  docket_metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))

  d <- map_dfr(docket_metadata, make_dataframe)


  return(d)

}
