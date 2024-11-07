#' @keywords internal

make_path_searchTerm <- function(searchTerm, 
                                 documents, 
                                 lastModifiedDate, 
                                 page,
                                 api_keys){
  paste0("https://api.regulations.gov",
         "/v4/",
         ifelse(documents == "comments", "comments", "documents"),
         "?",
         "&filter[searchTerm]=",  str_c("%22", searchTerm, "%22") |> str_replace_all(" ", "%2B"), "&",
         "filter[lastModifiedDate][le]=", format_date(lastModifiedDate), "&", #less than or equal to (vs [ge] in the api docs)
         "page[size]=250", "&",
         "page[number]=", page, "&", 
         "sort=-lastModifiedDate,documentId", "&",
         "api_key=", api_key)
}
