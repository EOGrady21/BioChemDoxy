# Script to calculate SOC correction from CTD oxygen sensors and in situ Winkler data
#
# Author: Benoit Casault 
# Created: 19-JUL-2017
# Adapted by Jeff Jackson for COR2017001 (06-FEB-2018)
# Last Updated: 06-FEB-2018

# load required packages ####
library(dplyr)
library(tidyr)
library(ggplot2)

# read data ####
df_data_raw <- read.csv("HUD99022_Oxygen_Rpt.csv")

# rename columns; calculate winkler average; order oxygen report by event and sample ID ####
df_data_raw <- df_data_raw %>%
  dplyr::rename(., ctd1=Oxy_CTD_P, ctd2=Oxy_CTD_S, winkler1=Oxy_W_Rep1, winkler2=Oxy_W_Rep2) %>%
  dplyr::mutate(., winkler_avg=rowMeans(cbind(.$winkler1, .$winkler2), na.rm=TRUE)) %>%
  dplyr::mutate(., winkler_avg=rowMeans(cbind(.$winkler1, .$winkler2), na.rm = T)) %>%
  dplyr::arrange(Event,SAMPLE_ID)

#NO REPLICATES
# filter outliers between Winkler replicates ####
 # winkler_dist <- df_data_raw$winkler1 - df_data_raw$winkler2
 # winkler_box <- boxplot(winkler_dist,ylab="Oxygen Difference (ml/l)",main="Boxplot of Winkler Replicate Differences")
 # winkler_outliers <- winkler_dist %in% winkler_box$out

# filter outliers between CTD sensors ####
ctd_dist <- df_data_raw$ctd2 - df_data_raw$ctd1
ctd_box <- boxplot(ctd_dist,ylab="Oxygen Difference (ml/l)",main="Boxplot of CTD Oxygen Sensor Differences")
ctd_outliers <- ctd_dist %in% ctd_box$out

# subset original data
#df_data_filtered <- df_data_raw %>% .[!(ctd_outliers | winkler_outliers) ,]
df_data_filtered <- df_data_raw %>% .[!(ctd_outliers) ,]

# filter outliers between ctd primary and Winkler replicates (average) ####
primary_winkler_dist <- df_data_filtered$ctd1 - df_data_filtered$winkler_avg
primary_winkler_dist <- primary_winkler_dist - mean(primary_winkler_dist, na.rm=TRUE)
primary_winkler_box <- boxplot(primary_winkler_dist,ylab="Oxygen Difference (ml/l)",main="Boxplot of CTD Primary - Winkler Oxygen Differences")
primary_winkler_outliers <- primary_winkler_dist %in% primary_winkler_box$out
# Change bad Primary CTD oxygens to NA.
df_data_filtered$ctd1[primary_winkler_outliers] <- NA

# Calculate new SOC for Primary CTD Oxygen (Sensor # 0133) ####
soc1 <- 00#???
soc1_ratio <- mean(df_data_filtered$winkler_avg/df_data_filtered$ctd1, na.rm=TRUE)
soc1_new <- soc1*soc1_ratio
# apply correction
df_data_filtered <- df_data_filtered %>%
  dplyr::mutate(., ctd1_corr=soc1_ratio*ctd1)

# filter outliers between ctd secondary and Winkler replicates (average) ####
secondary_winkler_dist <- df_data_filtered$ctd2 - df_data_filtered$winkler_avg
secondary_winkler_dist <- secondary_winkler_dist - mean(secondary_winkler_dist, na.rm=TRUE)
secondary_winkler_box <- boxplot(secondary_winkler_dist,ylab="Oxygen Difference (ml/l)",main="Boxplot of CTD Secondary - Winkler Oxygen Differences")
secondary_winkler_outliers <- secondary_winkler_dist %in% secondary_winkler_box$out
# Change bad Secondary CTD oxygens to NA.
df_data_filtered$ctd2[secondary_winkler_outliers] <- NA

# Calculate new SOC for Secondary CTD Oxygen (Sensor #) ####
soc2 <- .4949
soc2_ratio <- mean(df_data_filtered$winkler_avg/df_data_filtered$ctd2, na.rm=TRUE)
soc2_new <- soc2*soc2_ratio
# apply correction
df_data_filtered <- df_data_filtered %>%
  dplyr::mutate(., ctd2_corr=soc2_ratio*ctd2)



##########################################
#####  Plot Primary CTD Oxygen data  #####
##########################################

# rearrange the data for plotting
df_tmp1 <- df_data_filtered %>%
  dplyr::select(., ctd1, ctd1_corr, winkler_avg) %>%
  tidyr::gather(., key, ctd, ctd1, ctd1_corr) %>%
  dplyr::mutate(., key=ifelse(key=="ctd1", "Uncorrected", "Corrected"))

# initialize plot
p1 <- ggplot() +
  coord_cartesian() +
  scale_x_continuous(limits=c(2,9), name="Winkler") +
  scale_y_continuous(limits=c(2,9), name="CTD") +
  scale_shape_manual(values=c(23,21)) +
  scale_color_manual(values=c("red","blue"))

## plot 1:1 line
p1 <- p1 + 
  layer(
    data=data.frame(x=0:10,
                    y=0:10),
    mapping=aes(x=x, y=y),
    stat="identity",
    geom="line",
    params=list(size=.5, colour="black"),
    position=position_identity()
  )  

## plot data
p1 <- p1 + 
  layer(
    data=df_tmp1,
    mapping=aes(x=winkler_avg, y=ctd, shape=key, color=key),
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

suppressWarnings(print(p1))


##########################################
####  Plot Secondary CTD Oxygen data  ####
##########################################

# rearrange the data for plotting
df_tmp2 <- df_data_filtered %>%
  dplyr::select(., ctd2, ctd2_corr, winkler_avg) %>%
  tidyr::gather(., key, ctd, ctd2, ctd2_corr) %>%
  dplyr::mutate(., key=ifelse(key=="ctd2", "Uncorrected", "Corrected"))

# initialize plot
p2 <- ggplot() +
  coord_cartesian() +
  scale_x_continuous(limits=c(2,9), name="Winkler") +
  scale_y_continuous(limits=c(2,9), name="CTD") +
  scale_shape_manual(values=c(23,21)) +
  scale_color_manual(values=c("red","blue"))

## plot 1:1 line
p2 <- p2 + 
  layer(
    data=data.frame(x=0:10,
                    y=0:10),
    mapping=aes(x=x, y=y),
    stat="identity",
    geom="line",
    params=list(size=.5, colour="black"),
    position=position_identity()
  )  

## plot data
p2 <- p2 + 
  layer(
    data=df_tmp2,
    mapping=aes(x=winkler_avg, y=ctd, shape=key, color=key),
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

suppressWarnings(print(p2))


## Plot the CTD Oxygen Differences between the two sensors before and after calibration.
odiff <- df_data_filtered$ctd2 - df_data_filtered$ctd1
plot(odiff, col="black", ylim = range(-1.0,0.2) , main = 'Secondary - Primary CTD Oxygen Differences', ylab = 'Secondary - Primary (ml/l)')
mean_odiff <- mean(odiff, na.rm = TRUE)
abline(mean_odiff, 0, col="black")
odiff_corr <- df_data_filtered$ctd2_corr - df_data_filtered$ctd1_corr
points(odiff_corr, col="blue", ylim = range(-1.0,0.2))
mean_odiff_corr <- mean(odiff_corr, na.rm = TRUE)
abline(mean_odiff_corr, 0, col="blue")


# Compute the mean differences for the report
mpw <- mean(df_data_filtered$ctd1 - df_data_filtered$winkler_avg, na.rm = TRUE)
mpwc <- mean(df_data_filtered$ctd1_corr - df_data_filtered$winkler_avg, na.rm = TRUE)
msw <- mean(df_data_filtered$ctd2 - df_data_filtered$winkler_avg, na.rm = TRUE)
mswc <- mean(df_data_filtered$ctd2_corr - df_data_filtered$winkler_avg, na.rm = TRUE)
mco <- mean(df_data_filtered$ctd2 - df_data_filtered$ctd1, na.rm = TRUE)
mcoc <- mean(df_data_filtered$ctd2_corr - df_data_filtered$ctd1_corr, na.rm = TRUE)


#export corrected values

write.csv(x = df_data_filtered, file = 'HUD2012042_Oxy_corrected.csv')
