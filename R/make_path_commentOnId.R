#' @keywords internal

make_path_commentOnId <- function(objectId = NULL, 
                                  agencyId = NULL,
                                  lastModifiedDate,
                                  lastModifiedDate_mod = "le", #c("le", "ge", "NULL")
                                  page,
                                  api_key) {
  
  # Base URL 
  base_url <- "https://api.regulations.gov/v4/comments"
  
  # Format the last modified date with modifier if present
  lastModifiedDate_param <- if (!is.null(lastModifiedDate_mod)) {
    paste0("filter[lastModifiedDate][", lastModifiedDate_mod, "]")
  } else {
    "filter[lastModifiedDate]"
  }
  
  # Query parameters
  query <- list(
    `filter[agencyId]` = agencyId,
    `filter[commentOnId]` = objectId,
    `filter[lastModifiedDate]` = format_date(lastModifiedDate),
    `page[size]` = 250,
    `page[number]` = page,
    `sort` = "-lastModifiedDate",
    `api_key` = api_key)
  
  #correct parameter name for lastModifiedDate
  names(query)[3] <- lastModifiedDate_param
  
  # Remove NULL parameters
  query <- Filter(Negate(is.null), query)
  
  # Construct final URL 
  paste0(base_url, "?", paste0(names(query), "=", unlist(query), collapse = "&"))
}

