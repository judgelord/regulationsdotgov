# regulationsdotgov


<!-- README.md is generated from README.Rmd. Please edit that file -->

Get data from regulations.gov

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of regulationsdotgov from
[GitHub](https://github.com/) with:

``` r
if (!requireNamespace('pak')) install.packages('pak')
pak::pak("judgelord/regulationsdotgov")
```

``` r
library(regulationsdotgov)
```

## Metadata

Regulations.gov metadata is organized in a hierarchical database.

**Agencies**
  ¦ 
  ¦-- **Dockets** are “folders” where agencies keep documents for each
        ¦     policymaking process (including rulemaking and non-rulemaking dockets)
        ¦
        ¦-- **Documents** (including proposed rules, rules, and supplementary materials)
              ¦  
              ¦-- **Comments** on those documents (high-level metadata)
                    ¦  
                    ¦-- **Comment Details** for each comment (detailed metadata)

The `regulationsdotgov` package is organized with a parallel set of
functions to retrieve metadata:

#### Get dockets from an agency

-   `get_dockets("[agency_acronym]")` retrieves dockets for an agency
    (see official acronyms on regulations.gov)

``` r
# you need an API key
source("~/api-key.R")

# get FBI dockets
FBI_dockets <- get_dockets("FBI")

head(FBI_dockets)[[1]]$data # FIXME we should not need the [[1]]$data when this no longer returns a list
```

    #>               id    type attributes.docketType attributes.lastModifiedDate attributes.highlightedContent attributes.agencyId
    #> 1  FBI-2024-0001 dockets            Rulemaking        2024-07-26T09:29:34Z                            NA                 FBI
    #> 2  FBI-2023-0001 dockets            Rulemaking        2024-01-26T09:17:09Z                            NA                 FBI
    #> 3 FBI_FRDOC_0001 dockets            Rulemaking        2023-08-25T08:08:48Z                            NA                 FBI
    #> 4  FBI-2013-0001 dockets            Rulemaking        2021-05-02T01:06:49Z                            NA                 FBI
    #> 5  FBI-2008-0001 dockets            Rulemaking        2021-05-02T01:06:49Z                            NA                 FBI
    #> 6  FBI-2008-0003 dockets         Nonrulemaking        2021-05-02T01:06:49Z                            NA                 FBI
    #> 7  FBI-2016-0001 dockets            Rulemaking        2021-05-02T01:06:49Z                            NA                 FBI
    #> 8  FBI-2008-0002 dockets            Rulemaking        2014-11-05T13:55:47Z                            NA                 FBI
    #> 9  FBI-2011-0001 dockets            Rulemaking        2011-11-08T11:21:06Z                            NA                 FBI
    #>                                                                                                    attributes.title attributes.objectId                                                  self
    #> 1 Bipartisan Safer Communities Act -- Access to Records of Stolen Firearms in the National Crime Information Center    0b000064865d93e3  https://api.regulations.gov/v4/dockets/FBI-2024-0001
    #> 2                                   Child Protection Improvements Act Criteria for Designated Entity Determinations    0b00006485f05dad  https://api.regulations.gov/v4/dockets/FBI-2023-0001
    #> 3                                                                            Recently Posted FBI Rules and Notices.    0b00006481939821 https://api.regulations.gov/v4/dockets/FBI_FRDOC_0001
    #> 4                                                              National Instant Criminal Background\r\nCheck System    0b000064811e5c8c  https://api.regulations.gov/v4/dockets/FBI-2013-0001
    #> 5                                                      FBI Criminal Justice Information Services Division User Fees    0b0000648062f3e1  https://api.regulations.gov/v4/dockets/FBI-2008-0001
    #> 6                                     FBI Records Management Division National Name Check Program Section User Fees    0b000064807284a0  https://api.regulations.gov/v4/dockets/FBI-2008-0003
    #> 7                                                                     National Environmental Policy Act\nProcedures    0b0000648201ffea  https://api.regulations.gov/v4/dockets/FBI-2016-0001
    #> 8                                                          National Motor Vehicle Title Information System (NMVTIS)    0b0000648071e23f  https://api.regulations.gov/v4/dockets/FBI-2008-0002
    #> 9                                                  Federal Bureau of Investigation Anti-Piracy Warning Seal Program    0b00006480f1cd29  https://api.regulations.gov/v4/dockets/FBI-2011-0001

#### Get documents from a docket folder

-   `get_documents("[docket_id]")` retrieves documents for a docket

#### Get metadata for comments on a document or docket

-   `get_comments_on_docket("[docket_id]")` retrieves all comments for a
    docket (e.g., including an Advanced Notice of Proposed Rulemaking
    and all draft proposed rules)

-   `get_comments_on_document("[document_id]")` retrieves comments on a
    specific document (e.g., a specific proposed rule)

#### Get detailed metadata about a comment

`get_comment_details("[comment_id]")` retrieves comments on a specific
document (e.g., a specific proposed rule)

## Search

The package also contains functions to use the API’s search function to
search the text of documents or comments:

-   `get_searchTerm(searchTerm = "[searchTerm]", documents = c("documents", "comments"), agency_acronym = c("all", "[agency_acronym]"), docket_id = c("all", "[docket_id]"), document_id = c("all", "[document_id]")  )`

## Download

Finally, using URLs returned from `get_documents()` and
`get_comment_details()`, we can download files (e.g., pdfs)

-   `download_regulationsdotgov("[url]")` saves local copies of desired
    files in a standard file structure mirroring that above in a “files”
    folder:
    “files/agency_acronym/docket_id/document_id/document_name.extension”
    (e.g., “files/ACF/ACF-2009-0005/ACF-2009-0005-0018_1.doc” is a
    public comment on ACF Notice ACF-2009-0005-0002. This notice is
    located at “files/ACF/ACF-2009-0005/ACF-2009-0005-0002.pdf”)

To specify your own file structure, simply use the base download
function

-   `download.file(url = "[url]", destfile = "[path]")`

## Important notes

-   To use `regulationsdotgov,` you will need an API key. These keys
    have limits. You can request a rate increase.

-   The functions are currently built with the theory that the user
    wants all results for a given agency/docket/document. While not
    highlighted in the documentation, a user can limit the search to
    results *before* a given date with a `lastModifiedDate` argument
    (API calls are curently hard-coded to be in decending order). In the
    future, we will add more options to restrict results to a given
    timeframe.
