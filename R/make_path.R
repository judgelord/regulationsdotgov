# a function to make an api path from an id for get_details functions

make_path <- function(id, api_key){
  path = paste0("https://api.regulations.gov/v4/comments/",
                id,
                "?",
                "include=attachments&",
                "api_key=", api_key)
  return(path)
}
