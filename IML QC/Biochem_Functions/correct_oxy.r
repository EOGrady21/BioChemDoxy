# Oxygen correction for biochem data
#
# The script is using winkler oxy to derive corrected CTD oxy.
# Input: winkler and CTD oxy
# Output: corrected CTD oxy
#
# Steps: 
# 1.filters outliers
# 2. make a regression between winkler and CTD oxygen
# 3. plot the regression for visual inspection
# 4. correct CTD oxygen to match winkler
#
# Gordana Lazin, 29 April 2016

correct_oxy <- function(ctd,winkler,mission,oxy_sensor) {
  
# ctd is oxygen from ctd sensor
# winkler is oxygen from winkler measurements
  
# functions required
 source("find_outliers.r")
 source("axis_range.r")
  
# find outliers (large disagreements betwen winkler and ctd)
out=find_outliers(ctd,winkler,mission,oxy_sensor)

# original input data
ictd=ctd
iwinkler=winkler

# remove outliers from both measurements
if (length(out)>0) {
  ctd=ctd[-out]
  winkler=winkler[-out]
}

# make a regression and derive coeficcients
cor=lm(winkler~ctd)

# coefficients for the regression
intercept=summary(cor)$coefficients[1,1]
slope=summary(cor)$coefficients[2,1]
r2=summary(cor)$r.squared

# save the regression plot
plot_name=paste0(mission,"_oxy_correction.png")

#dev.copy(png,plot_name)

# plot the results
ar=axis_range(iwinkler,ictd)
title=paste(mission,",OXY",oxy_sensor,": Slope =",round(slope,4),", Intercept=",round(intercept,4))
plot(ctd, winkler,xlab="CTD OXY [ml/l]", ylab="Winkler OXY [ml/l]", col="blue", xlim=ar, ylim=ar, main=title, cex.main=1)
points(ictd[out],iwinkler[out],pch=19, col="red")
abline(cor, col="blue",lwd=2)
legend("topleft",paste("R2 = ",round(r2,digits=3)), bty="n")

# save the plot
# save the plotd
outpath=file.path(getwd(),mission)
# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_oxy",oxy_sensor,"_correction_qat.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()
# dev.off()

# make a correction of all ctd data
ctd_corrected=slope*ictd+intercept

return(ctd_corrected)

}