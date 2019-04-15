# function to determine the range of x and y axis so the x and y have the same scale

axis_range <- function(x,y) {
  
  # define minimum and maximum for the axis
  mn=floor(min(c(x,y),na.rm=T)) # minimum
  mx=ceiling(max(c(x,y),na.rm=T)) # maximum
  ar=c(mn,mx) # axis range
  
  return(ar)
  
}

