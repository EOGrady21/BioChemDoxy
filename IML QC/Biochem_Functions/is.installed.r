# checks if package is installed

is.installed <- function(mypkg){
  is.element(mypkg, installed.packages()[,1])
} 
