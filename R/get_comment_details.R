
#' @export


# loop over a vector of comment ids, return a dataframe of comment details
get_comment_details <- function(id,
                                lastModifiedDate = Sys.time(),
                                api_keys = keys) {



  if(length(id) != length(id |> unique()) ){
    message("Duplicate ids dropped to save API calls (result will be shorter than length of input id vector)")
  }

  message("Trying: ", make_path_comment_details(id[1], "XXXXXXXXXXXXXX") )

  unique_ids <- unique(id)

  message("| Comment details | input N = ", length(id), " | output N = ", length(unique_ids), " | \n| --- | --- | --- | ")


  # TODO make batches that we save in a temp file?
  # batches <- length(id)/5000 |> round(1)

  #FIXME we need better error handling, for now using possibly(..., otherwise = content_init)
  # a default for possibly to return if the call fails
  path <- make_path_comment_details(unique_ids[1], sample(api_keys, 1) )
  result_init <- httr::GET(path)
  content_init <- jsonlite::fromJSON(rawToChar(result_init$content))
  content_init$data$id <- NULL


  # TESTING WITHOUT POSSIBLY TO SEE ERRORS
  # content <- purrr::map(unique_ids, get_comment_details_content, api_keys = api_keys)

  #FIXME batch this by 5k, saving to a temp file
  content <- purrr::map(unique_ids,
                        api_keys = api_keys,
                        purrr::possibly(get_comment_details_content,
                                 otherwise = content_init) # FIXME replace with NULL, and then drop NULLs before next step? We might also be able to try the failed ones again.
  )

  # nulls are 404 errors on comment ids
  nulls <- purrr::map(content, ~.x$data$id) |> purrr::map_lgl(is.null )

  if( sum(nulls) > 0 ){
  message(paste("404 error:", paste(id[nulls], collapse = ",")))
  }

  # drop null
  content <- content[!nulls]

  # note that document call return attachment file names in attributes, but comments are in included
  metadata <- purrr::map_dfr(content, ~.x |> purrr::pluck("data", "attributes")) |> # purrr::map_dfr(content, ~.x$data$attributes) |>
    dplyr::select(-starts_with("display")) |>
    dplyr::distinct()

  #FIXME ISSUE #6
  # add id back in (we could just use the ids supplied to the function,  but the API returns more than one row for a single supplied document ID (at least for documents other than comments, it seems). I am hoping that by extracting it back out of the result, we get a vector of the correct length)
  #ids1 <- map(content, ~.x |> pluck("data", "id")) |>
  # FIXME? hopefully by discarding nulls, we get the same length as metadata....no this did not seem to work...
  #discard(is.null) |>
  #as.character()

  # NONE OF THIS WORKED, BUT I WORRY ABOUT THE ABOVE
  # IDEALLY WE WOULD USE THE SAME METHOD FOR BOTH
  #metadata1 <- purrr::map(content, ~.x |> pluck("data", "attributes")) |>
    #modify(~ifelse(is.null(.x), NA, .x)) |>
    #map_dfr(~.x)
    #list_rbind()
    #map(flatten) |>
    #purrr::map_depth(1, ~ifelse(is.null(.x), NA, .x) ) |>
    #map_dfr(~ .x)

  # ids <- modify(content, ~ifelse(is.null(.x), NA, .x) ) %>% .[[4872]]  #map_chr(content, ~.x$data$id)

  # ids <- purrr::map(content, ~.x$data$id) |> as.character()
  ids <- purrr::map_chr(content, ~.x |> purrr::pluck("data", "id"))

  metadata$id <- ids  #unique()

  #extract attachment file urls from included$attributes
  # attachments <- purrr::map_dfr(content, ~.x$included$attributes$fileFormats)
  attachments <- purrr::map(content, ~.x |> purrr::pluck("included", "attributes", "fileFormats"))

  #TODO REPLACE NULL WITH A DATA FRAME OF NAs SO THAT THIS WORKS?
  # attachments <- map(attachments, flatten) |> map(as.data.frame)

  metadata$attachments <- attachments #|> unique()

  # NO LONGER NEED THIS NOW THAT WE ARE USING PLUCK
  # # if some comments have attachments, then extract ids from the urls and nest all file url into one list per comment id
  # if(nrow(attachments) > 0){
  #   attachments_with_urls <- attachments |>
  #     mutate(id = str_remove_all(fileUrl, ".*gov/|/attach.*")) |>
  #     distinct(id, fileUrl) |>
  #     nest(.by = "id", .key = "attachments")
  #
  #   # join in the attachment lists by id
  #   # comments with no attachments will be null
  #   metadata <- left_join(metadata, attachments_with_urls, by = "id")
  # }

  metadata <- dplyr::distinct(metadata)

  return(metadata)
}


