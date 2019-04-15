# checks ranges of qat data
# for now only temp, sal, and oxy but ranges for other parameters can be added

check_qat_ranges <- function(qat) {
  
  
  # check ranges of the sensors
  sen=c("temp","sal","oxy")
  ranges=list(temp=c(-2.5,35),sal=c(0,50),oxy=c(0,11))
  
  for (i in 1:length(sen)){
    # find clumns for sensors, sid is the column numbers for sensor 1 and 2
    sid=setdiff(grep(sen[i],names(qat)),grep("_",names(qat)))
    
    # find apropriate range
    r=ranges[[grep(sen[i],names(ranges))]]
    
    # indices of records out of range
    oor=which(qat[,sid]<r[1] | qat[,sid]>r[2])
    
    # if there are records out of range find print those records on the screen
    if (length(oor>0)) {
      # indices of records out of range for sensor 1 and 2
      oor1=which(qat[,sid[1]]<r[1] | qat[,sid[1]]>r[2])
      oor2=NULL
      
      # if there is a second sensor
      if (length(sid)>1) {
      oor2=which(qat[,sid[2]]<r[1] | qat[,sid[2]]>r[2])}
      
      oor=unique(c(oor1,oor2))
      
      
      cat("\n","\n")
      cat(paste("-> QAT Range check:" ,toupper(sen[i]),"sensor have", length(oor),"records out of range",paste(r,collapse=" to ")))
      cat("\n","\n")
      print(qat[oor,sid])
    } 
    
    if (length(oor)==0) {
      cat("\n","\n")
      cat(paste("-> QAT Range check: all",toupper(sen[i]),"within acceptable range",paste(r,collapse=" to ")))
      
    }
    
  }
  
  cat("\n","\n")  
}
  
  