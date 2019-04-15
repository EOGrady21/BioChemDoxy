# counts number of digits before decimal point

whole_digits <- function(numb) {
  
  # convert number to string
  
  a=as.character(numb)
  
  # find the point in the string
  p=regexpr("[/./]",a)
  
  # there is no decimal point,the number is integer or 0
  if (p[1]<0) {
    
    # find out the number of digits in the integer
    dig=nchar(a)
    
  }
  
  
  # if there is a decimal point, find number of digits
  if (p[1]>0) {
    
    # number of digits before decimal point
    dig=p[1]-1
  
  }
  
  return(dig)
  
}