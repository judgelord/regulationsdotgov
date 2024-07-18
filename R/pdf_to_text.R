library(pdftools)

# a function to read pdf into a string
pdf_to_text <- function(file){
  message(file)
  # default value is NA
  text <- NA
  # if the file is a pdf, run pdf_text
  if(str_detect(file, "pdf")){
    text <- pdf_text(here("comments", file))  %>%
      # collapse the list of pages
      # FIXME
      unlist() %>%
      paste(collapse = "\n<pagebreak>\n") %>%
      unlist() %>%
      as.character() %>%
      paste(sep = "\n<pagebreak>\n")
  }
  return(text)
}

