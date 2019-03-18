####data error check####


data <- read.csv('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/Oxy_corrected.csv')

# 
# data$DIS_HEADER_SDATE[data$MISSION_DESCRIPTOR == '84036']
# data$DIS_HEADER_STIME[data$MISSION_DESCRIPTOR == '84036']
# 
# 
 grep(unique(data$MISSION_DESCRIPTOR), pattern = '18TL06043')


#if time value is na, causing error in QC
#change to zero value

for (i in 1:length(data$DIS_HEADER_STIME)){
  if(is.na(data$DIS_HEADER_STIME[i])){
    data$DIS_HEADER_STIME[i] <- 0
  }
}

#rewrite csv for reprocessing
write.csv(data, file = 'Oxy_corrected.csv')

###stub file

head(data[data$MISSION_DESCRIPTOR == '18HU83023',])
unique(data$DATA_TYPE_METHOD[data$MISSION_DESCRIPTOR == '18HU83023'])
