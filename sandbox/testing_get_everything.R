

agencies <- c("BIA", "IHS")

walk(here::here("data", agencies), dir.create)

dockets <- map_dfr(agencies, get_dockets) # retrieves dockets for an agency (see official acronyms on regulations.gov)

walk(here::here("data", dockets$docket_id), dir.create)

#### Get documents from each docket folder

save_documents <- function(docket){
  documents <- map_dfr(docket, get_documents)
  save(documents, here::here("data",
                             str_extract("[A-Z]+)", docket), # agency
                             docket,
                             "documents.rda"
                             )
  )
}

walk(dockets, save_documents)

documents <- map_dfr(dockets$docket_id, get_documents) # retrieves documents for a docket

save(here::here("data", "documents.rda"))


#### Get metadata for comments on a document or docket

get_comments_on_docket("[docket_id]") # retrieves all comments for a docket (e.g., including an Advanced Notice of Proposed Rulemaking and all draft proposed rules)

save_comments <- function(docket){
  comments <- map_dfr(docket, get_comments_on_docket)
  save(comments, here::here("data",
                             str_extract("[A-Z]+)", docket), # agency
                             docket,
                            "comments.rda"
  )
  )
}

walk(dockets, save_comments)



get_commentsOnId("[document_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)

#### Get detailed metadata about a comment

get_comment_details("[comment_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)


save_comment_details <- function(docket){
  comments <- map_dfr(docket, get_comments_on_docket)
  comment_details <- get_comment_details(comments$document_id)

  save(comment_details, here::here("data",
                            str_extract("[A-Z]+)", docket), # agency
                            docket,
                            "comment_details.rda"
  )
  )
}

walk(dockets, save_comment_details)

# DOWNLOAD

