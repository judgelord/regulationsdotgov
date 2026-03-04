# A Capitalized Title (ideally limited to 65 characters)

## Usage

``` r
get_comment_details(id, lastModifiedDate = Sys.time(), api_keys = keys)
```

## Arguments

- id:

- lastModifiedDate:

- api_keys:

## Details

## Value

## References

## Author

## Note

## See also

## Examples

``` r
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--  or standard data sets, see data().

## The function is currently defined as
function (id, lastModifiedDate = Sys.time(), api_keys = keys) 
{
    if (length(id) != length(unique(id))) {
        message("Duplicate ids dropped to save API calls (result will be shorter than length of input id vector)")
    }
    message("Trying: ", make_path_comment_details(id[1], "XXXXXXXXXXXXXX"))
    unique_ids <- unique(id)
    message("| Comment details | input N = ", length(id), " | output N = ", 
        length(unique_ids), " | \n| --- | --- | --- | ")
    temp_file <- tempfile(pattern = "comment_details_content_", 
        fileext = ".rda")
    success <- FALSE
    on.exit({
        if (!success && exists("content")) {
            metadata <- dplyr::select(purrr::map_dfr(content, 
                ~{
                  attrs <- as.data.frame(purrr::map(purrr::pluck(.x, 
                    "data", "attributes"), ~if (is.null(.x)) NA else .x))
                  attrs$id <- purrr::pluck(.x, "data", "id")
                  attrs
                }), where(~!all(is.na(.x))))
            save(metadata, file = temp_file)
            message("\nFunction failed - saved content to temporary file: ", 
                temp_file)
            message("To load: load('", temp_file, "')")
        }
    })
    content <- vector("list", length(unique_ids))
    for (i in seq_along(unique_ids)) {
        tryCatch({
            content[[i]] <- get_comment_details_content(unique_ids[i], 
                api_keys = api_keys)
        }, error = function(e) {
            message("Error for id ", unique_ids[i], ": ", e$message)
            content[[i]] <<- NULL
        })
    }
    nulls <- vapply(content, is.null, logical(1))
    if (sum(nulls) > 0) {
        message(paste("Errors for ids:", paste(unique_ids[nulls], 
            collapse = ",")))
    }
    content <- content[!nulls]
    if (length(content) == 0) {
        warning("No valid comments retrieved")
        return(NULL)
    }
    metadata <- dplyr::select(purrr::map_dfr(content, extract_attrs), 
        where(~!all(is.na(.x))))
    metadata <- dplyr::distinct(metadata)
    success <- TRUE
    return(metadata)
  }
#> function (id, lastModifiedDate = Sys.time(), api_keys = keys) 
#> {
#>     if (length(id) != length(unique(id))) {
#>         message("Duplicate ids dropped to save API calls (result will be shorter than length of input id vector)")
#>     }
#>     message("Trying: ", make_path_comment_details(id[1], "XXXXXXXXXXXXXX"))
#>     unique_ids <- unique(id)
#>     message("| Comment details | input N = ", length(id), " | output N = ", 
#>         length(unique_ids), " | \n| --- | --- | --- | ")
#>     temp_file <- tempfile(pattern = "comment_details_content_", 
#>         fileext = ".rda")
#>     success <- FALSE
#>     on.exit({
#>         if (!success && exists("content")) {
#>             metadata <- dplyr::select(purrr::map_dfr(content, 
#>                 ~{
#>                   attrs <- as.data.frame(purrr::map(purrr::pluck(.x, 
#>                     "data", "attributes"), ~if (is.null(.x)) NA else .x))
#>                   attrs$id <- purrr::pluck(.x, "data", "id")
#>                   attrs
#>                 }), where(~!all(is.na(.x))))
#>             save(metadata, file = temp_file)
#>             message("\nFunction failed - saved content to temporary file: ", 
#>                 temp_file)
#>             message("To load: load('", temp_file, "')")
#>         }
#>     })
#>     content <- vector("list", length(unique_ids))
#>     for (i in seq_along(unique_ids)) {
#>         tryCatch({
#>             content[[i]] <- get_comment_details_content(unique_ids[i], 
#>                 api_keys = api_keys)
#>         }, error = function(e) {
#>             message("Error for id ", unique_ids[i], ": ", e$message)
#>             content[[i]] <<- NULL
#>         })
#>     }
#>     nulls <- vapply(content, is.null, logical(1))
#>     if (sum(nulls) > 0) {
#>         message(paste("Errors for ids:", paste(unique_ids[nulls], 
#>             collapse = ",")))
#>     }
#>     content <- content[!nulls]
#>     if (length(content) == 0) {
#>         warning("No valid comments retrieved")
#>         return(NULL)
#>     }
#>     metadata <- dplyr::select(purrr::map_dfr(content, extract_attrs), 
#>         where(~!all(is.na(.x))))
#>     metadata <- dplyr::distinct(metadata)
#>     success <- TRUE
#>     return(metadata)
#> }
#> <environment: 0x55a521ec7108>
```
