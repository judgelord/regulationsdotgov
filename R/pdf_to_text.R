library(pdftools)

<<<<<<< HEAD
pdf_to_text <- function(files) {
  # Initialize a list to store text from each PDF
  texts <- vector("list", length(files))
  
  for (i in seq_along(files)) {
    file <- files[i]
    message("Processing file: ", file)
    
    # Default value is NA
    text <- NA
    
    # Check if the file is a PDF
    if (str_detect(file, "pdf")) {
      text <- pdf_text(here("OMB2023MENAORGS", file)) %>% # should edit so you specify folder within the function 
        # Collapse the list of pages
        unlist() %>%
        paste(collapse = "\n<pagebreak>\n") %>%
        as.character()
      
      # Clean up text by removing newline and <pagebreak>
      text <- str_replace_all(text, "\n", " ")
      text <- str_replace_all(text, "<pagebreak>", " ")
      text <- str_trim(text)  # Trim any leading or trailing whitespace
    }
    
    texts[[i]] <- text
  }
  
  return(texts)
}

## a function to read pdf into a string
#pdf_to_text <- function(file){
#  message(file)
#  # default value is NA
#  text <- NA
#  # if the file is a pdf, run pdf_text
#  if(str_detect(file, "pdf")){
#    text <- pdf_text(here("OMB2023MENAORGS", file))  %>%
#      # collapse the list of pages
#      # FIXME
#      unlist() %>%
#      paste(collapse = "\n<pagebreak>\n") %>%
#      unlist() %>%
#      as.character() %>%
#      paste(sep = "\n<pagebreak>\n")
#  }
#  return(text)
#}
=======
pdf_to_text <- function(files) {
  # Initialize a list to store text from each PDF
  texts <- vector("list", length(files))
  
  for (i in seq_along(files)) {
    file <- files[i]
    message("Processing file: ", file)
    
    # Default value is NA
    text <- NA
    
    # Check if the file is a PDF
    if (str_detect(file, "pdf")) {
      text <- pdf_text(here("OMB2023MENAORGS", file)) %>%
        # Collapse the list of pages
        unlist() %>%
        paste(collapse = "\n<pagebreak>\n") %>%
        as.character()
      
      # Clean up text by removing newline and <pagebreak>
      text <- str_replace_all(text, "\n", " ")
      text <- str_replace_all(text, "<pagebreak>", " ")
      text <- str_trim(text)  # Trim any leading or trailing whitespace
    }
    
    texts[[i]] <- text
  }
  
  return(texts)
}
>>>>>>> 4caa5763678e7122fc902e7df13a2964140ecf60
