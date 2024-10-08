

#' @export

get_dockets <- function(agency,
                        lastModifiedDate = Sys.time(),
                        api_keys) {
  
  metadata_temp <- tempfile(fileext = ".rda")
  
  tryCatch({
    # Fetch the initial 5k and establish the base dataframe
    metadata <- get_dockets_batch(agency, lastModifiedDate, api_keys)
    
    # Make a near-empty dataframe if the results are empty
    if (nrow(metadata) == 0) {
      metadata <- tibble(lastpage = TRUE)
    }
    
    # Loop until last page is TRUE
    while (!tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0) {
      # Fetch the next batch of comments using the last modified date
      nextbatch <- get_dockets_batch(agency,
                                     lastModifiedDate = tail(metadata$lastModifiedDate, n = 1),
                                     api_keys)
      
      message(paste(nrow(metadata), "+", nrow(nextbatch)))
      
      # Append next batch to metadata
      metadata <- suppressMessages(
        bind_rows(metadata, nextbatch)
      )
      
      message(paste(" = ", nrow(metadata)))
    }
    
  }, error = function(e) {
    message("An error occurred: ", e$message)
    if (exists("metadata")) {
      save(metadata, file = metadata_temp)
      message("Docket data saved to: ", metadata_temp)
    }
  })
  
  # Return the metadata (no saving on normal completion)
  return(metadata)
}

# TESTING
if(F){
n <- get_dockets(agency = "NOAA", api_keys = api_keys)
}
