# Function that takes time stamp in date-time format and returns 
# time in the format required by BioChem (HHMM string).
#
# Written by Gordana Lazin, BioChem Reboot Project, 2015

bctime <-function(datetime) {
 
  
      hstr=sprintf("%02d",hour(datetime)) # hour as 2-digit string with leading zero  
      mstr=sprintf("%02d",minute(datetime)) # minutes as 2-digit string with leading zeroes  
      bctime=paste0(hstr,mstr) # time in format HHMM as string.
  
      bctime[which(bctime=="NANA")]=""
  
  return(bctime)
}