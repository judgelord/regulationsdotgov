library(pdftools)

# a function to read pdfs and save a txt file
pdf_to_txt <- function(file){

  # remove directory
  file <- file |> str_remove(".*/")

  message(paste("Trying", file))

  agency <- str_extract(file, "[A-Z]*")

  docket <- str_extract(file, "[A-Z|-]*-[0-9]*-[0-9]*")

  # create new directories if needed
  if (!dir.exists(here("comment_text", agency, docket) ) ){
    dir.create(here("comment_text", agency), showWarnings = FALSE)
    dir.create(here("comment_text", agency, docket))
  }

  # default value is NA
  text <- NA

  # if the file is a pdf, run pdf_text
  if(str_detect(file, "pdf")){
    text <- pdftools::pdf_text(here("comments", agency, docket, file))  %>%
      # collapse the list of pages
      # FIXME
      unlist() %>%
      paste(collapse = "\n<pagebreak>\n") %>%
      unlist() %>%
      as.character() %>%
      paste(sep = "\n<pagebreak>\n")
  }

  # save txt file
  write_file(text,
             file = here("comment_text",
                         agency,
                         docket,
                         str_replace(file, "pdf", "txt")
             ) )

}




if(F){
  files <- list.files("comments", recursive = T)


  length(files)
  walk(files, possibly(pdf_to_txt, otherwise = print("nope")))
}
