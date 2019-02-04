

#sma function 

sma <- function(data, num){
  mav <- paste0('mavg', data) 
  mav <- list()
  for ( i in 1:length(data)){
    if (num == 3){
      mav[i] <- mean(c(data[i], data[i+1], data[i+2]), na.rm = TRUE)
    }
  }
  return(mav)
}