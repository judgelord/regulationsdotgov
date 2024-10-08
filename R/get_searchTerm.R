

#' @export

get_searchTerm <- function(searchTerm,
                           documents = "documents", # c("documents", "comments") defaults to documents
                           lastModifiedDate = Sys.time(), # , api_keys = api_keys #TODO test this
                           api_keys = keys){

  lastModifiedDate <- format_date(lastModifiedDate)

  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_searchTerm_batch(searchTerm = searchTerm,
                                   documents = documents,
                                   #commentOnId, #TODO feature to search comments on a specific docket or document
                                   lastModifiedDate = lastModifiedDate,
                                   apikeys = api_keys)

  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of metadata using the last modified date
    nextbatch <- get_searchTerm_batch(searchTerm,
                                    documents,
                                    lastModifiedDate = tail(metadata$lastModifiedDate,
                                                            n = 1) |>
                                      str_replace("T", "%20") |>
                                      str_remove_all("[A-Z]"),
                                    apikeys = api_keys
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

# FOR TESTING
if(F){
  searchTerm =  c("national congress of american indians")
}






