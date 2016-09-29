## ==============================================================
## Project definition
## ==============================================================

## Amadeus data manipulation challenge, working with real big data
## bookings: Information about bookings, date, time, ports, etc.
## searches: Information about search queries of customers

setwd("D:/Amadeus")

## --------------------------------------------------------------
## Stage 2: Data cleansing
## (1) Standardize data separators and remove unsed whitespaces
##     [bookings.csv --> bookings_clean.csv]
##     [searches.csv --> searches_clean.csv]
## (2) Filter out error data lines and fix them
##     [bookings_clean.csv --> bookings_clean2.csv]
##     [searches_clean.csv --> searches_clean2.csv]
## --------------------------------------------------------------

## ==============================================================
## Data cleansing [bookings.csv]
## ==============================================================

## --------------------------------------------------------------
## Clean these following errors:
## (1) Convert "," to "^"
## (2) Convert "[:space:]^" to "^"
## (3) Remove trailling whitespace
## --------------------------------------------------------------

file.in <- file("bookings.csv","r")
file.out <- file("bookings_clean.csv","w")
x <- readLines(file.in,n=1)

## Cleansing data for the headers
ind <- gsub(",","^",x) # Convert all "," to "^"
ind <- gsub(" +\\^","^",ind) # Convert all "[:space:]^" to "^"
ind <- gsub(" +$","",ind) # Remove trailing whitespace
writeLines(ind,file.out)

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- readLines(file.in,n=block)
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + length(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
  
  ind <- gsub(",","^",x) # Convert all "," to "^"
  ind <- gsub(" +\\^","^",ind) # Convert all "[:space:]^" to "^"
  ind <- gsub(" +$","",ind) # Remove trailing whitespace
  writeLines(ind,file.out)
}

close(file.in)
close(file.out)

## 10000010 lines
## 38 vars, 37 separators ("^")

## --------------------------------------------------------------
## Read through line by line, extract error lines
## --------------------------------------------------------------

library(stringr)

error.count = 0 # Numbers of error found
error.line = c() # List of error lines
error.data = c() # List of error data

file.in <- file("bookings_clean.csv","r")
x <- readLines(file.in,n=1) # Read headers

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- readLines(file.in,n=block)
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + length(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
  
  ## Look for line with different numbers of separator
  for (i in 1:length(x))
    if (str_count(x[i],"\\^")!=37) { # Error line detecting
      print(paste0("Error line: ",last.line+i))
      # print(x[i])
      error.count <- error.count+1
      error.line <- c(error.line,last.line+i)
      error.data <- c(error.data,x[i])
    }
}

close(file.in)

## Print out error lines
file.out = file("error_fixing/bookings_errors.csv","w")
for (i in 1:error.count)
  writeLines(paste0(error.line[i],"^",error.data[i]),file.out)
close(file.out)

## --------------------------------------------------------------
## Fix error lines in Excel, load back and Write fixed data to file
## --------------------------------------------------------------

fixed.lines <- read.table("error_fixing/bookings_errors_fixed.csv",
                          sep=",",header=F,stringsAsFactors=F)
mark <- rep(T,nrow(fixed.lines))

file.in <- file("bookings_clean.csv","r")
file.out <- file("bookings_clean2.csv","w")
x <- readLines(file.in,n=1) # Read headers
writeLines(x,file.out)

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- readLines(file.in,n=block)
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + length(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
  
  ## Replace error lines
  for (i in 1:nrow(fixed.lines))
    if (mark[i] & (fixed.lines[i,1] %in% (last.line+1):count)) {
      print(paste0("Fixing line: ",fixed.lines[i,1]))
      x[fixed.lines[i,1]-last.line] <- fixed.lines[i,2]
      mark[i] <- F # Mark this line as done (FALSE)
    }
  
  writeLines(x,file.out)
}

close(file.in)
close(file.out)

## --------------------------------------------------------------
## Use read.table() to read through file again to confirm NO error
## --------------------------------------------------------------

file.in <- file("bookings_clean2.csv","r")
x <- readLines(file.in,n=1) # Read headers

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- read.table(file.in,header=F,nrows=block,sep="^",na.strings="")
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + nrow(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
}

close(file.in)

## NO error confirmed [YEAH!]

## ==============================================================
## Data cleansing [searches.csv]
## ==============================================================

## --------------------------------------------------------------
## Clean these following errors:
## (1) Convert "," to "^"
## (2) Convert "[:space:]^" to "^"
## (3) Remove trailling whitespace
## --------------------------------------------------------------

file.in <- file("searches.csv","r")
file.out <- file("searches_clean.csv","w")
x <- readLines(file.in,n=1)

## Cleansing data for headers
ind <- gsub(",","^",x) # Convert all "," to "^"
ind <- gsub(" +\\^","^",ind) # Convert all "[:space:]^" to "^"
ind <- gsub(" +$","",ind) # Remove trailing whitespace
writeLines(ind,file.out)

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- readLines(file.in,n=block)
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + length(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
  
  ind <- gsub(",","^",x) # Convert all "," to "^"
  ind <- gsub(" +\\^","^",ind) # Convert all "[:space:]^" to "^"
  ind <- gsub(" +$","",ind) # Remove trailing whitespace
  writeLines(ind,file.out)
}

close(file.in)
close(file.out)

## 20390198 lines
## 45 vars, 44 separators ("^")

## --------------------------------------------------------------
## Read through line by line to detect and clean data error
## --------------------------------------------------------------

library(stringr)

error.count = 0 # Numbers of error found
error.line = c() # List of error lines
error.data = c() # List of error data

file.in <- file("searches_clean.csv","r")
x <- readLines(file.in,n=1) # Read headers

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- readLines(file.in,n=block)
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + length(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
  
  ## Look for line with different numbers of separator
  for (i in 1:length(x))
    if (str_count(x[i],"\\^")!=44) { # Error line detecting
      print(paste0("Error line: ",last.line+i))
      # print(x[i])
      error.count <- error.count+1
      error.line <- c(error.line,last.line+i)
      error.data <- c(error.data,x[i])
    }
}

close(file.in)

## Print out error lines
file.out = file("error_fixing/searches_errors.csv","w")
for (i in 1:error.count)
  writeLines(paste0(error.line[i],"^",error.data[i]),file.out)
close(file.out)

## --------------------------------------------------------------
## Fix error lines in Excel, load back and write fixed data to file
## --------------------------------------------------------------

fixed.lines <- read.table("error_fixing/searches_errors_fixed.csv",
                          sep=",",header=F,stringsAsFactors=F)
mark <- rep(T,nrow(fixed.lines))

file.in <- file("searches_clean.csv","r")
file.out <- file("searches_clean2.csv","w")
x <- readLines(file.in,n=1)
writeLines(x,file.out)

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- readLines(file.in,n=block)
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + length(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
  
  ## Replace error lines
  for (i in 1:nrow(fixed.lines))
    if (mark[i] & (fixed.lines[i,1] %in% (last.line+1):count)) {
      print(paste0("Fixing line: ",fixed.lines[i,1]))
      x[fixed.lines[i,1]-last.line] <- fixed.lines[i,2]
      mark[i] <- F # Mark this line as done (FALSE)
    }

  writeLines(x,file.out)
}

close(file.in)
close(file.out)

## --------------------------------------------------------------
## Using read.table() to read through file again to confirm NO error
## --------------------------------------------------------------

file.in <- file("searches_clean2.csv","r")
x <- readLines(file.in,n=1) # Read headers

block <- 500000 # Size of each data block
count <- 0 # Count how many lines
repeat {
  x <- read.table(file.in,header=F,nrows=block,sep="^",na.strings="")
  if (length(x)==0) break # End of file checking
  last.line <- count # Last line of previous data block
  count <- count + nrow(x) # Last line of current data block
  print(paste0("# WORKING ON LINE: ",last.line+1," --> ",count))
}

close(file.in)

## ==============================================================
## Last modified on 21 Apr 2016. Minh Phan.
## ==============================================================