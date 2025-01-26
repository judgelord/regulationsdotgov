#' @export


get_documents <- function(docketId,
                          lastModifiedDate = Sys.time(),
                          api_keys){
  
  metadata <- list()
  metadata_temp <- tempfile(fileext = ".rda")
  
  tryCatch({
    # Fetch the initial 5k and establish the base dataframe
    metadata <- get_documents_batch(docketId,
                                    lastModifiedDate,
                                    api_keys = api_keys)
    
    if(nrow(metadata) == 0){
      metadata <- dplyr::tibble(lastpage = TRUE)
    }
    
    # Loop until last page is TRUE
    while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {
      
      # Fetch the next batch of comments using the last modified date
      nextbatch <- get_documents_batch(docketId,
                                       lastModifiedDate = tail(metadata$lastModifiedDate, n = 1),
                                       api_keys)
      
      message(paste(nrow(metadata), "+", nrow(nextbatch)))
      
      # Append next batch to comments
      metadata <- dplyr::full_join(metadata, nextbatch)
      
      message(paste(" = ", nrow(metadata)))
      
      # Debugging: Print the tempfile path to ensure it's valid
      message("Saving metadata to temporary file: ", metadata_temp)
      
      # Save metadata to tempfile
      save(metadata, file = metadata_temp)
    }
    
  }, error = function(e) {
    
    message("An error occurred: ", e$message)
    
    if (length(metadata) > 0) {
      message("Saving partial metadata to: ", metadata_temp)
      save(metadata, file = metadata_temp)
    }
  })
  
  return(metadata)
}



