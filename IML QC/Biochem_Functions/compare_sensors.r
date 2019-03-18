# compare primary and secondary ctd sensors

compare_sensors <- function(qat,mission) {
  
  sensors=c("oxy","dens","theta","sal","cond","fluor","temp")
  
  for (i in 1:length(sensors)) {
    
  # find columns for each sensor
    sc=grep(sensors[i],names(qat))
   
  # if there is more than one sensor, then compare
    if (length(sc)>1) {
     sc1=grep(paste0(sensors[i],1),names(qat)) # column for the first sensor
     sc2=grep(paste0(sensors[i],2),names(qat)) # column for the second sensor 
     
     # check if all elements of one sensor are NA
     
     if (all(is.na(qat[,sc1])) | all(is.na(qat[,sc2]))) {
       
       # if there is data only for one sensor write a comment
       cat(c("\n","\n"))
       cat(paste0(sensors[i]," : There is data available only for one ", sensors[i], " sensor. Sensor comparison not possible"))
     } else {
     
     
     
     par(mfrow=c(2,1), mar=c(4,5,3,2))
     
     nm=names(qat)
     ylabel=paste(nm[sc1],"-",nm[sc2])
     title=paste(mission, sensors[i],"sensors difference")
     plot(qat$id,qat[,sc1]-qat[,sc2],ylab=ylabel,xlab="ID",col="blue", main=title)
     abline(0,0)
     
     plot(qat$pressure,qat[,sc1]-qat[,sc2],ylab=ylabel, xlab="Pressure", col="blue")
     abline(0,0)
     
     # examine differences: find outliers
     #d=qat[,sc1]-qat[,sc2] # differences between sensors
     #out=find_outliers1(d)
     
     # this section displays the dat with larger differences. I don't like how the "large" diferences 
     # are defined through boxplot (find_outliers1.r function)
     # if (length(out)>0) {
     #   cat("\n","\n")
     #   cat("-> QAT data check: large difference between sensors for following records:")
     #   cat("\n","\n")
     #   print(qat[out,c(1,sc1,sc2)])
     # }
     
     # save the plot
     outpath=file.path(getwd(),mission)
     # define file name (goes in the mission folder)
     fn=file.path(outpath,paste0(mission,"_", sensors[i],"_comparison_qat.png"))
     
     dev.copy(png,fn, width=700,height=600, res=90)
     dev.off()
    
     cat("\n","\n")
     cat(" *********** PLEASE EXAMINE SENSOR COMPARISON PLOTS  *********** ")
     cat("\n","\n")
     
     op=readline("Are you ready to continue (y or n)?: ")
     
     if (op=="n") {
       
       stop()
     } 
     
    } }# end of if
    
    else { # write a message that there is only one sensor available
      cat(c("\n","\n"))
      cat(paste0("-> QAT data ", sensors[i]," : only ", names(qat)[sc], " available. Sensor comparison not possible"))
      }
    
  } # end of for loop
  
  par(mfrow=c(1,1), mar=c(5.1,4.1,4.1,2.1)) # reset to 1 plot per image
  
  
} # end of function