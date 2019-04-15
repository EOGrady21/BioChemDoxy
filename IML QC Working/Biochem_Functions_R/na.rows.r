# Function returns the indices of the rows in the data frame that have all NA elements
# Written by Gordana Lazin, BioChem Reboot project, 2015

na.rows <- function(df) {
  
  # find rows with all NA or empty strings, f is logical
  f <- apply(is.na(df) | df == "", 1, all) 
  
  # indices of the rows with all na
  ind=which(f)
  
  return(ind)
  
}