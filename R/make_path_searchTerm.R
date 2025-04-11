#' @keywords internal

make_path_searchTerm <- function(searchTerm,
                                 endpoint,
                                 lastModifiedDate = Sys.time(),
                                 agencyId = NULL,
                                 docketId = NULL,
                                 docketType = NULL, #c("Rulemaking", "Non-rulemaking")
                                 commentOnId = NULL,
                                 page = 1,
                                 api_key) {
  
  # Base URL 
  base_url <- "https://api.regulations.gov/v4"
  endpoint <- match.arg(endpoint, c("documents", "comments", "dockets"))
  
  # Helper function to wrap in quotes and URL encode
  wrap_encode <- function(x) {
    if (is.null(x)) return(NULL)
    URLencode(paste0('"', x, '"'), reserved = TRUE)
  }
  
  # Query parameters
  query <- list(
    `filter[searchTerm]` = wrap_encode(searchTerm),
    `filter[agencyId]` = wrap_encode(agencyId),
    `filter[lastModifiedDate][le]` = format_date(lastModifiedDate),
    `filter[docketId]` = if (endpoint == "documents") wrap_encode(docketId),
    `filter[commentOnId]` = if (endpoint == "comments") wrap_encode(commentOnId),
    `filter[docketType]` = if (endpoint == "dockets") wrap_encode(docketType),
    `page[size]` = 250,
    `page[number]` = page,
    `sort` = "-lastModifiedDate,documentId",
    `api_key` = api_key
  )
  
  # Remove NULL parameters
  query <- Filter(Negate(is.null), query)
  
  # Construct final URL with proper encoding
  sprintf("%s/%s?%s",
          base_url,
          endpoint,
          paste0(names(query), "=", unlist(query), collapse = "&"))
}
