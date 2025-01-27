#' @export

get_dockets <- function(agency,
                        lastModifiedDate = Sys.time(),
                        api_keys){
  
  # Initialize temp file 
  tempdata <- tempfile(fileext = ".rda")
  
  tryCatch({
    # Fetch the initial 5k and establish the base dataframe
    metadata <- get_dockets_batch(agency, lastModifiedDate, api_keys)
    
    # Loop until last page is TRUE
    while (!tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0) {
      # Fetch the next batch of comments using the last modified date
      nextbatch <- get_dockets_batch(agency,
                                     lastModifiedDate = tail(metadata$lastModifiedDate, n = 1),
                                     api_keys)
      
      message(paste(nrow(metadata), "+", nrow(nextbatch)))
      
      # Append next batch to metadata
      metadata <- suppressMessages(
        dplyr::bind_rows(metadata, nextbatch)
      )
      
      message(paste(" = ", nrow(metadata)))
    }
    
  }, error = function(e) {
    if (exists(metadata)) {
      save(metadata, file = tempdata)
      message("Partially retrieved metadata saved to: ", tempdata)
    }
  })
  
  # Return the metadata (no saving on normal completion)
  return(metadata)
}
