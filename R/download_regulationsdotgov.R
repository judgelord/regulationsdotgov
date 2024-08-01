
download_regulationsdotgov <- function(url, dir){

  d <- tibble::tibble(
    url = url)


  d %<>% mutate(
    agency = str_extract(url, "[:upper:]+"),
    document_id = str_extract(url, "([A-Z]|-|[0-9])+"),
    docket_id = str_remove(document_id, "-[0-9]+$"),
    docket_path = paste(dir, agency, docket_id, sep = "/"),
    file = url |> str_replace("/attachment_", "_") |>  str_remove_all(".*/"),
    file_path = paste(dir, agency, docket_id, file, sep = "/")
  )

  # make needed agency and docket directories
  needed_dir <- setdiff(d$agency,
                        list.dirs(dir, recursive = F) |>
                          str_remove(dir) |>
                          str_remove("^/")
                        )

  walk(here(dir, needed_dir), dir.create)

  needed_dir <- setdiff(d$docket_path |> unique(),
                        list.dirs(dir, recursive = F) )

  walk(here(needed_dir), dir.create)

  # Inspect
  d$file_path[1]
  d$url[1]


  #################################
  # to DOWNLOAD
  download <- d

  # subset to files we don't have
  #FIXME
  download <- d |> filter(
    !file_path %in% paste0(dir, "/",
                           list.files(dir, recursive = T)
                           )
    ) %>%
    # drop empty URLs
    filter(!url %in% c("","NULL"), !is.null(url) )

  # check that subsetting worked
  dim(d)
  head(d)

  dim(download)
  head(download)

  # test download one file
  download.file(download$url[1],
                destfile = download$file_path[1] )

  # number of comments to download per minute (regulation.gov blocks IP addresses, but the max rate keeps changing)
  # n <- 780
  # loop over downloading attachments (no longer in batches)


  for(i in 1:dim(download)[1]){#round(dim(download)[1]/n)){

    # subset to files we don't have
    #download %<>% filter(!file %in% list.files(dir, recursive = T) )

    ## Reset error counter inside function
    errorcount <<- 0
    #for(i in 1:dim(download)[1]){
    #for(i in 1:n){
    if(errorcount < 5){
      # download to comments folder
      tryCatch({ # tryCatch handles errors
        download.file(download$url[i],
                      destfile = download$file_path[i] )
      },
      error = function(e) {
        errorcount<<-errorcount+1
        print(errorcount)
        if( str_detect(e[[1]][1], "cannot open URL") ){
          download$file_path[i] <<- "cannot open URL.csv" # this is a dummy file in the comments folder, which will cause this url to be filtered out
        }
        print(e)
      })
      message(paste(i, "of", dim(download)[1]) )
      #Sys.sleep(1) # pausing between requests does not seem to help, but makes it easier to stop failed calls
    } else{
      message("pausing for one minute to avoid IP being blocked")
      Sys.sleep(60)
    }
    #}
    #Sys.sleep(60) # 1 min
  }
}






