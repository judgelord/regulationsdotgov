#' @export


get_documents <- function(docketId,
                          lastModifiedDate = Sys.time(),
                          api_keys){
  
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

        metadata <- suppressMessages(

          dplyr::full_join(metadata, nextbatch))

        message(paste(" = ", nrow(metadata)))

      }
      }, error = function(e) {
      if (!is.null(metadata)) {
        save(metadata, file = metadata_temp)
        message("Partially retrieved metadata saved to: ", metadata_temp)}
    })

      return(metadata)
}


