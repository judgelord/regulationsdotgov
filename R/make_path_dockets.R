make_path_dockets <- function(agency, 
                              lastModifiedDate, 
                              api_key){

  paste0("https://api.regulations.gov",
         "/v4/",
         "dockets",
         "?",
         "filter[agencyId]=", agency, "&",
         "filter[lastModifiedDate][le]=", lastModifiedDate, "&", #less than or equal to (vs [ge] in the api docs)
         "page[size]=250", "&",
         "page[number]=", 1:20, "&", #FIXME replace with 2 with 20 when done testing
         "sort=-lastModifiedDate", "&",
         "api_key=", api_key)
}



