#' @export

get_commentsOnId <- function(commentOnId,
                             lastModifiedDate = Sys.time(),
                             api_keys){
  
  metadata_temp <- tempfile(fileext = ".rda")
  
  tryCatch({
    
    message(paste("Getting comments on", commentOnId))
    
    # Fetch the initial 5k and establish the base dataframe
    
    metadata <- get_comments_batch(commentOnId,
                                 lastModifiedDate,
                                 api_keys)
    
    # Loop until last page is TRUE
    
    while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of comments using the last modified date
    nextbatch <- get_comments_batch(commentOnId,
                                    lastModifiedDate = tail(metadata$lastModifiedDate, n = 1),
                                    api_keys)

    message(paste(nrow(metadata), "+", nrow(nextbatch)))

    # Append next batch to comments
    metadata <- suppressMessages(
      bind_rows(metadata, nextbatch) #TODO want to try left_join to see if it yields better results
    )

    message(paste(" = ", nrow(metadata)))
    
    }
    }, error = function(e) {
    message("An error occurred: ", e$message)
    if (exists("metadata")) {
      save(metadata, file = metadata_temp)
      message("Docket data saved to: ", metadata_temp)}
    }
  )
  
  return(metadata)
}


