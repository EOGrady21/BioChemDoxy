# usually the time is in GMT. On some occations the time is recorded in local time. 
# this function converts from local Atlantic Standard Time or Atlantic Daylight Saving Time to gmt time.

convert2gmt= function(dateTime) {
  
  # assigns Atlantic time zone to the time, does not change time
  dateTime_ast=force_tz(dateTime,tz="America/Halifax") 
  
  
  # converts AST or ADT to GMT. It takes care about daylight saving time. 
  dateTime_gmt=with_tz(dateTime_ast,tz="GMT") 
  
  return(dateTime_gmt)
  
}