# This function is for plotting multiple profiles of the same variable on the same plot.
# For example oxygen collected with CTD, Electrode, and Winkler are all plotted on the same figure.
# The input data from different methods is in the list.
# The first variable in the list has to be CTD profile.
# The secont and third variable, v2 and v3, are bottle data.
# This plotting function handles different combinations of variable (sometimes one of them is missing)
# Gordana Lazin, BioChem Reboot Project, May 10, 2017

plot_profiles <- function(xlist) {
  
  source("flagcol2.r")
  #investigate which elements are not empty
  
  l=lapply(xlist,dim) # dimensions of each element on the list
  data=rbind(xlist$v1,xlist$v2,xlist$v3)
  
  xrange=c(min(data$value),max(data$value))
  
  # CASE 1: if there is data for 1st element (ctd), then plot ctd and the rest if exists
  if (l$v1[1]>0) {
    plot(xlist$v1$value,-xlist$v1$depth, main=xlist$label, type="b", xlab=xlist$xlab, ylab="Depth[m]", xlim=xrange)
    points(xlist$v2$value,-xlist$v2$depth, type="b", col="dodgerblue", pch=16)
    points(xlist$v3$value,-xlist$v3$depth, type="b", col="blue", pch=15, lty=3) 
    
    if (xlist$label=="Oxygen" & (l$v2[1]>0 | l$v3[1]>0)) {
    legend("bottomright",legend=c("CTD", "Electrode","Winkler"),pch=c(1,16,15),col=c("black", "dodgerblue","blue"), lty=c(1,1,3),bty="n")
    }
  }
  
  
  # CASE 2: if there is no CTD data, but there is second measurement, plot second measurement and third if exists
  if (l$v1[1]==0 & l$v2[1]>0) {
    plot(xlist$v2$value,-xlist$v2$depth, main=xlist$label, pch=16, col="dodgerblue", type="b",xlab=xlist$xlab, ylab="Depth[m]", xlim=xrange)
    points(xlist$v3$value,-xlist$v3$depth, type="b", col="blue", pch=15, lty=3) 
    
    if (xlist$label=="Oxygen" & (l$v2[1]>0 | l$v3[1]>0)) {
      legend("bottomright",legend=c("CTD", "Electrode","Winkler"),pch=c(1,16,15),col=c("black", "dodgerblue","blue"), lty=c(1,1,3),bty="n")
    }
    
  }
  
  
  # CASE 3: if there is no CTD data or second set, plot third measurement
  if (l$v1[1]==0 & l$v2[1]==0) {
    plot(xlist$v3$value,-xlist$v3$depth, main=xlist$label, type="b",lty=3, pch=15, col="blue",xlab=xlist$xlab, ylab="Depth[m]", xlim=xrange)

    if (xlist$label=="Oxygen" & (l$v2[1]>0 | l$v3[1]>0)) {
      legend("bottomright",legend=c("CTD", "Electrode","Winkler"),pch=c(1,16,15),col=c("black", "dodgerblue","blue"), lty=c(1,1,3),bty="n")
    }
    
  }
  
  
  # STEP 2:  plot flagged data in different colours
  flag=which(data$qc>1) # find flag index
  if (length(flag)>0){
    clrs=flagcol2(data$qc[flag]) # colors for the flags
    points(data$value[flag],-data$depth[flag],cex=2,bg=clrs,pch=21) # plot flags
  }
    
  
    
  }
  
