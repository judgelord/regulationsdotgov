#' @export

get_dockets <- function(agency,
                        lastModifiedDate = Sys.time(),
                        api_keys){
  
  message("get_dockets for ", agency)

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

      ## Temporary partial fix to issue #24 and #25
      # make sure we advanced
      newdate <- nextbatch$lastModifiedDate |> min()
      olddate <- metadata$lastModifiedDate |> min()
      
      # if we did not
      if( newdate == olddate ){
        newdate <- newdate |>
          as.POSIXct(format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC") |>
          (\(x) x - 86400)() |>
          format("%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
        
        nextbatch <- get_dockets_batch(agency,
                                       lastModifiedDate = newdate,
                                       api_keys)
      }
      ## END FIX

      message(paste(nrow(metadata), "+", nrow(nextbatch)))

      # Append next batch to metadata
      metadata <- suppressMessages(
        dplyr::bind_rows(metadata, nextbatch)
      )

      message(paste(" = ", nrow(metadata)))
    }

  },  error = function(e) {
    message("An error occurred: ", e$message)
    if (!is.null(metadata)) {
      
      save(metadata, file = tempdata)
      message("Partially retrieved metadata saved to: ", tempdata)
    }
  })
  
  message("NOTE:Number of dockets may be lower due to dropping duplicate rows.")
  metadata <- metadata |> dplyr::distinct() #removing rows that are entirely duplicated

  # Return the metadata (no saving on normal completion)
  return(metadata)
}
