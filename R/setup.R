# Script for setting up the neccesary packages for regulationsdotgov 

requires <- c("tidyverse",
              "dplyr",
              "magrittr",
              "httr",
              "jsonlite",
              "lubridate")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

library(tidyverse)
library(purrr)
library(dplyr)
library(jsonlite)
library(httr)
library(magrittr)
library(lubridate)