

#' @export

get_dockets <- function(agency,
                        lastModifiedDate = Sys.time(),
                        api_keys){

  # Fetch the initial 5k and establish the base dataframe
  metadata <- get_dockets_batch(agency, lastModifiedDate, api_keys)

  # make an near-empty dataframe if the results are empty
  if(nrow(metadata) == 0){
    metadata <- tibble(lastpage = TRUE)
  }

  # Loop until last page is TRUE
  while( !tail(metadata$lastpage, 1) | nrow(metadata) %% 5000 == 0 ) {

    # Fetch the next batch of comments using the last modified date

    nextbatch <- get_dockets_batch(agency,
                                   lastModifiedDate = tail(metadata$lastModifiedDate, n = 1),
                                   api_keys)

    message(paste(nrow(metadata), "+", nrow(nextbatch)))

    # Append next batch to comments
    metadata <- suppressMessages(
      bind_rows(metadata, nextbatch)
    )

    message(paste(" = ", nrow(metadata)))

  }

  return(metadata)

}

# TESTING
if(F){
n <- get_dockets(agency = "NOAA", api_keys = api_keys)
}

