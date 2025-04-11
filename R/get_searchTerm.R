

#' @export

get_searchTerm <- function(searchTerm,
                           endpoint,
                           lastModifiedDate = Sys.time(), # , api_keys = api_keys #TODO test this
                           agencyId,
                           docketId, 
                           commentOnId, 
                           api_keys){

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
    metadata <- get_searchTerm_batch(searchTerm = searchTerm,
                                   endpoint,
                                   #commentOnId, #TODO feature to search comments on a specific docket or document
                                   lastModifiedDate = Sys.time(),
                                   api_keys = api_keys)

    if(nrow(metadata) == 0){
      metadata <- dplyr::tibble(lastpage = TRUE)
    }

    # Loop until last page is TRUE
    while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {



    # Fetch the next batch of metadata using the last modified date
    nextbatch <- get_searchTerm_batch(searchTerm,
                                    endpoint,
                                    lastModifiedDate = min(metadata$lastModifiedDate), # DONE BY format_date() in make_path()  |> stringr::str_replace("T", "%20") |> stringr::str_remove_all("[A-Z]"),
                                    api_keys = api_keys
                                    )

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
                                        endpoint,
                                        lastModifiedDate = newdate, # DONE BY format_date() in make_path()  |> stringr::str_replace("T", "%20") |> stringr::str_remove_all("[A-Z]"),
                                        api_keys = api_keys
      )
    }

    message(paste(nrow(metadata), "+", nrow(nextbatch)))

    # bind next batch to metadata
    metadata <- suppressMessages(
      dplyr::bind_rows(metadata, nextbatch)
      )

    message(paste(" = ", nrow(metadata)))
    }
    
    success <- TRUE
    return(metadata)

  }, error = function(e) {
    message("An error occurred: ", e$message)
  })
}

# FOR TESTING
if(F){
  get_searchTerm(searchTerm = "racism",
                 endpoint = "comments",
                 api_keys = keys,
                 lastModifiedDate = "2024-01-00T14:48:17Z")
}






