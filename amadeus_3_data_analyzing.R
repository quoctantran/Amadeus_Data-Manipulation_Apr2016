## ==============================================================
## Project definition
## ==============================================================

## Amadeus data manipulation challenge, working with real big data
## bookings: Information about bookings, date, time, ports, etc.
## searches: Information about search queries of customers

setwd("D:/Amadeus")

## --------------------------------------------------------------
## Stage 3: Data analyzing
## (1) Import clean data
## (2) Analyze to answer questions
## --------------------------------------------------------------

## ==============================================================
## Question 1: Count number of lines in each files
## ==============================================================

library(sqldf)

## --------------------------------------------------------------
## Read [bookings_clean2.csv]
## --------------------------------------------------------------

## Only import these columns: arr_port, pax, year
bookings_sql <- read.csv.sql(file="bookings_clean2.csv",header=T,sep="^",
                             sql="SELECT substr(act_date,1,10) AS act_date,
                             dep_port, arr_port, pax, year
                             FROM file")
nrow(bookings_sql)

## 10000010 lines of data (NOT include the header line)
## 38 variables, 37 separators per line

## --------------------------------------------------------------
## Read [searches_clean2.csv]
## --------------------------------------------------------------

## Only import these columns: Date, Destination
searches_sql <- read.csv.sql(file="searches_clean2.csv",header=T,sep="^",
                             sql="SELECT Date, Origin, Destination,
                             substr(Date,1,4) AS year,
                             substr(Date,6,2) AS month
                             FROM file")
nrow(searches_sql)

## 20390198 lines of data (NOT include the header line)
## 45 variables, 44 separators per line

write.csv(c(10000010,20390198),"results/q1_num_rows.csv",row.names=F)

write.csv(bookings_sql,"bookings_lite.csv",row.names=F,quote=F)
write.csv(searches_sql,"searches_lite.csv",row.names=F,quote=F)

## ==============================================================
## Question 2: Top 10 arrival airports in the world in 2013
## ==============================================================

## Sum and group by arr_port
port <- sqldf("SELECT year, arr_port, sum(pax) AS sum_pax
              FROM bookings_sql
              GROUP BY year, arr_port")
unique(port[,"year"]) # Checking data range, only in 2013

top10.port <- head(port[order(port[,"sum_pax"],decreasing=T),],10)
write.csv(top10.port,"results/q2_top10_arr_port.csv",row.names=F)

## LHR  88809   London            Heathrow
## MCO  70930   Orlando           International
## LAX  70530   Los Angeles       International/ Metropolitan Area
## LAS  69630   Las Vegas         McCarran International/	Metropolitan Area
## JFK  66270   New York          John F Kennedy Intl
## CDG  64490   Paris             Charles de Gaulle
## BKK  59460   Bangkok           Suvarnabhumi Int'l/ Metropolitan Area
## MIA  58150   Miami             International/ Metropolitan Area
## SFO  58000   San Francisco     International
## DXB  55590   Dubai             International/ Metropolitan Area

## IATA codes: http://www.iata.org/publications/Pages/code-search.aspx

## ==============================================================
## Question 3: Plot monthly number of searches for flights 
## arriving at Malaga, Madrid or Barcelona
## ==============================================================

## Malaga       AGP
## Madrid       MAD, CLQ, TOJ
## Barcelona    BCN, BLA

## Sum and group by year, month, Destination
dest <- sqldf("SELECT year, month, Destination,
              count(*) AS count_search
              FROM searches_sql
              GROUP BY year, month, Destination")
unique(dest[,"year"]) # Checking data range, only in 2013

## Flights arriving at Malaga
dest.Malaga <- dest[dest[,"Destination"] %in% c("AGP"),c("month","count_search")]

## Flights arriving at Madrid
dest.Madrid <- dest[dest[,"Destination"] %in% c("MAD","CLQ","TOJ"),]
dest.Madrid <- aggregate(count_search~month,data=dest.Madrid,sum)

## Flights arriving at Barcelona
dest.Barcelona <- dest[dest[,"Destination"] %in% c("BCN","BLA"),]
dest.Barcelona <- aggregate(count_search~month,data=dest.Barcelona,sum)

## Final results
dest.result <- cbind(dest.Malaga,dest.Madrid$count_search,dest.Barcelona$count_search)
names(dest.result) <- c("Month","Malaga","Madrid","Barcelona")
write.csv(dest.result,"results/q3_monthly_searches.csv",row.names=F)

## Plotting results
library(ggplot2)

ggplot(data=dest.result,aes(x=Month,group=3))+
  geom_line(aes(y=Malaga,color="Malaga"),size=2)+
  geom_line(aes(y=Madrid,color="Madrid"),size=2)+
  geom_line(aes(y=Barcelona,color="Barcelona"),size=2)+
  scale_colour_discrete(name="Destination")+
  ylab("Search Count")+
  ggtitle("Number of Searches Per Month in 2013")

## ==============================================================
## Bonus question 1: Match searches with bookings
## ==============================================================

library(ff)
library(ffbase)

## Matching criteria:
## (1) [searches] Origin = [bookings] dep_port
## (2) [searches] Destination = [bookings] arr_port
## (3) [searches] Date = [bookings] act_date
## Assume that matched search and booking should make in the same date

## Read the lite version of data sets to analyze easier
bookings_lite <- read.csv.ffdf(file="bookings_lite.csv",header=T)
searches_lite <- read.csv.ffdf(file="searches_lite.csv",header=T)

## Add match column and change columns names before merging
bookings_lite[,"match"] <- 1
names(bookings_lite) <- c("Date","Origin","Destination","pax","year","match")

## Use ff package to merge, very fast
match <- merge.ffdf(searches_lite,bookings_lite,by=c("Origin","Destination","Date"),all.x=T)
match[is.na(match[,"match"]),"match"] <- 0 # Fill NA values by 0
write.csv(match,"results/q4_match.csv",row.names=F)

## Write to output searches file
file.in <- file("searches_clean2.csv","r")
file.out <- file("searches_clean2_match.csv","w")

x <- readLines(file.in,n=1) # Read headers
x <- paste0(x,"^","match") # Add a new column [match]
writeLines(x,file.out) # Copy headers

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- read.table(file.in,header=F,nrows=block,sep="^",na.strings="")
  if (length(x)==0) break # Checking end of file
  last.line <- count # Last line of previous data block
  count <- count + nrow(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
  
  x[,"match"] <- match[c((last.line+1):count),"match"]
  write.table(x,file.out,append=T,sep="^",quote=F,row.names=F,col.names=F,na="")
}

close(file.in)
close(file.out)

## Number of searches match with bookings: 996008
## Number of searches NO match with bookings: 19394190

## ==============================================================
## Bonus question 2: Write a Web Service (Extract to JSON)
## ==============================================================

library(rjson)

n <- 100
topN.port <- head(port[order(port[,"sum_pax"],decreasing=T),],n)

x <- toJSON(topN.port) # Convert to JSON format
cat(x) # Print out to check JSON file

writeLines(x,"results/q5_topN_arr_port_JSON.json")

## ==============================================================
## Last modified on 23 Apr 2016. Tan Tran.
## ==============================================================
