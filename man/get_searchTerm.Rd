\name{get_searchTerm}
\alias{get_searchTerm}
\title{
Search Regulations.gov Content by Keyword
}
\description{
Searches for a specific term across regulations.gov content types. 
Returns documents, comments, or dockets that match the search term, 
with optional filters for date, agency, and other parameters.
}
\usage{
get_searchTerm(searchTerm, endpoint, 
               lastModifiedDate = Sys.time(), 
               lastModifiedDate_mod = "le", agencyId = NULL, 
               docketId = NULL, docketType = NULL, 
               commentOnId = NULL, api_keys)
}
\arguments{
  \item{searchTerm}{
A character string containing the term to search for. 
Can include multiple keywords (e.g., "climate change").
URL-encoding is handled automatically by the function.
}
  \item{endpoint}{
Character string specifying the content type to search within.
Valid options:
\describe{
  \item{"documents"}{Search within regulatory documents}
  \item{"comments"}{Search within public comments}
  \item{"dockets"}{Search within docket metadata}
}
}
  \item{lastModifiedDate}{
Filter results by their last modified date. Default is current system time.
Format must be: \code{"yyyy-MM-ddHH:mm:ss"} 
(e.g., "2024-01-0100:00:00" for January 1, 2024).
}
  \item{lastModifiedDate_mod}{
Modifier for the date filter. Acceptable values:
\describe{
  \item{"le"}{Less than or equal to (default)}
  \item{"ge"}{Greater than or equal to}
  \item{NULL}{Collects results for a single exact date match}
}
}
 \item{agencyId}{
Optional character string to filter by agency acronym 
(e.g., "EPA", "FCC", "CMS").
}
  \item{docketId}{
Optional character string to filter by specific docket ID.
Limits search to content within a particular docket.
}
  \item{docketType}{
Optional character string to filter by docket type
(e.g., "Rulemaking", "Nonrulemaking").
}
  \item{commentOnId}{
Optional character string to filter by the document ID that comments
are responding to. Only applicable when \code{endpoint = "comments"}.
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
# Basic search for documents about "climate change"
climate_results <- get_searchTerm("climate change", api_keys = "DEMO_KEY")

# Search for comments containing "pesticide" from EPA
epa_comments <- get_searchTerm("pesticide", 
                               endpoint = "comments", 
                               agencyId = "EPA")

# Search within a specific docket for recent documents
docket_search <- get_searchTerm("safety", 
                               endpoint = "documents",
                               docketId = "EPA-HQ-OPP-2023-0123",
                               lastModifiedDate = "2024-01-01\%2000:00:00",
                               lastModifiedDate_mod = "ge")

# Search for rulemaking dockets about healthcare
healthcare_dockets <- get_searchTerm("healthcare", 
                                    endpoint = "dockets",
                                    docketType = "Rulemaking")

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_searchTerm("air quality", 
                         endpoint = "documents",
                         api_keys = keys)
}
}
