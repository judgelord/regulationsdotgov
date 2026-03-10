# Search Regulations.gov Content by Keyword

Searches for a specific term across regulations.gov content types.
Returns documents, comments, or dockets that match the search term, with
optional filters for date, agency, and other parameters.

## Usage

``` r
get_searchTerm(searchTerm, endpoint, 
               lastModifiedDate = Sys.time(), 
               lastModifiedDate_mod = "le", agencyId = NULL, 
               docketId = NULL, docketType = NULL, 
               commentOnId = NULL, api_keys)
```

## Arguments

- searchTerm:

  A character string containing the term to search for. Can include
  multiple keywords (e.g., "climate change"). URL-encoding is handled
  automatically by the function.

- endpoint:

  Character string specifying the content type to search within. Valid
  options:

  "documents"

  :   Search within regulatory documents

  "comments"

  :   Search within public comments

  "dockets"

  :   Search within docket metadata

- lastModifiedDate:

  Filter results by their last modified date. Default is current system
  time. Format must be: `"yyyy-MM-dd%20HH:mm:ss"` (e.g.,
  "2024-01-01%2000:00:00" for January 1, 2024).

- lastModifiedDate_mod:

  Modifier for the date filter. Acceptable values:

  "le"

  :   Less than or equal to (default)

  "ge"

  :   Greater than or equal to

  NULL

  :   Collects results for a single exact date match

- agencyId:

  Optional character string to filter by agency acronym (e.g., "EPA",
  "FCC", "CMS").

- docketId:

  Optional character string to filter by specific docket ID. Limits
  search to content within a particular docket.

- docketType:

  Optional character string to filter by docket type (e.g.,
  "Rulemaking", "Nonrulemaking").

- commentOnId:

  Optional character string to filter by the document ID that comments
  are responding to. Only applicable when `endpoint = "comments"`.

- api_keys:

  Character string or vector containing API key(s) from api.data.gov. If
  multiple keys are provided, the function will cycle through them to
  manage rate limits.

## References

Regulations.gov API Documentation:
<https://open.gsa.gov/api/regulationsgov/>

Agency Acronym List: <https://www.regulations.gov/agencies>

## Examples

``` r
if (FALSE) { # \dontrun{
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
                               lastModifiedDate = "2024-01-01%2000:00:00",
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
} # }
```
