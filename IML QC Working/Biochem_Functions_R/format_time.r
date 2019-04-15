# Function that reads time in various format and outputs time in HHMM format (as string).
# It is "guessing" input time format until it gets it right. If the input format is very unusual 
# it might not work. Additional input formats can be added.


# Written by Gordana Lazin, BioChem Reboot project, 2015


format_time <-function(time) {
  
  require(lubridate)
  
  # check if all time records are NA
  if(all(is.na(time))) {
    bct=time
  } else {
  
  # if there is no : in the time field, then the time is probably HHMM format
  
  if (length(grep(":",time))==0) {
    
    # check number of digits (should have 3 or 4 digits)
    if (any(nchar(time)>4)) {
      print("Warning: Unknown time format: number of digits is > 4")
    }
    
    # make sure time has 4 digits (pad with zeroes in the begening)  
    bct=formatC(as.numeric(time), width=4, flag=0) 
  
    } else {
  
  # if there is : in the time field
 
   # check if the format is HH:MM:SS
   t=strptime(time,"%H:%M:%S") 
  
   # if this is not the format then t will be NA
   if (all(is.na(t))) {
    t=strptime(time,"%H:%M")  # try format HH:MM
   }
   
   # it is possible that time coulmn is character and includes date as well; 
   # then the numer of characters is >9
   n=nchar(time[!is.na(time)]) # number of characters in time that is not NA
   if (mean(n)>9 & is.character(time)) {
     t=as.POSIXct(time)
   }
   
   # if the time is already in POSIXt format
   if (is.POSIXt(time)) {
     t=time
   }
   
  
   # if this is not the right format then t will be NA
   if (all(is.na(t))) {
    print("Warning: unknown time format")
   
    } else{
      
      # format time to HHMM with 4 digits
      hstr=sprintf("%02d",hour(t)) # hour as 2-digit string with leading zero  
      mstr=sprintf("%02d",minute(t)) # minutes as 2-digit string with leading zeroes  
      bct=paste0(hstr,mstr) # time in format HHMM as string.
    
  }
    }
  
  
  bct[which(bct=="NANA")]=""
  bct=gsub(" ","",bct)
  
  }
  
  return(bct)
}
