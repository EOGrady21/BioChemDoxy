<<<<<<< HEAD
###data prep for QC###

library(readxl)

data <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/Emily_Winkler.csv')

##make sure ll data types are present in BCD_IMML_MAP
map0=read.csv("BCD_IML_map_upd.csv", stringsAsFactors = FALSE)

types <- unique(data$DATA_TYPE_METHOD)

bb <- types %in% map0$BCD_FIELDS

#creates vector with all unmapped variables
b <- types[bb == FALSE]

#write.csv(file = 'data_map.csv', b)
#step 1
#exclude by geographical coordinates to ensure focus on area of interest
#completed by Shelley within SQL pull

# 
# geolim <- data$DIS_DETAIL_DATA_VAL[data$DIS_HEADER_SLON > -72 & data$DIS_HEADER_SLON < -48 & data$DIS_HEADER_SLAT > 37.5 & data$DIS_HEADER_SLAT < 48]
# 
# 
# for (i in 1:length(data$DIS_DATA_NUM)){
#   if (!(data$DIS_HEADER_SLON[i] > -72 & data$DIS_HEADER_SLON[i] < -48 & data$DIS_HEADER_SLAT[i] > 37.5 & data$DIS_HEADER_SLAT[i] < 48)){
#     data[i, ] <- NA #outside geographical limits
#     #is setting a temporary flag best way to handle this???
#     #setting to NA is WAY TOO SLOW (3+ hrs...)
#   }
# }
# 
# data <- na.omit(data)
# write.csv(x = data , file = 'oxyPlus_geoLim.csv' )



###check for winkler oxy in all missions###
flag <- list()
for (i in 1:length(unique(data$MISSION_DESCRIPTOR))){
  dt <- unique(data$DATA_TYPE_METHOD[data$MISSION_DESCRIPTOR == unique(data$MISSION_DESCRIPTOR)[i]])
  
  g <- grep(dt, pattern = 'O2_W')
  
  if (length(g) == 0){
    flag[i] <- as.character(unique(data$MISSION_DESCRIPTOR)[i])
    
  }
  
}

flag <- na.omit(unlist(flag))

for (i in 1:length(flag)){
  print(unique(data$DATA_TYPE_METHOD[data$MISSION_DESCRIPTOR == flag[i]]))
}

#step 2
#run unit check to ensure correct units going into QC

#check range of data per cruise
#if range matches mmol/m**3 set DATA_TYPE_METHOD to O2_Winkler_Molar
#so that data maps to appropriate unit in QC
#only for oxygen data

#initialize factor levels for new data type
DATA_TYPE_METHOD <- levels(data$DATA_TYPE_METHOD)
data$DATA_TYPE_METHOD <- factor(data$DATA_TYPE_METHOD, levels = c(DATA_TYPE_METHOD, 'O2_Winkler_Molar'))

winkler <- c('O2_Winkler', 'O2_Winkler_Auto')

for (i in 1:length(unique(data$MISSION_DESCRIPTOR))){
  #isolate by mission
  miss <- unique(data$MISSION_DESCRIPTOR)[i]
  #bb <- data[data$MISSION_DESCRIPTOR == miss,]
  #isolate oxygen data
  #bb <- bb[bb$DATA_TYPE_METHOD == 'O2_Winkler',]
  
  #determine range
  if(max(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == miss & data$DATA_TYPE_METHOD %in% winkler ]) <=14){
   ;
  }
  else {
    #rename data_type_method for molar
    data$DATA_TYPE_METHOD[data$MISSION_DESCRIPTOR == miss & data$DATA_TYPE_METHOD %in% winkler] <- as.factor('O2_Winkler_Molar')
    
  }
  # else {
  #   if(!any(is.na(data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == miss]))){
  #     print(paste('Cruise', miss, 'has values in unknown range!'))
  #     plot(x = bb$DIS_DETAIL_COLLECTOR_SAMP_ID, y = bb$DIS_DETAIL_DATA_VAL, xlab = 'SampleID' , ylab = 'Oxygen Value', main = miss)
  #     abline(h = 14, col ='blue')
  #     abline(h = 105, col = 'red')
  #     a <- menu(c('mll', 'mmolm', 'unkn'), graphics = F, title = 'Estimated Oxygen Units')
  #   if (a == 1){
  #     data$UNIT[data$MISSION_DESCRIPTOR == miss] <- 'mll'
  #     data$DIS_DETAIL_DATA_QC_CODE[data$MISSION_DESCRIPTOR == miss] <- 7 #flag for manual or unsure units?
  #   }
  #   if (a == 2){
  #     data$UNIT[data$MISSION_DESCRIPTOR == miss] <- 'mmolm'
  #     data$DIS_DETAIL_DATA_QC_CODE[data$MISSION_DESCRIPTOR == miss] <- 7
  #   }
  #   if (a == 3){
  #     data$DIS_DETAIL_DATA_QC_CODE[data$MISSION_DESCRIPTOR == miss] <- 7
  #     
  #   }
  #   }
  # }
}

#write out new file
write.csv(data, file = 'Oxy_corrected.csv')
#create loop to convert mmol measurements to mll

# backup <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/OXY_Plus_for_Emily.csv')
# 
# data$DIS_DETAIL_DATA_VAL <- backup$DIS_DETAIL_DATA_VAL
# 
# for (i in 1:length(data$UNIT)){
#   if (!is.na(data$UNIT[i])){
#   if (data$UNIT[i] == 'mmolm'){
#     data$DIS_DETAIL_DATA_VAL[i] <- data$DIS_DETAIL_DATA_VAL[i] / 44.6596 #from IML standard
#     }
#   }
# }
# 
# bcdo$DIS_DETAIL_DATA_VALUE <- data$DIS_DETAIL_DATA_VAL
# 
# write.csv(bcdo, file = 'OxyPlus_all_mll')
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

#check QC files

filesc <- list.files('~/BIOCHEM/IML QC/QC_V5/', pattern = 'QC_')
filesc <- filesc[1:157]

list <- list()
h <- 0

for (i in 1:length(filesc)){
  
  t <- read.table(file = paste0('~/BIOCHEM/IML QC/QC_V5/', filesc[i]), sep = ';', na.strings = 'NaN', comment.char = '', stringsAsFactors = F)
  names(t) <- as.character(t[2,])
  if ('OXYM_01' %in% names(t)){
    h <- h+1
    g <- grep(names(t), pattern = 'Q_OXYM')
    if (length(g) == 0){
      print('>> Warning, OXYM present without QC variable')
      print(paste0('>>>>', i, '/', length(filesc)))
      list[i] <- filesc[i]
    }
  }

}

#files that contain OXYM but are not getting a Q_OXYM column
l <- na.omit(unlist(list))

for ( i in 1:length(l)){
  f <- read.table(file = paste0('~/BIOCHEM/IML QC/QC_V5/', l[i]), sep = ';', na.strings = 'NaN', comment.char = '', stringsAsFactors = F)
  names(f) <- as.character(f[2,])
}
=======
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

>>>>>>> 8d16c9adec107eab3c9823ff203975da149b937b
