#' @keywords internal

make_path_searchTerm <- function(searchTerm,
                                 endpoint,
                                 lastModifiedDate,
                                 lastModifiedDate_mod = "le", #c("le", "ge", "NULL"),
                                 agencyId = NULL,
                                 docketId = NULL,
                                 docketType = NULL, #c("Rulemaking", "Nonrulemaking")
                                 commentOnId = NULL,
                                 page,
                                 api_key) {
  
  # Base URL 
  base_url <- "https://api.regulations.gov/v4/"
  endpoint <- match.arg(endpoint, c("documents", "comments", "dockets"))
  
  # Format the last modified date with modifier if present
  lastModifiedDate_param <- if (!is.null(lastModifiedDate_mod)) {
    paste0("filter[lastModifiedDate][", lastModifiedDate_mod, "]")
  } else {
    "filter[lastModifiedDate]"
  }
  
  # Query parameters
  query <- list(
    `filter[searchTerm]` = searchTerm,
    `filter[agencyId]` = agencyId,
    `filter[lastModifiedDate]` = format_date(lastModifiedDate),
    `filter[docketId]` = if (endpoint == "documents") docketId,
    `filter[commentOnId]` = if (endpoint == "comments") commentOnId,
    `filter[docketType]` = if (endpoint == "dockets") docketType,
    `page[size]` = 250,
    `page[number]` = page,
    `sort` = "-lastModifiedDate",
    `api_key` = api_key
  )
  
  #correct parameter name for lastModifiedDate
  names(query)[3] <- lastModifiedDate_param
  
  # Remove NULL parameters
  query <- Filter(Negate(is.null), query)
  
  # Construct final URL 
  paste0(base_url, endpoint, "?", paste0(names(query), "=", unlist(query), collapse = "&"))
}
