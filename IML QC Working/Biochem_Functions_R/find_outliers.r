# Identify outliers in the difference between CTd oxygen and winkler oxygen
# Outliers are identified as values exceeding 1.5 inter quartile range.
# Gordana Lazin, April 28, 2016


find_outliers <- function(ctd,winkler,mission,oxy_sensor) {


# difference between ctd oxy and winkler
d1=ctd-winkler 
  
# determine outliers via boxplot
b=boxplot(d1)

# b$out contains all the outliers that are larger than 1.5*IQR
# b$stats[1] is upper whisker and b$stats[5] is lower whisker

# indices of outliers
ob=which(d1 %in% b$out)

# mean value
m1=mean(d1, na.rm=TRUE)

# plot the difference, outliers, mean and ranges
plot_name=paste0(mission,"_oxy_outliers_OXY",oxy_sensor,".png")

#dev.copy(png,plot_name)
title=paste0(mission,", OXY",oxy_sensor, " :outliers outside 1.5*IQR")
plot(d1,ylab="OXY-Winkler",main=title)
points(ob,d1[ob],pch=19, col="red")
abline(m1,0, col="blue")
abline(b$stats[1],0, col="blue", lty=3) # plot lower limit
abline(b$stats[5],0, col="blue", lty=3) # plot upper limit
#dev.off()


return(ob) #returns the indices of outliers in ctd and winkler vectors
}