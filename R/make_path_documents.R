#' @keywords internal

make_path_documents <- function(docketId,
                                lastModifiedDate,
                                page,
                                api_key){
              
  if(stringr::str_detect(docketId, "^[A-Z]+$")){
    
    paste0("https://api.regulations.gov",
           "/v4/",
           "documents",
           "?",
           "filter[agencyId]=", docketId, "&",
           "filter[lastModifiedDate][le]=", format_date(lastModifiedDate), "&", #less than or equal to (vs [ge] in the api docs)
           "page[size]=250", "&",
           "page[number]=", page, "&", 
           "sort=-lastModifiedDate,documentId", "&",
           "api_key=", api_key)
  }
  
  else{paste0("https://api.regulations.gov",
         "/v4/",
         "documents",
         "?",
         "filter[docketId]=", docketId, "&",
         "filter[lastModifiedDate][le]=", format_date(lastModifiedDate), "&", #less than or equal to (vs [ge] in the api docs)
         "page[size]=250", "&",
         "page[number]=", page, "&", 
         "sort=-lastModifiedDate,documentId", "&",
         "api_key=", api_key)}
}

