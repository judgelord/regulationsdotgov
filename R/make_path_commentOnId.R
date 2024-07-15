make_path_commentOnId <- function(commentOnId, lastModifiedDate = Sys.time()){
  paste0("https://api.regulations.gov",
         "/v4/",
         "comments",
         "?",
         "filter[commentOnId]=", commentOnId, "&",
         "filter[lastModifiedDate][le]=", lastModifiedDate, "&", #less than or equal to (vs [ge] in the api docs)
         "page[size]=250", "&",
         "page[number]=", 1:20, "&", #FIXME replace with 2 with 20 when done testing
         "sort=-lastModifiedDate,documentId", "&",
         "api_key=", api_key)
}
