

#' @export

get_searchTerm <- function(searchTerm,
                           documents = "documents", # c("documents", "comments") defaults to documents
                           lastModifiedDate = Sys.time(), # , api_keys = api_keys #TODO test this
                           api_keys = keys){

  metadata_temp <- tempfile(fileext = ".rda")

  tryCatch({

    # Fetch the initial 5k and establish the base dataframe
    metadata <- get_searchTerm_batch(searchTerm = searchTerm,
                                   documents = documents,
                                   #commentOnId, #TODO feature to search comments on a specific docket or document
                                   lastModifiedDate = Sys.time(),
                                   api_keys = api_keys)

    if(nrow(metadata) == 0){
      metadata <- dplyr::tibble(lastpage = TRUE)
    }

    # Loop until last page is TRUE
    while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

      #newdate <-  tail(metadata$lastModifiedDate,  n = 1)
      newdate <-  min(metadata$lastModifiedDate)


      # subtract a second so we don't end up in endless loops  where more than 5000 comments come in a single second
      # TODO can we make this conditional on the date being the same as it was before?
      str_sub(newdate, -3, -2) <- ( as.numeric(newdate |> str_sub(-3, -2) ) -1 ) |>
        abs() |> # FIXME this really should be subtracting one sedond from a native date time object---we can still get stuck at 00 here
        str_pad(2, pad =  "0")

    # Fetch the next batch of metadata using the last modified date
    nextbatch <- get_searchTerm_batch(searchTerm,
                                    documents,
                                    lastModifiedDate = newdate, # DONE BY format_date() in make_path()  |> stringr::str_replace("T", "%20") |> stringr::str_remove_all("[A-Z]"),
                                    api_keys = api_keys
                                    )

    message(paste(nrow(metadata), "+", nrow(nextbatch)))

    metadata <- suppressMessages(
      dplyr::bind_rows(metadata, nextbatch)
      )

    message(paste(" = ", nrow(metadata)))
    }

  }, error = function(e) {
    message("An error occurred: ", e$message)
    if (exists("metadata")) {
      save(metadata, file = metadata_temp)
      message("Document data saved to: ", metadata_temp)

    }
  })

  return(metadata)
}

# FOR TESTING
if(F){
  get_searchTerm("racism", "comments", api_keys = keys)
}






