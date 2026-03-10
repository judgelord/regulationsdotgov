# Retrieve Documents from a Docket or Agency

Fetches document metadata from regulations.gov. Can retrieve all
documents within a specific docket or all documents belonging to an
agency. Returns a data frame containing document details based on
specified filters.

## Usage

``` r
get_documents(agencyId = NULL, docketId = NULL, 
              lastModifiedDate = Sys.time(), 
              lastModifiedDate_mod = "le", documentType = NULL, 
              api_keys)
```

## Arguments

- agencyId:

  Optional character string containing the agency acronym. Can be used
  alone to retrieve all documents from an agency, or in combination with
  `docketId` to filter documents within a specific docket. Must match
  official agency acronyms used on regulations.gov (e.g., "EPA", "FCC",
  "CMS").

- docketId:

  Optional character string containing the docket ID. When provided
  alone or with `agencyId`, returns all documents belonging to the
  specified docket.

- lastModifiedDate:

  Filter documents by their last modified date. Default is current
  system time. Format must be: `"yyyy-MM-dd%20HH:mm:ss"` (e.g.,
  "2024-01-01%2000:00:00" for January 1, 2024).

- lastModifiedDate_mod:

  Modifier for the date filter. Acceptable values:

  "le"

  :   Less than or equal to (default)

  "ge"

  :   Greater than or equal to

  NULL

  :   Collects results for a single exact date match

- documentType:

  Optional filter for document type. Filter by specific document
  categories (e.g., "Notice", "Rule", "Proposed Rule", "Supporting &
  Related Material"). See regulations.gov documentation for valid types.

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
# Basic usage - get all documents from a specific docket
docket_docs <- get_documents(docketId = "EPA-HQ-OPP-2023-0123", 
                            api_keys = "DEMO_KEY")

# Get all documents from an agency
epa_documents <- get_documents(agencyId = "EPA", api_keys = "DEMO_KEY")

# Filter by date (documents modified since January 1, 2024)
recent_docs <- get_documents(agencyId = "FCC", 
                            lastModifiedDate = "2024-01-01%2000:00:00",
                            lastModifiedDate_mod = "ge")

# Filter by document type within a specific docket
proposed_rules <- get_documents(docketId = "CMS-2024-0012",
                               documentType = "Proposed Rule",
                               lastModifiedDate = "2024-06-01%2000:00:00",
                               lastModifiedDate_mod = "ge")

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_documents(agencyId = "EPA", api_keys = keys)
} # }
```
