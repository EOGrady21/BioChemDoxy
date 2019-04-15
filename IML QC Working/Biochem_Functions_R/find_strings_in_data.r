# find strings in dataframe that is supposed to be numeric
# print those strings
# give options: 
#1. replace strings with NA 
#2. stop the function and edit file manually to remove strings

find_strings_in_data <- function(bsum) {
  
  # check if there is any characters (strings) in the data columns
  nc=which(!sapply(bsum,is.numeric))
  
  if (length(nc)>0) {
    cat(c("\n","\n"))
    cat("-> WARNING: Strings found in following data columns: ")
    cat(c("\n","\n"))
    print(nc)
    cat(c("\n","\n"))
    cat("Following strings found:")
    cat(c("\n","\n"))
    
    # find what are the strings in the file: PRINT THE STRINGS
    for (i in 1:length(nc)) {
      # find alpha characters 
      re=regexpr("[[:alpha:]]",bsum[,nc[i]])
      cha=which(re>0)
      
      # make dataframe with characters
      cdf=data.frame(cbind(cha,bsum[cha,nc[i]]))
      names(cdf)=c("row",names(bsum)[nc[i]])
      
      print(cdf)
      cat(c("\n","\n"))
      
    }# close for loop that prints the strings
    
    
    # # I DON'T LIKE IDEA of AUTOMATIC COERCION OF STRINGS TO NA SO I WILL COMMENT THIS SECTION
    # # DO YOU WANT TO REPLACE THE STRINGS WITH NA AND MAKE COLUMN NUMERIC?
    # op=readline("Would you like to continue anyway? The strings will be converted to NA (y or n):")
    # cat(c("\n","\n"))
    # if (op=="n") {
    #   cat( "Please edit original file manually to remove strings.")
    #   stop()
    # } # close op "n"
    # 
    # if (op=="y"){
    #   
    #   #turn all the strings to NA (force the columns to be numeric)
    #   for (k in 1:length(nc)) {
    #     bsum[,nc[k]]=as.numeric(bsum[,nc[k]])
    #   } # close for k loop
    #   
    # } # close op "y"
    
    cat(c("\n","\n"))
    cat( "Please edit original file manually to remove strings.")
    stop()
    
  } # close main loop for finding strings
  
  
  return(bsum)
  
} # close function