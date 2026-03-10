# Save Docket Metadata to Local Directory

Retrieves docket metadata for specified agency(ies) and saves it to a
structured local directory. Creates an organized folder system for
storing and managing regulatory data over time.

## Usage

``` r
save_dockets(agency, api_keys)
```

## Arguments

- agency:

  A character string containing the agency acronym. Must match official
  agency acronyms used on regulations.gov (e.g., "EPA", "FCC", "CMS").

- api_keys:

  Character string or vector containing API key(s) from api.data.gov. If
  multiple keys are provided, the function will cycle through them to
  manage rate limits.

## Details

The function uses
[`get_dockets`](https://judgelord.github.io/regulationsdotgov/reference/get_dockets.md)
internally to fetch the latest docket metadata, so you will need to have
an API key.

## Value

Stores data as a .rmd file.
