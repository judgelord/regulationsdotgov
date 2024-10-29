#' @keywords internal

make_path_commentOnId <- function(commentOnId,
                                  lastModifiedDate,
                                  page,
                                  api_key){
  
  if(stringr::str_detect(commentOnId, "^[A-Z]+")){
  
  paste0("https://api.regulations.gov",
         "/v4/",
         "comments/",
         commentOnId, "?",
         "page[size]=250", "&",
         "page[number]=", page, "&", 
         "api_key=", api_key)
  }
  
  else{
    
    paste0("https://api.regulations.gov",
           "/v4/",
           "comments",
           "?",
           "filter[commentOnId]=", commentOnId, "&",
           "filter[lastModifiedDate][le]=", format_date(lastModifiedDate), "&", #less than or equal to (vs [ge] in the api docs)
           "page[size]=250", "&",
           "page[number]=", page, "&", 
           "sort=-lastModifiedDate,documentId", "&",
           "api_key=", api_key)
  }
}


