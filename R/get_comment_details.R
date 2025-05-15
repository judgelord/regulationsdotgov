
#' @export


# loop over a vector of comment ids, return a dataframe of comment details
get_comment_details <- function(id,
                                lastModifiedDate = Sys.time(),
                                api_keys = keys) {

  if(length(id) != length(unique(id))) {
    message("Duplicate ids dropped to save API calls (result will be shorter than length of input id vector)")
  }

  message("Trying: ", make_path_comment_details(id[1], "XXXXXXXXXXXXXX")) ## Switch this out for doc ID so its clearer?

  unique_ids <- unique(id)

  message("| Comment details | input N = ", length(id), " | output N = ", length(unique_ids), " | \n| --- | --- | --- | ")

  temp_file <- tempfile(pattern = "comment_details_content_", fileext = ".rda")

  success <- FALSE

  on.exit({
    if(!success && exists("content")) {

      metadata <- purrr::map_dfr(content, ~{
        # Extract attributes and replace NULLs with NA
        attrs <- purrr::pluck(.x, "data", "attributes") |>
          purrr::map(~ if(is.null(.x)) NA else .x) |>
          as.data.frame() #|>
        #dplyr::select(-starts_with("display")) # Possibly add this back in after testing?

        # Add the id column
        attrs$id <- purrr::pluck(.x, "data", "id")

        # Return the augmented data
        attrs
      }) |>
        dplyr::select(where(~!all(is.na(.x)))) #Remove columns that are empty

      save(metadata, file = temp_file)
      message("\nFunction failed - saved content to temporary file: ", temp_file)
      message("To load: load('", temp_file, "')")
    }
  })

  content <- vector("list", length(unique_ids))

  for(i in seq_along(unique_ids)) {
    tryCatch({
      content[[i]] <- get_comment_details_content(unique_ids[i], api_keys = api_keys)
    },
    error = function(e) {
      message("Error for id ", unique_ids[i], ": ", e$message)
      content[[i]] <<- NULL
    })
  }

  nulls <- vapply(content, is.null, logical(1))

  if(sum(nulls) > 0) {
    message(paste("Errors for ids:", paste(unique_ids[nulls], collapse = ",")))
  }

  # Drop nulls
  content <- content[!nulls]

  if(length(content) == 0) {
    warning("No valid comments retrieved")
    return(NULL)
  }

  # note that document call return attachment file names in attributes, but comments are in included

  metadata <- purrr::map_dfr(content, extract_attrs) |>
    dplyr::select(where(~!all(is.na(.x)))) #Remove columns that are empty

  # # Get attachments
  # metadata$attachments <- lapply(content, function(x) {
  #   if(!is.null(x$included) && !is.null(x$included$attributes)) {
  #    tidyr::nest(x$included$attributes$fileFormats)
  #   } else {
  #     NULL
  #   }
  # })

  metadata <- dplyr::distinct(metadata)

  success <- TRUE

    return(metadata)
}

