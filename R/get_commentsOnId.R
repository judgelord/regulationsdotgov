#' @export

get_commentsOnId <- function(objectId,
                             lastModifiedDate = Sys.time(),
                             api_keys = keys){

  temp_file <- tempfile(pattern = "commentsOnId_", fileext = ".rda")
  
  success <- FALSE
  
  on.exit({
    if(!success && exists("metadata")) {
      save(metadata, file = temp_file)  
      message("\nFunction failed - saved content to temporary file: ", temp_file)
      message("To load: load('", temp_file, "')")
    }
  })
  

  message(paste("Getting comments on", objectId))

  tryCatch({

    # Fetch the initial 5k and establish the base dataframe

    metadata <- get_comments_batch(objectId,
                                 lastModifiedDate,
                                 api_keys)

    # message("Docket =", unique(metadata$id |> stringr::str_remove("-[0-9]*$")))

    # Loop until last page is TRUE

    while( nrow(metadata) < 2000000 & (!tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0) ) {

    # Fetch the next batch of comments using the last modified date
    nextbatch <- get_comments_batch(objectId,
                                    lastModifiedDate = tail(metadata$lastModifiedDate, n = 1),
                                    api_keys)

    ## Temporary partial fix to issue #24 and #25
    # make sure we advanced
    newdate <-  min(nextbatch$lastModifiedDate)
    olddate <-  min(metadata$lastModifiedDate)

    # if we did not
    if( newdate == olddate ){
      # go to next day to avoid getting stuck
      
      newdate <- newdate |>
        as.POSIXct(format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC") |>
        (\(x) x - 86400)() |>
        format("%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
        
     # # subtract a day so we don't end up in endless loops  where more than 5000 comments come in a single day
     # stringr::str_sub(newdate, 9, 10) <- ( as.numeric(newdate |> stringr::str_sub(9, 10) ) -1 ) |>
     #   abs() |> # FIXME this really should be subtracting one second from a native date time object---we can still get stuck at 00 here
     #   stringr::str_pad(2, pad =  "0") |>
     #   stringr::str_replace("00", "01")

     nextbatch <- get_comments_batch(objectId,
                                     lastModifiedDate = newdate,
                                     api_keys)
    }
    ## END FIX

    message(paste(
      "Adding comments from", olddate, "to", newdate, "|",
      nrow(metadata), "+", nrow(nextbatch)))

    # Append next batch to comments
    metadata <- suppressMessages(
      dplyr::bind_rows(metadata, nextbatch) #TODO want to try left_join to see if it yields better results
    )

    message(paste(" = ", nrow(metadata)))
    }
    
    success <- TRUE
    return( dplyr::distinct(metadata) )
    
    },  error = function(e) {
      message("An error occurred: ", e$message)
      })
}


