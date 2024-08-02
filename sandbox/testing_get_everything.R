

agencies <- c("BIA", "IHS")

# create directories for each agency
walk(here::here("data", agencies), dir.create)

dockets <- map_dfr(agencies, get_dockets) # retrieves dockets for an agency (see official acronyms on regulations.gov)


# create directories for each docket
docket_paths <- paste(dockets$agency, dockets$docket_id, sep = "/")

walk(here::here("data", docket_paths), dir.create)

#### Get documents from each docket
save_documents <- function(docket){
  documents <- map_dfr(docket, get_documents)
  save(documents, here::here("data",
                             str_extract("[A-Z|-]+)", docket), #FIXME this is not going to work for agencies with numbers in their names, e.g. FWS-R9...
                             # should we require an agency argument here, or is there a reliable way to split agencies and dockets, e.g., by looking for years -19[0-9][0-9]- or -20[0-9][0-9]-
                             docket,
                             "documents.rda"
                             )
  )
}

walk(dockets, save_documents)

documents <- map_dfr(dockets$docket_id, get_documents) # retrieves documents for a docket

save(here::here("data", "documents.rda"))


#### Get metadata for comments on a document or docket

get_comments_on_docket("[docket_id]") # retrieves all comments for a docket (e.g., including an Advanced Notice of Proposed Rulemaking and all draft proposed rules)

save_comments <- function(docket){
  comments <- map_dfr(docket, get_comments_on_docket)
  save(comments, here::here("data",
                             str_extract("[A-Z]+)", docket), # agency
                             docket,
                            "comments.rda"
  )
  )
}

walk(dockets, save_comments)



get_commentsOnId("[document_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)

#### Get detailed metadata about a comment

get_comment_details("[comment_id]") # retrieves comments on a specific document (e.g., a specific proposed rule)


save_comment_details <- function(docket){
  comments <- map_dfr(docket, get_comments_on_docket)
  comment_details <- get_comment_details(comments$document_id)

  save(comment_details, here::here("data",
                            str_extract("[A-Z]+)", docket), # agency
                            docket,
                            "comment_details.rda"
  )
  )
}

walk(dockets, save_comment_details)

# DOWNLOAD ATTACHMENTS

# extract attachments from details
attachments <- comment_details$attachments |>
  flatten() |>
  map(as.data.frame) |> #FIXME, can we do this in one line?
  map_dfr(~.x)

# inspect
ggplot(attachments) +
  aes(x = size, fill = format) +
  geom_bar()

ggplot(attachments |> slice_max(size, n = 100)) +
  aes(x = size, fill = format) +
  geom_bar()

#TODO? drop large pdf files?
# attachments %<>% filter(size < 100000000) # = < 100 MB ?

attachment_urls <- attachments |>
  pull(fileUrl) |>
  unique()


download_comments(attachment_urls )




# CONVERT TO TXT
files <- list.files("comments", recursive = T)
length(files)
head(files)
converted <- list.files("comment_text", recursive = T) |> str_replace("txt", "pdf")
head(converted)
# files not converted
not_converted <- files[!files %in% converted]
head(not_converted)

# pdfs not converted
pdfs <- not_converted[str_detect(not_converted, "pdf")]

walk(pdfs, possibly(pdf_to_txt, otherwise = print("nope")))
