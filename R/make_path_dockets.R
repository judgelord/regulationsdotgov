#' @keywords internal

make_path_dockets <- function(agency, 
                              lastModifiedDate,
                              page,
                              api_key){

  paste0("https://api.regulations.gov",
         "/v4/",
         "dockets",
         "?",
         "filter[agencyId]=", agency, "&",
         "filter[lastModifiedDate][le]=", format_date(lastModifiedDate), "&", #less than or equal to (vs [ge] in the api docs)
         "page[size]=250", "&",
         "page[number]=", page, "&", 
         "sort=-lastModifiedDate", "&",
         "api_key=", api_key)
}



