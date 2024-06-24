
make_call <- function(url){
  
  result <- GET(url) # doesn't currently archive API calls before manipulation, just checks if they are successful 
  
  if (result$status_code == 200) {
    metadata <- fromJSON(rawToChar(result$content))
    
    d <- make_comment_dataframe(metadata)
    
    lastpage <- metadata$meta$lastPage
    
    return(d)
  } else {
    return(NULL)
  }
}


