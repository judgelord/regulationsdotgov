#' @keywords internal

make_path_dockets <- function(agency,
                                 lastModifiedDate,
                                 lastModifiedDate_mod = "le", #c("le", "ge", "NULL")
                                 docketType = NULL, #c("Rulemaking", "Nonrulemaking")
                                 page,
                                 api_key) {
  
  # Base URL 
  base_url <- "https://api.regulations.gov/v4/dockets"
  
  # Format the last modified date with modifier if present
  lastModifiedDate_param <- if (!is.null(lastModifiedDate_mod)) {
    paste0("filter[lastModifiedDate][", lastModifiedDate_mod, "]")
  } else {
    "filter[lastModifiedDate]"
  }
  
  # Query parameters
  query <- list(
    `filter[agencyId]` = agency,
    `filter[lastModifiedDate]` = format_date(lastModifiedDate),
    `filter[docketType]` = docketType,
    `page[size]` = 250,
    `page[number]` = page,
    `sort` = "-lastModifiedDate",
    `api_key` = api_key
  )
  
  #correct parameter name for lastModifiedDate
  names(query)[2] <- lastModifiedDate_param
  
  # Remove NULL parameters
  query <- Filter(Negate(is.null), query)
  
  # Construct final URL with proper encoding
  paste0(base_url, "?", paste0(names(query), "=", unlist(query), collapse = "&"))
}
