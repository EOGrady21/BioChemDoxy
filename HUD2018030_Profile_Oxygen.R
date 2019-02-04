
####  The oxygen outlier calculation was done based on 1.5 IQR but the original 
####  It makes sense to change the method to this now 

### -------------- HUD2018030 Oxygen QC and Data Exploration ----------------------------
setwd("C:\\Users\\CogswellA\\Documents\\AZMP\\Missions\\2018\\2018 Fall\\atsea\\Reports")

input_o=("HUD2018030_Oxygen_Rpt_0924.csv") #name of input file in working directory
(input_o)  #original dataset where corrected oxygen values will reside

o=read.csv(input_o)
o$Oxy_W_Rep2[o$Oxy_W_Rep2==0] <- NA
library(dplyr)
o= o %>% 
  dplyr::arrange(Event,SAMPLE_ID) %>% #properly orders oxygen report by event and sample ID
  dplyr::mutate(ID=row.names(o)) #Adds a new variable called ID that can be used to plot the data and/or keep it sorted properly


# data not subsetted but you could using o=subset(o_orig,START_DEPTH<=1000) #Used only data for top 1000m because there is a hysteresis below 1000m that is corrected when data is reprocessed


o$Oxy_w_avg <- rowMeans(o[c('Oxy_W_Rep1', 'Oxy_W_Rep2')], na.rm=TRUE)
o$sdiff=o$Oxy_CTD_P - o$Oxy_CTD_S

primary1<-o$Oxy_CTD_P
secondary1<-o$Oxy_CTD_S

find_outliers1 <- function(primary1,secondary1) {
  
  
  # difference between primary and secondary salinity sensor
  d1=primary1-secondary1 # difference primary and secondary
  
  # determine outliers via boxplot
  b1=boxplot(d1)
  
  # b$out contains all the outliers that are larger than 1.5*IQR
  # b$stats[1] is upper whisker and b$stats[5] is lower whisker
  
  # indices of outliers
  ob1=which(d1 %in% b1$out)
  
  # plot the difference, outliers, mean and ranges
  plot(d1,xlab="Ordered by Event and Increasing Sample ID",ylab="Primary Oxygen - Secondary Oxygen (ml/l)",main="Outliers Outside 1.5*IQR")
  points(ob1,d1[ob1],pch=19, col="red")
  abline(b1$stats[3],0, col="blue")
  abline(b1$stats[1],0, col="blue", lty=3) # plot lower limit
  abline(b1$stats[5],0, col="blue", lty=3) # plot upper limit
  
  return(ob1) #returns the indices of outliers in ctd and winkler vectors
}

find_outliers1(primary1,secondary1)

d1=primary1-secondary1 # difference primary and secondary
b1=boxplot(d1)
ob1=which(d1 %in% b1$out)
repsrm <- subset(o, ID %in% ob1)
o2 <- o[ ! o$ID %in% ob1, ] #remove bad data rows where there is relatively large difference between primary and secondary
row.names(o2) <- 1:nrow(o2)
o2$ID<-row.names(o2)


rep1<-o2$Oxy_W_Rep1
rep2<-o2$Oxy_W_Rep2
rep2[rep2==0] <- NA


find_outliers2 <- function(rep1,rep2) {
  
  
  # difference between primary and secondary salinity sensor
  d2=rep1-rep2 # difference primary and secondary
  
  # determine outliers via boxplot
  b2=boxplot(d2)
  
  # b$out contains all the outliers that are larger than 1.5*IQR
  # b$stats[1] is upper whisker and b$stats[5] is lower whisker
  
  # indices of outliers
  ob2=which(d2 %in% b2$out)
  
  # plot the difference, outliers, mean and ranges
  plot(d2,xlab="Ordered by Event and Increasing Sample ID",ylab="Winkler Rep1 - Rep 2 (ml/l)",main="Outliers Outside 1.5*IQR")
  points(ob2,d2[ob2],pch=19, col="red")
  abline(b2$stats[3],0, col="blue")
  abline(b2$stats[1],0, col="blue", lty=3) # plot lower limit
  abline(b2$stats[5],0, col="blue", lty=3) # plot upper limit
  
  return(ob2) #returns the indices of outliers in ctd and winkler vectors
}

find_outliers2(rep1,rep2)
o2$Oxy_W_Diff<-o2$Oxy_W_Rep1-o2$Oxy_W_Rep2

winklermean<-o2$Oxy_w_avg

d2=rep1-rep2 # difference primary and secondary
b2=boxplot(d2)
ob2=which(d2 %in% b2$out)
wrm <- subset(o2, ID %in% ob2)
o3 <- o2[ ! o2$ID %in% ob2, ] #remove bad data rows where there is relatively large difference between primary and secondary
row.names(o3) <- 1:nrow(o3)
o3$ID<-row.names(o3)


### Primary Oxygen 0133####

o3$p_wavg=(o3$Oxy_CTD_P-o3$Oxy_w_avg) # The difference between the primary sensor and Winkler replicate average 
o3$threshold_p=(o3$p_wavg-(mean(o3$p_wavg,na.rm=T))) # Threshold variable to look for outliers (Primary SBE O2 - averaged Winkler O2) - mean(Primary SBE O2 - averaged Winkler O2)
o3<-dplyr::arrange(o3,Event,SAMPLE_ID)
plot(o3$threshold_p, xlab="Ordered by Event and Increasing Sample ID", ylab="Primary Threshold (SBEO2-WinklerO2)-mean(SBEO2-WinklerO2)-ml/l") #plot to look for outliers and remove them

p_wavg<-o3$p_wavg
p_wavgm<-mean(o3$p_wavg,na.rm=T)

find_outliers3 <- function(p_wavg,p_wavgm) {
  
  
  # difference between primary and winkler average
  d3=p_wavg-p_wavgm 
  
  # determine outliers via boxplot
  b3=boxplot(d3)
  
  # b$out contains all the outliers that are larger than 1.5*IQR
  # b$stats[1] is upper whisker and b$stats[5] is lower whisker
  
  # indices of outliers
  ob3=which(d3 %in% b3$out)
  
  # mean value
  m3=mean(d3, na.rm=TRUE)
  
  # plot the difference, outliers, mean and ranges
  plot(d3,xlab="Ordered by Event and Increasing Sample ID",ylab="Primary Threshold (SBEO2-WinklerO2)-mean(SBE02-Winkler)2)-ml/l",main="Outliers Outside 1.5*IQR")
  points(ob3,d3[ob3],pch=19, col="red")
  abline(b3$stats[3],0, col="blue")
  abline(b3$stats[1],0, col="blue", lty=3) # plot lower limit
  abline(b3$stats[5],0, col="blue", lty=3) # plot upper limit
  
  return(ob3) #returns the indices of outliers in ctd and winkler vectors
}

find_outliers3(p_wavg,p_wavgm)



d3=p_wavg-p_wavgm 
b3=boxplot(d3)
ob3=which(d3 %in% b3$out)
ptrm <- subset(o3, ID %in% ob3)
o3 <- o3[ ! o3$ID %in% ob3, ] #remove bad data rows where there is relatively large difference between primary and secondary
row.names(o3) <- 1:nrow(o3)
o3$ID<-row.names(o3)

soc_p_old=0.404880 #enter old primary Soc value here 
#is.na(o3$Oxy_w_avg) <- is.nan(o3$Oxy_w_avg) 
soc_p<-soc_p_old*(mean(o3$Oxy_w_avg/o3$Oxy_CTD_P, na.rm=T)) #Calculate primary SOC value for mission for primary sensor from all data
soc_p # view primary oxygen sensor soc for mission
socr_p<-soc_p/soc_p_old #ratio between new and old Soc used for rough correction of Oxygen values
o3$socr_p<-socr_p

o3$p_corr=socr_p*o3$Oxy_CTD_P #create new field with corrected primary sensor values using primary soc 
o3$p_wavg_cor=o3$p_corr-o3$Oxy_w_avg #Difference between corrected primary oxygen and winkler replicate average

df_tmp <- o3 %>%
  dplyr::select(., Oxy_CTD_P, p_corr, Oxy_w_avg) %>%
  tidyr::gather(., key, ctd, Oxy_CTD_P, p_corr) %>%
  dplyr::mutate(., key=ifelse(key=="Oxy_CTD_P", "Uncorrected", "Corrected"))

p1 <- ggplot() +
  coord_cartesian() +
  scale_x_continuous(name="Winkler") +
  scale_y_continuous(name="CTD") +
  scale_shape_manual(values=c(22,16)) +
  scale_color_manual(values=c("blue","black"))

## plot 1:1 line
p1 <- p1 + 
  layer(
    data=data.frame(x=c(min(o3$Oxy_w_avg, na.rm=TRUE), max(o3$Oxy_w_avg, na.rm=TRUE)),
                    y=c(min(o3$Oxy_w_avg, na.rm=TRUE), max(o3$Oxy_w_avg, na.rm=TRUE))),
    mapping=aes(x=x, y=y),
    stat="identity",
    geom="line",
    params=list(size=.5, colour="blue"),
    position=position_identity()
  )  

## plot data
p1 <- p1 + 
  layer(
    data=df_tmp,
    mapping=aes(x=Oxy_w_avg, y=ctd, shape=key, color=key),
    stat="identity",
    geom="point",
    params=list(),
    position=position_identity()
  )  

## customize plot components
p1 <- p1 +
  theme_bw() +
  ggtitle("CTD Primary Oxygen Correction") +
  theme(
    axis.text.x=element_text(colour="black", angle=0, hjust=0.5, vjust=0.5),
    plot.title=element_text(colour="black", hjust=0.5, vjust=1, size=12),
    legend.text=element_text(size=10),
    legend.position=c(.25, .75),
    legend.direction="vertical",
    panel.border=element_rect(colour="black", fill=NA, size=.65),
    plot.margin=unit(c(0.1,0.1,0.1,0.1), "cm")
  )

## customize legend
p1 <- p1 +
  guides(shape=guide_legend(title = NULL,
                            label.position="right",
                            label.hjust=0.5,
                            label.vjust=0.5,
                            keywidth=.75,
                            keyheight=.75)) +
  guides(color=guide_legend(title = NULL,
                            label.position="right",
                            label.hjust=0.5,
                            label.vjust=0.5,
                            keywidth=.75,
                            keyheight=.75))




### Secondary Oxygen #0042 ####


o3$s_wavg=(o3$Oxy_CTD_S-o3$Oxy_w_avg) # The difference between the primary sensor and Winkler replicate average 
o3$threshold_s=(o3$s_wavg-(mean(o3$s_wavg,na.rm=T))) # Threshold variable to look for outliers (Primary SBE O2 - averaged Winkler O2) - mean(Primary SBE O2 - averaged Winkler O2)
o3<-dplyr::arrange(o3,Event,SAMPLE_ID)
plot(o3$threshold_s, xlab="Ordered by Event and Increasing Sample ID", ylab="Secondary Threshold (SBEO2-WinklerO2)-mean(SBEO2-WinklerO2)-ml/l", title="Prior to Event 46") #plot to look for outliers and remove them

s_wavg<-o3$s_wavg
s_wavgm<-mean(o3$s_wavg,na.rm=T)

find_outliers4 <- function(s_wavg,s_wavgm) {
  
  
  # difference between primary and winkler average
  d4=s_wavg-s_wavgm 
  
  # determine outliers via boxplot
  b4=boxplot(d4)
  
  # b$out contains all the outliers that are larger than 1.5*IQR
  # b$stats[1] is upper whisker and b$stats[5] is lower whisker
  
  # indices of outliers
  ob4=which(d4 %in% b4$out)
  
  # mean value
  m4=mean(d4, na.rm=TRUE)
  
  # plot the difference, outliers, mean and ranges
  plot(d4,xlab="Ordered by Event and Increasing Sample ID",ylab="Secondary Threshold (SBEO2-WinklerO2)-mean(SBE02-Winkler)2)-ml/l",main="Outliers Outside 1.5*IQR")
  points(ob4,d4[ob4],pch=19, col="red")
  abline(m4,0, col="blue")
  abline(b4$stats[1],0, col="blue", lty=3) # plot lower limit
  abline(b4$stats[5],0, col="blue", lty=3) # plot upper limit
  
  return(ob4) #returns the indices of outliers in ctd and winkler vectors
}

find_outliers4(s_wavg,s_wavgm)

d4=s_wavg-s_wavgm 
b4=boxplot(d4)
ob4=which(d4 %in% b4$out)

soc_s_old=0.434280 #enter old Soc value here

##### 0042 Threshold and SOC calculation

#is.na(o3$Oxy_w_avg) <- is.nan(o3a$Oxy_w_avg)
soc_s=soc_s_old*(mean(o3$Oxy_w_avg/o3$Oxy_CTD_S, na.rm=T)) #Calculate primary SOC value for mission for primary sensor from all data
soc_s # view primary oxygen sensor soc for mission
socr_s=soc_s/soc_s_old #ratio between new and old Soc used for rough correction of Oxygen values
o3$socr_s=socr_s

o3$s_corr=socr_s*o3$Oxy_CTD_S #create new field with corrected secondary sensor values using secondary soc - uses filtered O2 measurements from line 31
o3$s_wavg_cor=o3$s_corr-o3$Oxy_w_avg #Difference between corrected secondary oxygen and winkler 
#head(arrange(o3,-(abs(-o3$s_wavg_cor))),20) #Arrange the diff between corrected secondary sensor and winkler from greatest to least in the original file


df_tmp <- o3 %>%
  dplyr::select(., Oxy_CTD_S, s_corr, Oxy_w_avg) %>%
  tidyr::gather(., key, ctd, Oxy_CTD_S, s_corr) %>%
  dplyr::mutate(., key=ifelse(key=="Oxy_CTD_S", "Uncorrected", "Corrected"))

p2 <- ggplot() +
  coord_cartesian() +
  scale_x_continuous(name="Winkler") +
  scale_y_continuous(name="CTD") +
  scale_shape_manual(values=c(22,16)) +
  scale_color_manual(values=c("blue","black"))

## plot 1:1 line
p2 <- p2 + 
  layer(
    data=data.frame(x=c(min(o3$Oxy_w_avg, na.rm=TRUE), max(o3$Oxy_w_avg, na.rm=TRUE)),
                    y=c(min(o3$Oxy_w_avg, na.rm=TRUE), max(o3$Oxy_w_avg, na.rm=TRUE))),
    mapping=aes(x=x, y=y),
    stat="identity",
    geom="line",
    params=list(size=.5, colour="black"),
    position=position_identity()
  )  

## plot data
p2 <- p2 + 
  layer(
    data=df_tmp,
    mapping=aes(x=Oxy_w_avg, y=ctd, shape=key, color=key),
    stat="identity",
    geom="point",
    params=list(),
    position=position_identity()
  )  

## customize plot components
p2 <- p2 +
  theme_bw() +
  ggtitle("CTD Secondary Oxygen Correction") +
  theme(
    axis.text.x=element_text(colour="black", angle=0, hjust=0.5, vjust=0.5),
    plot.title=element_text(colour="black", hjust=0.5, vjust=1, size=12),
    legend.text=element_text(size=10),
    legend.position=c(.25, .75),
    legend.direction="vertical",
    panel.border=element_rect(colour="black", fill=NA, size=.65),
    plot.margin=unit(c(0.1,0.1,0.1,0.1), "cm")
  )

## customize legend
p2 <- p2 +
  guides(shape=guide_legend(title = NULL,
                            label.position="right",
                            label.hjust=0.5,
                            label.vjust=0.5,
                            keywidth=.75,
                            keyheight=.75)) +
  guides(color=guide_legend(title = NULL,
                            label.position="right",
                            label.hjust=0.5,
                            label.vjust=0.5,
                            keywidth=.75,
                            keyheight=.75))



#plot difference between corrected primary and secondary


plot(o3$p_corr-o3$s_corr, ylab="Difference between primary (#0133) and secondary sensor (#0042)", xlab="Ordered by Event and Increasing Sample ID",pch=22, col=4, ylim=c(-0.07,0.07))
points(o3$Oxy_CTD_P-o3$Oxy_CTD_S, pch=20, col=1) 
abline(h=mean(o3$p_corr-o3$s_corr, na.rm=T),col="blue")
abline(h=mean(o3$Oxy_CTD_P-o3$Oxy_CTD_S,na.rm=T), col="black")


