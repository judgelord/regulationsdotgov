make_path_searchTerm <- function(searchTerm, 
                                 documents, 
                                 lastModifiedDate = Sys.time(), 
                                 api_keys){
  paste0("https://api.regulations.gov",
         "/v4/",
         ifelse(documents == "comments", "comments", "documents"),
         "?",
         "&filter[searchTerm]=",  str_c("%22", searchTerm, "%22") |> str_replace_all(" ", "%2B"), "&",
         "filter[lastModifiedDate][le]=", lastModifiedDate, "&", #less than or equal to (vs [ge] in the api docs)
         "page[size]=250", "&",
         "page[number]=", 1:20, "&", #FIXME replace with 2 with 20 when done testing
         "sort=-lastModifiedDate,documentId", "&",
         "api_key=", api_key)
}
