\name{get_dockets}
\alias{get_dockets}
\title{
Retrieve Dockets from a Government Agency
}
\description{
Fetches docket information from a specified government agency using the regulations.gov API. 
This function returns a data frame containing docket details based on specified filters.
}
\usage{
get_dockets(agency, lastModifiedDate = Sys.time(), 
            lastModifiedDate_mod = "le", docketType = NULL, 
            api_keys)
}
\arguments{
  \item{agency}{
A character string containing the agency acronym. 
Must match official agency acronyms used on regulations.gov 
(e.g., "EPA", "FCC", "CMS").
}
  \item{lastModifiedDate}{
Filter dockets by their last modified date. Default is current system time.
Format must be: \code{"yyyy-MM-ddHH:mm:ss"} 
(e.g., "2024-01-0100:00:00" for January 1, 2024).
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
  \item{docketType}{
Optional filter for docket type. Filter by specific docket categories 
(e.g., "Rulemaking", "Nonrulemaking"). See regulations.gov 
documentation for valid types.
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
# Basic usage with EPA
epa_dockets <- get_dockets("EPA", api_keys = "DEMO_KEY")

# Filter by date (dockets modified since January 1, 2024)
recent_dockets <- get_dockets("FCC", 
                              lastModifiedDate = "2024-01-01\%2000:00:00",
                              lastModifiedDate_mod = "ge")

# Filter by docket type with specific date range
rulemaking_dockets <- get_dockets("CMS",
                                  lastModifiedDate = "2024-06-01\%2000:00:00",
                                  lastModifiedDate_mod = "ge",
                                  docketType = "Rulemaking")

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_dockets("EPA", api_keys = keys)
}
}
