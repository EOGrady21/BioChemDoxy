# Function that removes extra rows and columns that show up 
# when reading from excel file with read.xslx

# Written by Gordana Lazin, BioChem reboot project, Dec 1, 2015

clean_xls = function(dfin) {
  
  df=dfin
  
  # determine which columns have POSIXt or Date formats
  posixt=which(sapply(df, FUN = is.POSIXt)) # columns with POSIXlt or POSIXct format
  dates=which(sapply(df, is.Date)) # columns with date format
  
  # columns with either date or POSIXt formats
  time_formats=c(posixt,dates)
  
  
  # find rows whit all na (extra rows)
  if (length(time_formats>0)) {
    extra=na.rows(df[,-time_formats]) # find rows for which all values are NA
  } else {
    extra=na.rows(df)
  }
  
  # if there are such rows, remove them
  if (length(extra)>0){ 
    df=df[-extra,]
  }
  
  
  # determine which columns have NA in the header
  extra_cols=grep("NA",names(df))
  
  # if there are such columns remove them
  if (length(extra_cols)>0){
    df=df[,-extra_cols]
  }
  
  return(df)
  
  
}

