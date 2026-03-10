\name{get_documents}
\alias{get_documents}
\title{
Retrieve Documents from a Docket or Agency
}
\description{
Fetches document metadata from regulations.gov. Can retrieve all documents 
within a specific docket or all documents belonging to an agency. Returns a 
data frame containing document details based on specified filters.
}
\usage{
get_documents(agencyId = NULL, docketId = NULL, 
              lastModifiedDate = Sys.time(), 
              lastModifiedDate_mod = "le", documentType = NULL, 
              api_keys)
}
\arguments{
  \item{agencyId}{
Optional character string containing the agency acronym. 
Can be used alone to retrieve all documents from an agency, 
or in combination with \code{docketId} to filter documents within a 
specific docket. Must match official agency acronyms used on 
regulations.gov (e.g., "EPA", "FCC", "CMS").
}
  \item{docketId}{
Optional character string containing the docket ID. 
When provided alone or with \code{agencyId}, returns all documents 
belonging to the specified docket.
}
  \item{lastModifiedDate}{
Filter documents by their last modified date. Default is current system time.
Format must be: \code{"yyyy-MM-dd\%20HH:mm:ss"} 
(e.g., "2024-01-01\%2000:00:00" for January 1, 2024).
}
  \item{lastModifiedDate_mod}{
Modifier for the date filter.
Acceptable values:
\describe{
  \item{"le"}{Less than or equal to (default)}
  \item{"ge"}{Greater than or equal to}
  \item{NULL}{Collects results for a single exact date match}
}
}
  \item{documentType}{
Optional filter for document type. Filter by specific document categories 
(e.g., "Notice", "Rule", "Proposed Rule", "Supporting & Related Material"). 
See regulations.gov documentation for valid types.
}
  \item{api_keys}{
Character string or vector containing API key(s) from api.data.gov. 
If multiple keys are provided, the function will cycle through them 
to manage rate limits.
}
}
\references{
Regulations.gov API Documentation: 
\url{https://open.gsa.gov/api/regulationsgov/}

Agency Acronym List: 
\url{https://www.regulations.gov/agencies}
}
\examples{
\dontrun{
# Basic usage - get all documents from a specific docket
docket_docs <- get_documents(docketId = "EPA-HQ-OPP-2023-0123", 
                            api_keys = "DEMO_KEY")

# Get all documents from an agency
epa_documents <- get_documents(agencyId = "EPA", api_keys = "DEMO_KEY")

# Filter by date (documents modified since January 1, 2024)
recent_docs <- get_documents(agencyId = "FCC", 
                            lastModifiedDate = "2024-01-01\%2000:00:00",
                            lastModifiedDate_mod = "ge")

# Filter by document type within a specific docket
proposed_rules <- get_documents(docketId = "CMS-2024-0012",
                               documentType = "Proposed Rule",
                               lastModifiedDate = "2024-06-01\%2000:00:00",
                               lastModifiedDate_mod = "ge")

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_documents(agencyId = "EPA", api_keys = keys)
}
}