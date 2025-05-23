#############################################
# HELPER FUNCTION THAT FORMATS SYSTEM TIME #
############################################

#' @keywords internal

format_date <- function(lastModifiedDate){
  
  if(!stringr::str_detect(lastModifiedDate, "[0-9]{4}-[0-9]{2}-[0-9]{2}\\S[0-9]{2}:[0-9]{2}:[0-9]{2}\\S")){
    timezone <- Sys.timezone()
    
    # Convert to POSIXct
    date_posixct <- as.POSIXct(lastModifiedDate, format = "%Y-%m-%d %H:%M:%S", tz = timezone)
    
    # Convert to UTC
    date_utc <- format(date_posixct, tz = "UTC", usetz = FALSE)
    
    # Format spaces
    formatted_date <- gsub(" ", "%20", date_utc)
    
    return(formatted_date)
  }
  
  else{
    formatted_date <- lastModifiedDate |>
      stringr::str_replace("T", "%20") |>
      stringr::str_remove_all("[A-Z]")
    
    return(formatted_date)
  }

}

