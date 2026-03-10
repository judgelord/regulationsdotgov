# Retrieve Dockets from a Government Agency

Fetches docket information from a specified government agency using the
regulations.gov API. This function returns a data frame containing
docket details based on specified filters.

## Usage

``` r
get_dockets(agency, lastModifiedDate = Sys.time(), 
            lastModifiedDate_mod = "le", docketType = NULL, 
            api_keys)
```

## Arguments

- agency:

  A character string containing the agency acronym. Must match official
  agency acronyms used on regulations.gov (e.g., "EPA", "FCC", "CMS").

- lastModifiedDate:

  Filter dockets by their last modified date. Default is current system
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

- docketType:

  Optional filter for docket type. Filter by specific docket categories
  (e.g., "Rulemaking", "Nonrulemaking"). See regulations.gov
  documentation for valid types.

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
# Basic usage with EPA
epa_dockets <- get_dockets("EPA", api_keys = "DEMO_KEY")

# Filter by date (dockets modified since January 1, 2024)
recent_dockets <- get_dockets("FCC", 
                              lastModifiedDate = "2024-01-01%2000:00:00",
                              lastModifiedDate_mod = "ge")

# Filter by docket type with specific date range
rulemaking_dockets <- get_dockets("CMS",
                                  lastModifiedDate = "2024-06-01%2000:00:00",
                                  lastModifiedDate_mod = "ge",
                                  docketType = "Rulemaking")

# Using multiple API keys for higher rate limits
keys <- c("api_key_1", "api_key_2", "api_key_3")
results <- get_dockets("EPA", api_keys = keys)
} # }
```
