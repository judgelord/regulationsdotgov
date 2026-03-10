\name{get_comment_details}
\alias{get_comment_details}
\title{
Retrieve Full Comment Details and Content
}
\description{
Fetches complete comment details and content from regulations.gov using 
comment IDs. Returns a data frame containing the full text, metadata, 
and attachment information for each requested comment.
}
\usage{
get_comment_details(id, lastModifiedDate = Sys.time(), api_keys)
}
\arguments{
  \item{id}{
Character string or vector containing comment ID(s) obtained from 
\code{\link{get_commentsOnId}} or other search functions. 
Duplicate IDs are automatically removed to optimize API usage.
}
  \item{lastModifiedDate}{
Filter comments by their last modified date. Default is current system time.
Format must be: \code{"yyyy-MM-dd\%20HH:mm:ss"} 
(e.g., "2024-01-01\%2000:00:00" for January 1, 2024).
}
  \item{api_keys}{
Character string or vector containing API key(s) from api.data.gov. 
If multiple keys are provided, the function will cycle through them 
to manage rate limits.
}
}
\details{
This function retrieves the full content of public comments, including the 
comment text, submitter information, and any attachments. Unlike 
\code{\link{get_commentsOnId}} which returns only metadata, this function 
fetches the complete comment details from the regulations.gov API.

If the function encounters errors during execution, it will save successfully 
retrieved comments to a temporary .rda file and provide the file path for 
recovery.
}
\references{
Regulations.gov API Documentation: 
\url{https://open.gsa.gov/api/regulationsgov/}
}
\examples{
\dontrun{
# Get details for a single comment using its ID
comment_details <- get_comment_details(
  id = "FBI-2024-0001-0002", 
  api_keys = "DEMO_KEY"
)

# View the full comment text
cat(comment_details$comment)

# Get details for multiple comments
comment_ids <- c("FBI-2024-0001-0002", "FBI-2024-0001-0005", 
                 "FBI-2024-0001-0007")
                 
multiple_comments <- get_comment_details(
  id = comment_ids, 
  api_keys = "DEMO_KEY"
)

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_comment_details(
  id = comment_ids, 
  api_keys = keys
)

# Typical workflow: get metadata first, then full details
# Get metadata for comments on a document
metadata <- get_commentsOnId(objectId = "09000064865d514a", 
                            api_keys = "DEMO_KEY")
# Then fetch full details for specific comments of interest
detailed <- get_comment_details(
  id = metadata$id[1:10],  # First 10 comments
  api_keys = "DEMO_KEY"
)
}
}

