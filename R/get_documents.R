#' @export


get_documents <- function(agencyId = NULL,
                          docketId = NULL,
                          lastModifiedDate = Sys.time(),
                          lastModifiedDate_mod = "le", #c("le", "ge", "NULL")
                          documentType = NULL, #c("Notice", "Rule", "Proposed Rule", "Supporting & Related Material", "Other")
                          api_keys){
  
  metadata <- list()
  success <- FALSE
  
  # Save temp file on error
  temp_file <- tempfile(pattern = "documents_", fileext = ".rda") 
  
  on.exit({
    if(!success && exists("metadata")) {
      save(metadata, file = temp_file)  
      message("\nTemporary file: ", temp_file)
      message("To load: load('", temp_file, "')")}})

  tryCatch({
    # Fetch the initial 5k and establish the base dataframe
    metadata <- get_documents_batch(agencyId,
                                    docketId,
                                    lastModifiedDate,
                                    lastModifiedDate_mod, 
                                    documentType, 
                                    api_keys)

    if(nrow(metadata) == 0){
      metadata <- dplyr::tibble(lastpage = TRUE)
    }

    # Loop until last page is TRUE
    while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

      # Fetch the next batch of comments using the last modified date
      nextbatch <- get_documents_batch(agencyId,
                                       docketId,
                                       lastModifiedDate = tail(metadata$lastModifiedDate, n = 1),
                                       lastModifiedDate_mod, 
                                       documentType, 
                                       api_keys)

      ## Temporary partial fix to issue #24 and #25
      # make sure we advanced
      newdate <- nextbatch$lastModifiedDate |> min()
      olddate <- metadata$lastModifiedDate |> min()

      # if we did not
      if( newdate == olddate ){
        # go to next day to avoid getting stuck

        # subtract a day so we don't end up in endless loops  where more than 5000 comments come in a single day
        newdate <- newdate |>
          as.POSIXct(format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC") |>
          (\(x) x - 86400)() |>
          format("%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

       nextbatch <- get_documents_batch(agencyId,
                           docketId,
                           lastModifiedDate = newdate,
                           lastModifiedDate_mod, 
                           documentType, 
                           api_keys)
      }

      message(paste(nrow(metadata), "+", nrow(nextbatch)))

      # Append next batch to comments
      metadata <- dplyr::full_join(metadata, nextbatch)

      message(paste(" = ", nrow(metadata)))
    }
    
    success <- TRUE
    return(metadata)

  }, error = function(e) {
    message("An error occurred: ", e$message)
  })
}



