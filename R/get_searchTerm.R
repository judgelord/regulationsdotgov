
## trying to incorporate a while loop for last page - I might have lost the plot

source("../api-key.R")

library(httr)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(lubridate)

source("R/make_dataframe.R")
source("R/get_searchTerm_batch.R")


# FOR TESTING
if(F){
searchTerm =  c("national congress of american indians")
}



get_searchTerm <- function(searchTerm,
                           documents = "documents", # c("documents", "comments") defaults to documents
                           lastModifiedDate = Sys.time()){


  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_searchTerm_batch(searchTerm = searchTerm,
                                   documents = documents,
                                   #commentOnId, #TODO feature to search comments on a specific docket or document
                                   lastModifiedDate = lastModifiedDate,
                                   api_keys = api_keys)

  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of metadata using the last modified date
    nextbatch <- get_searchTerm_batch(searchTerm,
                                    documents,
                                    lastModifiedDate = tail(metadata$lastModifiedDate,
                                                             n = 1),
                                    api_keys = api_keys
                                    )

    message(paste("+", nrow(nextbatch)))

    # Append next batch to comments

    #FIXME this works when run on its own, but using the function, metadata fails to update
     #metadata <<- bind_rows(metadata, nextbatch) #|> distinct()
     metadata <<- full_join(metadata, nextbatch) #FIXME? perhaps better? But will need to silence message

     metadata <<- distinct(metadata)

     message(paste(" = ", nrow(metadata)))
  }

  return(metadata)
}





#TESTING
if(F){
  d <- get_searchTerm(searchTerm) # documents, the default

 d <- get_searchTerm(searchTerm, documents = "comments") # comments



# write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))

search =  c("national congress of american indians", "cherokee nation")

search = c("climate justice", "environmental justice")

search = c("climate justice")


documents = c("documents", "comments")

documents = c("comments")


search_to_csv <- function(searchTerm, documents){
  d <- get_searchTerm(searchTerm, documents)

  write_csv(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".csv")))
}

walk2(searchTerm, documents, .f = search_to_csv)


search_to_rda <- function(search, documents){
  d <- get_searchTerm(searchTerm, documents)

  save(d, file = here::here("data", "metadata", documents, paste0(searchTerm, ".rda")))
}

walk2(search, documents, .f = search_to_rda)
}


