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

      ## Temporary partial fix to issue #24 and #25
      # make sure we advanced
      newdate <- as.Date(nextbatch$lastModifiedDate) |> min()
      olddate <- as.Date(metadata$lastModifiedDate) |> min()

      # if we did not
      if( newdate == olddate ){
        # go to next day to avoid getting stuck
        newdate <-  min(metadata$lastModifiedDate)

        # subtract a day so we don't end up in endless loops  where more than 5000 comments come in a single day
        stringr::str_sub(newdate, 9, 10) <- ( as.numeric(newdate |> stringr::str_sub(9, 10) ) -1 ) |>
          abs() |> # FIXME this really should be subtracting one second from a native date time object---we can still get stuck at 00 here
          stringr::str_pad(2, pad =  "0") |>
          stringr::str_replace("00", "01")

        nextbatch <- get_searchTerm_batch(searchTerm,
                                          documents,
                                          lastModifiedDate = newdate, # DONE BY format_date() in make_path()  |> stringr::str_replace("T", "%20") |> stringr::str_remove_all("[A-Z]"),
                                          api_keys = api_keys
        )
      }

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



