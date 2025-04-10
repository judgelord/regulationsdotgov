# a function to make an api path from an id for get_details functions
#' @keywords internal

make_path_document_details <- function(id, api_key){
  path = paste0("https://api.regulations.gov/v4/documents/",
                id,
                "?",
                "include=attachments&",
                "api_key=", api_key)
  return(path)
}
