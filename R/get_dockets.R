#' @export

get_dockets <- function(agency,
                        lastModifiedDate = Sys.time(),
                        api_keys){
  
  message("get_dockets for ", agency)

  temp_file <- tempfile(pattern = "commentsOnId_", fileext = ".rda")
  
  success <- FALSE
  
  on.exit({
    if(!success && exists("metadata")) {
      save(metadata, file = temp_file)  
      message("\nFunction failed - saved content to temporary file: ", temp_file)
      message("To load: load('", temp_file, "')")
    }
  })
  
  
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
      
      message("NOTE: Number of dockets may be lower due to dropping duplicate rows.")
    }
    
    success <- TRUE
    
    return(dplyr::distinct(metadata))

  },  error = function(e) {
    message("An error occurred: ", e$message)
  })
}
