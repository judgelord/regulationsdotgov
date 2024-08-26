#############################################
# HELPER FUNCTION THAT FORMATS SYSTEM TIME #
############################################

format_date <- function(lastModifiedDate){
  
  if(!str_detect(lastModifiedDate, "[0-9]{4}-[0-9]{2}-[0-9]{2}\\S[0-9]{2}:[0-9]{2}:[0-9]{2}\\S")){
    timezone <- base::format(lastModifiedDate, format="%Z")
    
    # Convert to POSIXct
    date_posixct <- as.POSIXct(lastModifiedDate, format = "%Y-%m-%d %H:%M:%S", tz = "EDT")
    
    # Convert to UTC
    date_utc <- format(date_posixct, tz = "UTC", usetz = FALSE)
    
    # Format spaces
    formatted_date <- gsub(" ", "%20", date_utc)
    
    return(formatted_date)
  }
  
  else{
    formatted_date <- lastModifiedDate |>
      str_replace("T", "%20") |>
      str_remove_all("[A-Z]")
    
    return(formatted_date)
  }

}


#TODO DELETE AFTER FINALIZING
#format_date2 <- function(lastModifiedDate){
#
#  formatted_date <- lastModifiedDate |>
#    str_replace("T", "%20") |>
#    str_remove_all("[A-Z]")
#
#  return(formatted_date)
#}
#
#lastModifiedDate = Sys.time()
#lastModifiedDate <- "2023-06-16T18:12:27Z"
#
#str_detect(lastModifiedDate, "[0-9]{4}-[0-9]{2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}\s[A-Z]{3}")
#str_detect(lastModifiedDate, "[0-9]{4}-[0-9]{2}-[0-9]{2}\\S[0-9]{2}:[0-9]{2}:[0-9]{2}\\S")


