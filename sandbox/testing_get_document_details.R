################
# TESTING #####
# install regulationsdotgov
devtools::load_all()
# keys saved up one directory
load("../keys.rda")

library(tidyverse)
library(httr)
library(jsonlite)
library(magrittr)

  # for a notice (the API appears to return the same document details with /documents/ instead of /documents/ in the path)
  # however, it does not return the same included list
  document_details <- get_document_details(id = "FDA-2015-N-0030-8511")

  document_details$fileFormats

  class(document_details$fileFormats)


