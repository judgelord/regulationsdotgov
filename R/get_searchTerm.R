library(httr)
library(jsonlite)
library(purrr)
library(dplyr)

#############################
# REQUIRES HELPER FUNCTIONS #
#############################

# source("R/make_dataframe.R")
# source("R/get_searchTerm_batch.R")


# FOR TESTING
if(F){
searchTerm =  c("national congress of american indians")
}



get_searchTerm <- function(searchTerm,
                           documents = "documents", # c("documents", "comments") defaults to documents
                           lastModifiedDate = Sys.time() # , api_keys = api_keys #TODO test this
                           ){

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

    message(paste(nrow(metadata), "+", nrow(nextbatch)))

    # Append next batch to comments
     metadata <- suppressMessages(
       full_join(metadata, nextbatch)
     )

     message(paste("= ", nrow(metadata)))
  }

  return(metadata)
}






