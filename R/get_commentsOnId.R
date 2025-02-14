#' @export

get_commentsOnId <- function(objectId,
                             lastModifiedDate = Sys.time(),
                             api_keys){

  metadata_temp <- tempfile(fileext = ".rda")

  message(paste("Getting comments on", objectId))

  tryCatch({

    # Fetch the initial 5k and establish the base dataframe

    metadata <- get_comments_batch(objectId,
                                 lastModifiedDate,
                                 api_keys)

    # Loop until last page is TRUE

    while( nrow(metadata) < 2000000 & (!tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0) ) {

    # Fetch the next batch of comments using the last modified date
    nextbatch <- get_comments_batch(objectId,
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
    ## END FIX

    message(paste(
      "Adding comments to", newdate, "|",
      nrow(metadata), "+", nrow(nextbatch)))

    # Append next batch to comments
    metadata <- suppressMessages(
      bind_rows(metadata, nextbatch) #TODO want to try left_join to see if it yields better results
    )

    message(paste(" = ", nrow(metadata)))

    }
    },  error = function(e) {
      if (!is.null(metadata)) {
        save(metadata, file = metadata_temp)
        message("Partially retrieved metadata saved to: ", metadata_temp)
      }
    })

  return(metadata)
}


