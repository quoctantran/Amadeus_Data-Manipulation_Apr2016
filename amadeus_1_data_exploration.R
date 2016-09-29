## ==============================================================
## Project definition
## ==============================================================

## Amadeus data manipulation challenge, working with real big data
## bookings: Information about bookings, date, time, ports, etc.
## searches: Information about search queries of customers

setwd("D:/Amadeus")

## --------------------------------------------------------------
## Stage 1: Data exploration
## (1) Read some samples data
## (2) Explore the data structure and types
## (3) Get some first idea about the data sets
## --------------------------------------------------------------

## ==============================================================
## Install require packages
## ==============================================================

install.packages("ff")
install.packages("ffbase")
install.packages("stringr")
install.packages("sqldf")
install.packages("ggplot2")
install.packages("rjson")

## ==============================================================
## Data exploration [bookings.csv]
## ==============================================================

library(ff)

bookings <- read.table.ffdf(file="bookings.csv",sep="^",nrows=100,header=T)
str(bookings[,]) # Explore data structure, identify variables' types

## Manual set variables' types
bookings.vars <- c("POSIXct", # act_date
                   "factor", # source
                   "factor", # pos_ctry
                   "factor", # pos_iata
                   "factor", # pos_oid
                   "factor", # rloc
                   "POSIXct", # cre_date
                   "integer", # duration
                   "integer", # distance
                   "factor", # dep_port
                   "factor", # dep_city
                   "factor", # dep_ctry
                   "factor", # arr_port (13)
                   "factor", # arr_city
                   "factor", # arr_ctry
                   "factor", # lst_port
                   "factor", # lst_city
                   "factor", # lst_ctry
                   "factor", # brd_port
                   "factor", # brd_city
                   "factor", # brd_ctry
                   "factor", # off_port
                   "factor", # off_city
                   "factor", # off_ctry
                   "factor", # mkt_port
                   "factor", # mkt_city
                   "factor", # mkt_ctry
                   "integer", # intl
                   "factor", # route
                   "factor", # carrier
                   "factor", # bkg_class
                   "factor", # cab_class
                   "POSIXct", # brd_time
                   "POSIXct", # off_time
                   "integer", # pax (35)
                   "integer", # year (36)
                   "integer", # month
                   "factor" # oid
                   ) # End of vars list (38 vars)

writeLines(bookings.vars,con="bookings_vars.csv")

## ==============================================================
## Data exploration [searches.csv]
## ==============================================================

library(ff)

searches <- read.table.ffdf(file="searches.csv",sep="^",nrows=100,header=T)
str(searches[,]) # Explore data structure, identify variables' types

## Manual set variables' types
searches.vars <- c("Date", # Date
                   "factor", # Time
                   "factor", # TxnCode
                   "factor", # OfficeID
                   "factor", # Country
                   "factor", # Origin
                   "factor", # Destination
                   "integer", # RoundTrip
                   "integer", # NbSegments
                   "factor", # Seg1Departure
                   "factor", # Seg1Arrival
                   "Date", # Seg1Date
                   "factor", # Seg1Carrier
                   "factor", # Seg1BookingCode
                   "factor", # Seg2Departure
                   "factor", # Seg2Arrival
                   "Date", # Seg2Date
                   "factor", # Seg2Carrier
                   "factor", # Seg2BookingCode
                   "factor", # Seg3Departure
                   "factor", # Seg3Arrival
                   "Date", # Seg3Date
                   "factor", # Seg3Carrier
                   "factor", # Seg3BookingCode
                   "factor", # Seg4Departure
                   "factor", # Seg4Arrival
                   "Date", # Seg4Date
                   "factor", # Seg4Carrier
                   "factor", # Seg4BookingCode
                   "factor", # Seg5Departure
                   "factor", # Seg5Arrival
                   "Date", # Seg5Date
                   "factor", # Seg5Carrier
                   "factor", # Seg5BookingCode
                   "factor", # Seg6Departure
                   "factor", # Seg6Arrival
                   "Date", # Seg6Date
                   "factor", # Seg6Carrier
                   "factor", # Seg6BookingCode
                   "factor", # From
                   "integer", # IsPublishedForNeg
                   "integer", # IsFromInternet
                   "integer", # IsFromVista
                   "factor", # TerminalID
                   "factor" # InternetOffice
                   ) # End of vars list (45 vars)

writeLines(searches.vars,con="searches_vars.csv")

## ==============================================================
## Last modified on 23 Apr 2016. Minh Phan.
## ==============================================================