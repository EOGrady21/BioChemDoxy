# Function that reads dates in various format and outputs date in dd-mmm-yyyy format as string (like 24-Jan-2012).
# It is "guessing" input date format until it gets it right. If the input format is very unusual 
# it might not work. Additional input formats can be added.


# Written by Gordana Lazin, BioChem Reboot project, 2015



format_date <-function(date) {
  
  # format input dates to dd-mmm-yyyy (24-Oct-2013) by guessing input date format
  
  require(lubridate)
  
  if(all(is.na(date))) {
    outdate=date  # return all NA
    #cat("\n",'\n')
    #print("Format date function: Input dates are all NA.")
  } else {
  
  # try different formats to see which one works
  
  d=strptime(date,"%d-%b-%y") # try date format dd-mmm-yy "24-09-13"
  
  if (all(is.na(d))) { 
    d=strptime(date,"%d/%m/%Y") # try date format dd/mm/yyyy  "24/09/2013" 
  }
  
  # if this one doesn't work try another one
  if (all(is.na(d))) { 
    d=strptime(date,"%d/%m/%y") # try date format dd/mm/yy (2-digit year) "24/09/13"
  }
  
  # if this one doesn't work try another one
  if (all(is.na(d))) { 
    d=strptime(date,"%b %d %Y") # try date format "mmm dd yyyy" "Sep 24 2012"  
  }
  
  
  # if this one doesn't work try another one
  if (all(is.na(d))) { 
    d=strptime(date,"%Y-%m-%d") # try date format "yyyy-mm-dd" "2012-09-24"  
  }
  
  
  # if none works write a message
  if (all(is.na(d))) { 
    cat("\n","\n")
    print("Unknow date format. Add another date format to format_date function.")
    cat("\n","\n")
  }
  
  # output date should look like: dd-mmm-yyyy
  outdate=format(d,"%d-%b-%Y")
  }
  
  return(outdate)  
  
}
