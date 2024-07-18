# a function to read pdfs and save a txt file
pdf_to_txt <- function(file){

  message(paste("Trying", file))
  agency <- str_extract(file, "[A-Z]*")

  docket <- str_extract(file, "[A-Z]*-[0-9]*-[0-9]*")

  # create new directories if needed
  if (!dir.exists(here("comments", agency, docket) ) ){
    dir.create(here("comments", agency), showWarnings = FALSE)
    dir.create(here("comments", agency, docket))
  }

  # save txt file
  write_file(pdf_to_text(file),
             path = here("comments", agency, docket, str_replace(file, "pdf", "txt") ) )
}

if(F){
length(files)
walk(files, possibly(pdf_to_txt, otherwise = print("nope")))
}
