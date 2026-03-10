\name{get_document_details}
\alias{get_document_details}
\title{
Retrieve Full Document Details and Metadata
}
\description{
Fetches complete document details and metadata from regulations.gov using 
document IDs. Returns a data frame containing the full document information,
including title, abstract, dates, and all associated metadata fields.
}
\usage{
get_document_details(id, lastModifiedDate = Sys.time(), api_keys)
}
\arguments{
  \item{id}{
Character string or vector containing document ID(s) obtained from 
\code{\link{get_documents}} or other search functions. 
Duplicate IDs are automatically removed to optimize API usage.
}
  \item{lastModifiedDate}{
Filter documents by their last modified date. Default is current system time.
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
This function retrieves the complete metadata for regulatory documents, 
including Federal Register notices, proposed rules, final rules, and 
supporting materials. Unlike \code{\link{get_documents}} which returns 
summary information, this function fetches the full detailed record from 
the regulations.gov API.

If the function encounters errors during execution, it will save successfully 
retrieved documents to a temporary .rda file and provide the file path for 
recovery.
}
\references{
Regulations.gov API Documentation: 
\url{https://open.gsa.gov/api/regulationsgov/}
}
\examples{
\dontrun{
# Get details for a single document using its ID
doc_details <- get_document_details(
  id = "EPA-HQ-OAR-2025-1806-0001", 
  api_keys = "DEMO_KEY"
)

# View the document abstract
cat(doc_details$abstract)

# Get details for multiple documents
doc_ids <- c("EPA-HQ-OAR-2025-1806-0001", 
             "ED-2022-OPE-0157-0001")
             
multiple_docs <- get_document_details(
  id = doc_ids, 
  api_keys = "DEMO_KEY"
)

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_document_details(
  id = doc_ids, 
  api_keys = keys
)

# Typical workflow: get summary first, then full details
# Get summary metadata for all documents in a docket
summary <- get_documents(docketId = "ED-2022-OPE-0157", 
                        api_keys = "DEMO_KEY")
                        
# Then fetch full details for specific documents of interest
detailed <- get_document_details(
  id = summary$id, 
  api_keys = "DEMO_KEY"
)
}
}
