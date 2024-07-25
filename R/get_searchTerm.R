
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
if(F){
searchTerm =  c("national congress of american indians")
}

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

source("R/get_searchTerm_batch.R")


get_searchTerm <- function(searchTerm,
                           documents = "documents", # c("documents", "comments") defaults to documents
                           lastModifiedDate = Sys.time()){


  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_searchTerm_batch(searchTerm,
                                   documents,
                                   #commentOnId, #TODO feature to search comments on a specific docket or document
                                   lastModifiedDate = Sys.time()
                                   )

  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of metadata using the last modified date
    nextbatch <- get_searchTerm_batch(searchTerm,
                                    documents,
                                    lastModifiedDate = tail(metadata$lastModifiedDate,
                                                             n = 1)
    )

    # Append next batch to comments
    # metadata <<- bind_rows(metadata, nextbatch) |> distinct()
     metadata <<- full_join(metadata, nextbatch) |> distinct()#FIXME? perhaps better? But will need to silence message
  }

  return(metadata)
}





#TESTING
if(F){
  d <- get_searchTerm(searchTerm, documents = "documents")

 d <- get_searchTerm(searchTerm, documents = "comments")



# write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))

searchTerm =  c("national congress of american indians", "cherokee nation")

searchTerm = c("climate justice", "environmental justice")

documents = c("documents", "comments")

search_to_csv <- function(searchTerm, documents){
  d <- get_searchTerm(searchTerm, documents)

  write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))
}

walk2(searchTerm, documents, .f = search_to_csv)


search_to_rda <- function(searchTerm, documents){
  d <- get_searchTerm(searchTerm, documents)

  save(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".rda")))
}

walk2(searchTerm, documents, .f = search_to_rda)
}


