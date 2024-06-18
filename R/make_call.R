
make_call <- function(urls){
  
  result <- GET(url)
  
  if (result$status_code == 200) {
    metadata <- fromJSON(rawToChar(result$content))
    
    d <- make_comment_dataframe(metadata)
    
    lastpage <- metadata$meta$lastPage
    
    return(d)
  } else {
    return(NULL)
  }
}


