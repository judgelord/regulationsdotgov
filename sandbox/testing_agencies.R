devtools::load_all()
library(tidyverse)

make_path_dockets(agency = "OMB", lastModifiedDate = Sys.time(), page = 1, api_key = api_keys)



n <- httr::GET("https://api.regulations.gov/v4/dockets?filter[agencyId]=OMB&filter[lastModifiedDate][le]=2025-01-16%2015:33:35&page[size]=250&page[number]=1&sort=-lastModifiedDate&api_key=9azbQEqsdmKb7d3sb4ThbELXxMIk5CeYMhlUSd8o")

content <- jsonlite::fromJSON(rawToChar(n$content))

agencies_1.16 <- data.frame(agency = c("FDA","FAA","EPA","USCG","DOT","FMCSA","PHMSA","NRC","NOAA","NHTSA","CMS","MARAD",
                                       "FRA","DOD","ED","HUD","NIH","FWS","APHIS","DOS","CDC","FTC","FHWA","NCUA","IRS",
                                       "AMS","OSHA","DHS","SSA","BOEM","USCBP","PTO","DARS","CPSC","ITA","FNS","HHS","ETA",
                                       "FTA","EERE","MSHA","DEA","FSIS","FS","SBA","CFPB","FEMA","DOE","BIS","OPM","USA",
                                       "VA","USTR","USN","RBS","EBSA","RHS","COE","USCIS","FAR","USAF","RUS","OCC","ACF",
                                       "CNCS","EIB","GSA","USDA","USBC","DOC","HRSA","DOL","EAC","TREAS","COLC","DOJ","TTB",
                                       "NRCS","PBGC","FSA","FTZB","OMB","OSM","NARA","EEOC","NSF","NTSB","TSA","DOI","SAMHSA",
                                       "FINCEN","AID","BSEE","ASC","NIST","CCC","ICEB","NASA","CISA","OTS","FCIC","ATBCB",
                                       "FRTIB","GIPSA","AHRQ","FISCAL","NPS","MMS","ATSDR","HHSIG","BIA","IHS","CEQ","RITA",
                                       "OFAC","NTIA","FMC","OFCCP","BOP","EOIR","ONRR","BLM","EDA","NLRB","USC","NASS",
                                       "CPPBSD","EAB","SLSDC","ESA","WCPO","WHD","AOA","NIFA","BPD","CDFI","USMINT","ATF",
                                       "NCS","NIGC","VETS","LMSO","ARS","BLS","BSC","PCLOB","MBDA","USPC","FAS","FSOC",
                                       "CSREES","FFIEC","OPPM","OJP","OSTP","FIRSTNET","FBI","OFPP","BOR","WAPA","DEPO",
                                       "ECSA","FLETC","OEPNU","TA","BPA","EIA","NNSA","ACL","ERS","ONDCP","RTB","CSB",
                                       "ISOO","ONCD","RMA","ERULE","FPAC","OFR","OJJDP","ATR","IPEC","NAL","NSPC",
                                       "PCSCOTUS","SWPA","CSEO","ECAB","EOA","FCSC","GAPFAC","USDAIG"),
                            dockets = c(56487,47339,20706,12660,11802,8226,7731,
                                        5293,5051,4490,3831,3750,3106,2793,2642,
                                        2629,2496,2098,2049,2041,1992,1941,1860,
                                        1816,1753,1711,1597,1504,1404,1191,1148,
                                        1067,1063,987,960,883,800,799,786,764,751,
                                        726,715,714,699,693,691,659,645,634,621,
                                        565,561,555,521,510,497,473,422,420,407,
                                        406,373,371,359,342,338,315,308,306,285,
                                        283,267,258,254,234,230,229,224,220,220,
                                        210,208,183,179,176,176,175,170,170,161,
                                        154,149,141,137,134,134,124,123,123,121,
                                        116,106,105,99,98,95,91,88,82,76,75,72,
                                        60,58,54,53,52,50,50,50,49,49,48,48,47,
                                        46,46,46,45,44,44,41,39,38,35,30,29,28,
                                        28,28,26,23,23,23,23,22,20,18,18,16,16,
                                        14,13,13,12,11,11,10,10,9,9,9,8,8,7,7,7,
                                        6,6,5,5,4,4,4,4,3,3,3,3,2,2,2,2,2,2,1,1,
                                        1,1,1,1))


save_dockets <- function(agency){
  message (agency)
  dockets <- map_dfr(agency, get_dockets, api_keys = keys)
  message(paste("|", agency, "| n =", nrow(dockets), "|"))
  save(dockets, file = here::here("data",
                                  agency,
                                  paste0(agency, "_dockets.rda")
  )
  )
}

# Testing dockets N < 50 

agencies <- agencies_1.16[119:192,]$agency %>%
  walk(here::here("data",.), dir.create)

walk(agencies, possibly(save_dockets, otherwise = print("nope")))

get_dockets(agency = "USDAIG", api_keys = api_keys)




