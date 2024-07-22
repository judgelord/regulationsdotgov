


get_dockets <- function(agency, lastModifiedDate = Sys.time()){

  lastModifiedDate <- lastModifiedDate  %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    # replace spaces with unicode
    gsub(" ", "%20", .) %>%
    str_remove("\\..*")

  path <- make_path_dockets(agency)

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
    pluck(1, "x-ratelimit-remaining")

  if(remaining < 2){

    message(paste(Sys.time()|> format("%X"), "- Hit rate limit, will continue after one minute"))

    Sys.sleep(60)
  }


  # map the content of successful api results into a list
  docket_metadata <- purrr::map_if(result, ~ status_code(.x) == 200, ~fromJSON(rawToChar(.x$content)))


  return(docket_metadata)

}