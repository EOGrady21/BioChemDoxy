# QAT file usualy has primary and secondary sensors for oxy, temp, sal, and cond, named oxy1, oxy2 etc.
# This function allows user to choose between primary or secondary sensor for each parameter.
#
# Input: qat data frame with all columns and sensors
#
# Output: data frame containing ID, pressure, and sensors of choice. 
# The name of each parameter does not contain number, just namre (oxy, temp etc.)
#
# Gordana lazin, 13 April 2016

choose_qat_sensors <- function(qat) {
  
  
  # CHOOSE BETWEEN MULTIPLE SENSORS (primary or secondary)
  
  # define qat parameters that have primary and secondary sensor
  sensors=c("oxy","sal","temp","cond","fluor")
    
  
  op=readline("Would you like to use sensor 1 for all parameters (y or n)?: ")
  
  # OPTION 1: if you want to use primary sensors only
  if (op=="y") {
    sn=paste0(sensors,1) # name of the sensors to be loaded (like oxy1)
    cat("-> Retreiving primary sensors only.")
  }
  
  
  # OPTION 2: if you want to use combination of primary and secondary sensors you have to choose for each
  if (op=="n") {
     n=NULL
    
    # choose sensors for each parameter
    for (i in 1:length(sensors)) {
      
      n[i]=readline(paste("Which sensor would you like to use for", sensors[i],"(1 or 2)?:") )
    }
    sn=paste0(sensors,n)
    cat(paste("-> Retreiving following sensors:"),paste(sn,collapse=", "))
  }
  
  
  
  # add the rest of the sensors to the sensor list
  sna=c(sn,"pressure","ph","par")
  
  # check if all possible sensors are there
  cl=which(names(qat) %in% sna)
  
  if (length(cl)==length(sna)) {
    cat("All sensors found in QAT file")
  }
  
  if (length(cl)<length(sna)) {
    missing_sensors=setdiff(sna,names(qat)[cl])
    cat("\n","\n")
    cat(paste("-> Sensors not found in in QAT file:", paste(missing_sensors,collapse=", ")))
    cat("\n","\n")
  }
  
  
  # qat data frame containing only fields to be loaded
  qf=qat[,c("id",names(qat)[cl])]
  
  # names of the original sensors assigned for each measurements
  original_sensors=names(qf)[which(!is.na(as.numeric(gsub("[[:alpha:]]","",names(qf)))))]
  
  # remove sensor number from the column header (replace temp1 with temp)
  names(qf)=gsub("[[:digit:]]","",names(qf))
  
  l=list(qf=qf,original_sensors=original_sensors)
  
  return(l)
  
}