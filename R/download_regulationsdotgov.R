library(tidyverse)
library(magrittr)
library(here)

attachments <- comments_coded$attachments |>
  flatten() |>
  map(as.data.frame) |>
  map_dfr(~.x)

ggplot(attachments) +
  aes(x = size, fill = format) +
  geom_bar()

ggplot(attachments |> slice_max(size, 100)) +
  aes(x = size, fill = format) +
  geom_bar()

attachment_urls <- attachments |>
  pull(fileUrl) |>
  unique()



download_regulations_gov(attachment_urls )


download_regulations_gov <- function(url){

  d <- tibble::tibble(
    url = url)


  d %<>% mutate(
    agency = str_extract(url, "[:upper:]+"),
    document_id = str_extract(url, "([A-Z]|-|[0-9])+"),
    docket_id = str_remove(document_id, "-[0-9]+$"),
    docket_path = paste("comments", agency, docket_id, sep = "/"),
    file = url |> str_replace("/attachment_", "_") |>  str_remove_all(".*/"),
    file_path = paste("comments", agency, docket_id, file, sep = "/")
  )

  # make directories
  needed_dir <- setdiff(d$agency, list.dirs("comments", recursive = F) |> str_remove("comments/") )

  walk(here("comments", needed_dir), dir.create)

  needed_dir <- setdiff(d$docket_path |> unique(),
                        list.dirs("comments", recursive = F) )

  walk(here(needed_dir), dir.create)





  # Test
  d$url[1]

  # name output file
  d %<>%
    mutate(file = file_path)

  # Inspect
  d$file[1]
  d$url[1]



  #################################
  # to DOWNLOAD
  download <- d

  # subset to files we don't have
  #FIXME
  download %<>% filter(
    !file %in% paste0("comments/",
                      list.files("comments", recursive = T)
    )
  ) %>%
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
    #download %<>% filter(!file %in% list.files("comments", recursive = T) )

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
          download$file[i] <<- "cannot open URL.csv" # this is a dummy file in the comments folder, which will cause this url to be filtered out
        }
        print(e)
      })
      print(i)
      #Sys.sleep(1) # pausing between requests does not seem to help, but makes it easier to stop failed calls
    } else{
      message("pausing for one minute to avoid IP being blocked")
      Sys.sleep(60)
    }
    #}
    #Sys.sleep(60) # 1 min
  }
}

#TESTING
if(F){
  download_regulations_gov(download)
}

##################

# FIXME do this inside next function, one at a time
# pdftools::pdf_text("comments/WHD-2017-0002-138298-1.pdf")
# READ TEXTS
# initialize and loop over downloaded attachments to read in texts






