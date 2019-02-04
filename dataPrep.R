###data prep for QC###

library(readxl)

data <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/OXY_Plus_for_Emily.csv')


#step 1
#exclude by geographical coordinates to ensure focus on area of interest



geolim <- data$DIS_DETAIL_DATA_VAL[data$DIS_HEADER_SLON > -72 & data$DIS_HEADER_SLON < -48 & data$DIS_HEADER_SLAT > 37.5 & data$DIS_HEADER_SLAT < 48]


for (i in 1:length(data$DIS_DATA_NUM)){
  if (!(data$DIS_HEADER_SLON[i] > -72 & data$DIS_HEADER_SLON[i] < -48 & data$DIS_HEADER_SLAT[i] > 37.5 & data$DIS_HEADER_SLAT[i] < 48)){
    data[i, ] <- NA #outside geographical limits
    #is setting a temporary flag best way to handle this???
  }
}

data <- na.omit(data)
write.csv(x = data , file = 'oxyPlus_geoLim.csv' )

#step 2
#run unit check to ensure correct units going into QC

#check ranges, set unit field to appropriate? if falls in unknown range?
#update to appropriate name for unit column form BCD

for (i in 1:length(unique(data$MISSION_DESCRIPTOR))){
  miss <- unique(data$MISSION_DESCRIPTOR)[i]
  if(max(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == miss]) <=14){
    data$UNIT[data$MISSION_DESCRIPTOR == miss] <- 'mll'
  }
  if (min(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == miss]) >=105){
    data$UNIT[data$MISSION_DESCRIPTOR == miss] <- 'mmolm'
  }
  else {
    if(!any(is.na(data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == miss]))){
      print(paste('Cruise', miss, 'has values in unknown range!'))
      plot(x = data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == miss], y = data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == miss], xlab = 'SampleID' , ylab = 'Oxygen Value', main = miss)
      abline(h = 14, col ='blue')
      abline(h = 105, col = 'red')
      a <- menu(c('mll', 'mmolm', 'unkn'), graphics = F, title = 'Estimated Oxygen Units')
    if (a == 1){
      data$UNIT[data$MISSION_DESCRIPTOR == miss] <- 'mll'
      data$DIS_DETAIL_DATA_QC_CODE[data$MISSION_DESCRIPTOR == miss] <- 7 #flag for manual or unsure units?
    }
    if (a == 2){
      data$UNIT[data$MISSION_DESCRIPTOR == miss] <- 'mmolm'
      data$DIS_DETAIL_DATA_QC_CODE[data$MISSION_DESCRIPTOR == miss] <- 7
    }
    if (a == 3){
      data$DIS_DETAIL_DATA_QC_CODE[data$MISSION_DESCRIPTOR == miss] <- 7
      
    }
    }
  }
}

#step 2.1
#search metadata for NA


for (i in 1:length(unique(data$MISSION_DESCRIPTOR))){
  miss <- unique(data$MISSION_DESCRIPTOR)[i]
  meta <- names(data)
  
     if (any(is.na(data$DIS_HEADER_STIME[data$MISSION_DESCRIPTOR == miss] ))){
    
       print(paste( miss, 'has NA metadata values'))
  
  }
}


#step 3
#run script to put in IML format

#step 4
#MATLAB

#step 5
#back into BCD format


#step 6
#flag review
#flagReview(path)

