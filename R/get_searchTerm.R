

#' @export

get_searchTerm <- function(searchTerm,
                           documents = "documents", # c("documents", "comments") defaults to documents
                           lastModifiedDate = Sys.time(), # , api_keys = api_keys #TODO test this
                           api_keys){
  
  metadata_temp <- tempfile(fileext = ".rda")
  
  tryCatch({  
    
    # Fetch the initial 5k and establish the base dataframe
    metadata <- get_searchTerm_batch(searchTerm = searchTerm,
                                   documents = documents,
                                   #commentOnId, #TODO feature to search comments on a specific docket or document
                                   lastModifiedDate,
                                   apikeys = api_keys)
    
    if(nrow(metadata) == 0){
      metadata <- dplyr::tibble(lastpage = TRUE)
    }

    # Loop until last page is TRUE
    while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of metadata using the last modified date
    nextbatch <- get_searchTerm_batch(searchTerm,
                                    documents,
                                    lastModifiedDate = tail(metadata$lastModifiedDate,
                                                            n = 1) |>
                                      stringr::str_replace("T", "%20") |>
                                      stringr::str_remove_all("[A-Z]"),
                                    api_keys = api_keys
                                    )

    message(paste(nrow(metadata), "+", nrow(nextbatch)))
    
    metadata <- suppressMessages(
      
      dplyr::full_join(metadata, nextbatch))
    
    message(paste(" = ", nrow(metadata)))
    
    }
  },error = function(e) {
    message("An error occurred: ", e$message)
    if (exists("metadata")) {
      save(metadata, file = metadata_temp)
      message("Document data saved to: ", metadata_temp)
      
    }
  })

  return(metadata)
}

# FOR TESTING
if(F){
  searchTerm =  c("national congress of american indians")
}






