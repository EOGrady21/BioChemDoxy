

library(readxl)


OxyPlus <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/OXY_Plus_for_Emily.csv')
OxyPlus$DIS_SAMPLE_KEY_VALUE=paste0(OxyPlus$MISSION_DESCRIPTOR,"_",sprintf("%03d",OxyPlus$EVENT_COLLECTOR_EVENT_ID),"_",OxyPlus$DIS_DETAIL_COLLECTOR_SAMP_ID)
#rename some columns
names(OxyPlus)[14] <- 'DIS_DETAIL_DATA_VALUE'
names(OxyPlus)[12] <- 'DIS_DETAIL_DATA_TYPE_SEQ'

OxyPlus$MISSION <- NULL
OxyPlus$INSTITUTE <- NULL


BB <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/HUD2000050_BCD.csv')
