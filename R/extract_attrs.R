#' @keywords internal

# a function to extract attributes
extract_attrs <- function(content) {
  
  x <- content#[[1]]
  
  # Extract attributes and replace NULLs with NA
  attrs <- purrr::pluck(x, "data", "attributes")
  
  
  # nest attachments
  # attrs$fileFormats <-  tidyr::nest(attrs$fileFormats, .key = "fileFormats")
  
  
  attrs <- attrs |>
    purrr::map(~ ifelse(is.null(.x), NA_character_, .x)) |>
    as.data.frame() |>
    dplyr::select(-starts_with("display")) # Possibly add this back in after testing?
  
  # Add the id column
  attrs$id <- purrr::pluck(x, "data", "id")
  
  # Add attachments (fileFormats) if they exist
  if (!is.null(x$included) && !is.null(x$included$attributes)) {
    fileFormats <- x$included$attributes$fileFormats |> purrr::map_dfr(~ as.data.frame(.x) )
    
    if (!is.null(fileFormats)){
      attrs$attachments <- list(fileFormats) # |>  tidyr::nest(.key = "fileFormats") #FIXME this is too nested
    } else {
      attrs$attachments <- NA_character_
    }
  }
  
  # Return the augmented data
  return(attrs)
}