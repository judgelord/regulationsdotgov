\name{save_dockets}
\alias{save_dockets}
\title{
Save Docket Metadata to Local Directory
}
\description{
Retrieves docket metadata for specified agency(ies) and saves it to a structured 
local directory. Creates an organized folder system for storing and managing 
regulatory data over time.
}
\usage{
save_dockets(agency, api_keys)
}
\arguments{
  \item{agency}{
A character string containing the agency acronym. 
Must match official agency acronyms used on regulations.gov 
(e.g., "EPA", "FCC", "CMS").
}
  \item{api_keys}{
Character string or vector containing API key(s) from api.data.gov. 
If multiple keys are provided, the function will cycle through them 
to manage rate limits.
}
}
\details{
The function uses \code{\link{get_dockets}} internally to fetch the latest 
docket metadata, so you will need to have an API key.
}
\value{
Stores data as a .rmd file. 
}

