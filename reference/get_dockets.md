# Get dockets from an agency

get_dockets("\[agency_acronym\]") retrieves dockets for an agency

## Usage

``` r
get_dockets(agency, lastModifiedDate = Sys.time(), api_keys)
```

## Arguments

- agency:

  Agency acronym (see official acronyms on regulations.gov)

- lastModifiedDate:

  Filter results by their last modified date. Default is set to
  [`Sys.time()`](https://rdrr.io/r/base/Sys.time.html).

  User-specified values must be formatted as `yyyy-MM-dd%20HH:mm:ss`.

- api_keys:

  API key(s) from api.data.gov.

## Details

## Value

## References

## Author

## Note

## See also

## Examples

``` r
# FBI_dockets <- get_dockets(agency = "FBI", api_keys = "DEMO_KEY") 

# head(FBI_dockets)

# A tibble: 6 × 8
#   docketType    lastModifiedDate     highlightedContent agencyId title                objectId id    lastpage
#   <chr>         <chr>                <lgl>              <chr>    <chr>                <chr>    <chr> <lgl>   
# 1 Rulemaking    2024-08-26T13:14:32Z NA                 FBI      "Bipartisan Safer C… 0b00006… FBI-… TRUE    
# 2 Rulemaking    2024-08-26T13:13:45Z NA                 FBI      "Child Protection I… 0b00006… FBI-… TRUE    
# 3 Rulemaking    2023-08-25T08:08:48Z NA                 FBI      "Recently Posted FB… 0b00006… FBI_… TRUE    
# 4 Rulemaking    2021-05-02T01:06:49Z NA                 FBI      "National Instant C… 0b00006… FBI-… TRUE    
# 5 Rulemaking    2021-05-02T01:06:49Z NA                 FBI      "FBI Criminal Justi… 0b00006… FBI-… TRUE    
# 6 Nonrulemaking 2021-05-02T01:06:49Z NA                 FBI      "FBI Records Manage… 0b00006… FBI-… TRUE 


##{DELETE?}
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--  or standard data sets, see data().

## The function is currently defined as
#function (agency, lastModifiedDate = Sys.time()) 
#{
#    lastModifiedDate <- lastModifiedDate %>% ymd_hms() %>% with_tz(tzone = "America/New_York") %>% 
#        gsub(" ", "%20", .) %>% str_remove("\..*")
#    path <- make_path_dockets(agency, lastModifiedDate)
#    result <- purrr::map(path, GET)
#    status <<- tail(map(result, status_code), 1) %>% as.numeric()
#    url <- result[[20]][1]$url
#    if (status != 200) {
#        message(paste(format(Sys.time(), "%X"), "| Status", status, 
#            "| URL:", url))
#        Sys.sleep(6)
#    }
#    remaining <<- pluck(tail(map(result, headers), 1), 1, "x-ratelimit-remaining")
#    if (remaining < 2) {
#        message(paste(format(Sys.time(), "%X"), "- Hit rate limit, will continue after one minute"))
#        Sys.sleep(60)
#    }
#    docket_metadata <- purrr::map_if(result, ~status_code(.x) == 
#        200, ~fromJSON(rawToChar(.x$content)))
#    return(docket_metadata)
#  }
#
```
