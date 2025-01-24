#' @export
#' Need to add api key argument to function

save_dockets <- function(agency){
  
  # Ensure the agency directory exists
  agency_dir <- here::here("data", agency)
  
  if (!dir.exists(agency_dir)) {
    dir.create(agency_dir, recursive = TRUE)
  }

  # Retrieve the dockets
  dockets <- map_dfr(agency, get_dockets, api_keys = api_keys)

  # Print the size of the dockets for debugging
  message(paste("|", agency, "| n =", nrow(dockets), "|"))
  
  # Save the dockets to the corresponding file
  save(dockets, file = file.path(agency_dir, paste0(agency, "_dockets.rda")))
}
