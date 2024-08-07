#############################################
# HELPER FUNCTION THAT FORMATS SYSTEM TIME #
############################################


format_date <- function(lastModifiedDate){
  
  timezone <- base::format(lastModifiedDate, format="%Z")
  
  # Convert to POSIXct
  date_posixct <- as.POSIXct(lastModifiedDate, format = "%Y-%m-%d %H:%M:%S", tz = "EDT")
  
  # Convert to UTC
  date_utc <- format(date_posixct, tz = "UTC", usetz = FALSE)
  
  # Format spaces
  formatted_date <- gsub(" ", "%20", date_utc)
    
  return(formatted_date)                   
}

