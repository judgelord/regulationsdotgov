
## trying to incorporate a while loop for last page - I might have lost the plot

source("~/api-key.R")

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

source("R/fetch_with_delay.R")
source("R/make_path_commentOnId.R")
source("R/make_comment_dataframe.R")
source("R/make_call.R")


# FOR TESTING
searchTerm =  c("national congress of american indians")

get_searchTerm <- function(searchTerm,
                           documents = "documents",
                           lastModifiedDate = Sys.time()){

  d <- list()
  lastpage <- FALSE

  # fixing lastMdifiedDate inside the function so that we do not need to do format dates for the API before providing them to the function (this also allows us to set sys.time as a default, which requires formatting as well)
  lastModifiedDate <- lastModifiedDate  %>%
    ymd_hms() %>%
    with_tz(tzone = "America/New_York") %>%
    gsub(" ", "%20", .) %>%
    str_remove("\\..*")

  # call the make path function to make paths for the first 20 pages of 250 results each
  path <- make_path_searchTerm(searchTerm, documents, lastModifiedDate)

  for (url in path){

    df <- make_call(url)

    if (!is.null(df)) {
      d <- append(d, list(df))
    }

    lastpage <- tail(d$lastpage)
  }

  combined_df <- bind_rows(d)

  combined_df$searchTerm <- searchTerm

  return(combined_df)
}


#TESTING
if(F){
d <- get_searchTerm(searchTerm, documents = "comments")

# write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))

searchTerm =  c("national congress of american indians", "cherokee nation")
documents = c("documents", "comments")

search <- function(searchTerm, documents){
  d <- get_searchTerm(searchTerm, documents)

  write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))
}

walk2(searchTerm, documents, .f = search)
}


