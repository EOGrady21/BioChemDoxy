####data check####

library(readxl)

data <- read_xlsx('D:/DATA/Dec27-Winkler/Emily_Winkler.xlsx')

plot(data$DIS_DETAIL_DATA_VAL, type = 'h')


mll <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL < 14])
mmolm <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL > 105])
unkn <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL >= 14 & data$DIS_DETAIL_DATA_VAL <= 105])
err <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL < 0])




mission <- unique(data$MISSION_DESCRIPTOR)


#check for duplicates

dupes <- read_xlsx('D:/DATA/Dec27-Winkler/Emily_dupe_sampids_metadata.xlsx')

uniqdata <- unique(dupes$DIS_DETAIL_DATA_VAL)


dupes$flag <- 0

for (i in 1:length(dupes$DIS_DETAIL_DATA_VAL)){
  for(j in 1:length(dupes$DIS_DETAIL_DATA_VAL)){
    if (i != j){
   
      if(dupes$MISSION_DESCRIPTOR[i] == dupes$MISSION_DESCRIPTOR[j]){
        if(dupes$DIS_DETAIL_COLLECTOR_SAMP_ID[i] == dupes$DIS_DETAIL_COLLECTOR_SAMP_ID[j]){
          if(dupes$DIS_HEADER_SDATE[i] == dupes$DIS_HEADER_SDATE[j]){
            if(dupes$DIS_HEADER_STIME[i] == dupes$DIS_HEADER_STIME[j]){
              if(dupes$DIS_HEADER_START_DEPTH[i] == dupes$DIS_HEADER_START_DEPTH[j]){
                if(dupes$DIS_DETAIL_DATA_VAL[i] == dupes$DIS_DETAIL_DATA_VAL[j]){
                  dupes$flag[j] <- 4
                  #setting all flags to 4 instead of only duplicates?
                }
              }
            }
          }
        }
      }
    }
  }
}

#flag duplicated data values
tf <- duplicated(dupes$DIS_DETAIL_DATA_VAL)
for (i in 1:length(dupes$DIS_DETAIL_DATA_VAL)){

if (tf[i] == T){
  dupes$flag[i] <- 4
}

}

#successful
#108 identical duplicates flagged "4"

#unlikely there are duplicates entered in distinct units 
#due to range of values in "dupes"

#needs to be flagged in master data sheet

#limit by geographical area

geolim <- data$DIS_DETAIL_DATA_VAL[data$DIS_HEADER_SLON > -72 & data$DIS_HEADER_SLON < -48 & data$DIS_HEADER_SLAT > 37.5 & data$DIS_HEADER_SLAT < 48]


for (i in 1:length(data$DIS_DATA_NUM)){
  if (!(data$DIS_HEADER_SLON[i] > -72 & data$DIS_HEADER_SLON[i] < -48 & data$DIS_HEADER_SLAT[i] > 37.5 & data$DIS_HEADER_SLAT[i] < 48)){
    data$DIS_DETAIL_DATA_QC_CODE[i] <- 5 #outside geographical limits
    
  }
}

#sucessfully flagged 69220 records which were outside relevant
#geographical boundaries


dupmission <- unique(dupes$MISSION_DESCRIPTOR[dupes$flag == 4])

for (i in 1:length(data$DIS_DATA_NUM)){
  if (data$MISSION_DESCRIPTOR[i] %in% dupmission){
    data$DIS_DETAIL_DATA_QC_CODE[i] <- 4
  }
}



mll <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL < 14 ])
mmolm <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL > 105  ])
unkn <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL >= 14 & data$DIS_DETAIL_DATA_VAL <= 105 ])
err <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_DATA_VAL < 0 ])

length(unique(data$MISSION_DESCRIPTOR))


#plot good/bad data over time

plot( data$DIS_HEADER_SDATE, data$DIS_DETAIL_DATA_VAL, type = 'h')

#number of data points per year
year <- list()

for (i in 1932:2018){
  year[i] <- length(grep(data$DIS_HEADER_SDATE, pattern = i))
}

databyyear <- year[1932:2018]
year <- c(1932:2018)

#number of unflagged data per year
gooddata <- list()
for (i in 1932:2018){
  gooddata[i] <- length(grep(data$DIS_HEADER_SDATE[data$DIS_DETAIL_DATA_QC_CODE != 4 & data$DIS_DETAIL_DATA_QC_CODE != 5], pattern = i))
}
gooddata <- gooddata[1932:2018]

plot( year,unlist(databyyear), type = 'h', xlab = 'Year', ylab = 'Number of data points', col = 'red')
par(new = T)
plot(year, unlist(gooddata), type = 'h', xlab = '', ylab = '', axes = F)


##check metadata against master cruise list from MEDS##


master <- read.csv('meds_master_missions.csv')

#check if cruises from data set are in master cruise list
match <- 0
for (i in 1:length(data$MISSION_DESCRIPTOR)){
  g <- grep(master$CR_NUMBER, pattern = data$MISSION_DESCRIPTOR[i])
  if (length(g) > 0){
    match <- match +1
  }
}

#363716/390281 cruise numbers/mission descriptors match
#82395 data points dont match cruise names


a <- list()

for ( i in 1:length(data$MISSION_DESCRIPTOR)){
  g <- grep(master$CR_NUMBER, pattern = data$MISSION_DESCRIPTOR[i])
  if (length(g) == 0){
    a[i] <- data$MISSION_DESCRIPTOR[i]
  }
}

unlist(unique(a))

# 


#check start/end dates
#master mission list dates are in weird format, difficult to compare (YYYYMMDD - as numeric)
#convert to readable date
#dd <- as.character(master$startdate)
#as.Date(dd, "%Y%m%d")


#sink(file = 'date_check_3.txt')

mismatch <- list()
for (i in 1:length(data$MISSION_DESCRIPTOR)){
  g <- grep(master$CR_NUMBER, pattern = data$MISSION_DESCRIPTOR[i])
  if (length(g) > 0){
    sdate<- as.character(master$START_DATE[g])
    sdate <- as.Date(sdate, "%Y%m%d")
    edate<- as.character(master$END_DATE[g])
    edate <- as.Date(edate, "%Y%m%d")
    if (!(sdate <= as.Date(data$DIS_HEADER_SDATE[i]) & as.Date(data$DIS_HEADER_SDATE[i]) <= edate)){
mismatch[i] <- data$MISSION_DESCRIPTOR[i]
      
          }
    
  }
}


length(unique(unlist(mismatch)))


#sink()
 

##unkn data by cruise

uniqMissionID <- unique(data$MISSION_DESCRIPTOR)


unkn <- data$MISSION_DESCRIPTOR[data$DIS_DETAIL_DATA_VAL >= 14 & data$DIS_DETAIL_DATA_VAL <= 105]

unkn <- unique(unkn)

pdf(file = 'UnknownO2_byCruise.pdf')
for(i in 1:length(unkn)){
  plot(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == unkn[i]], main = paste(unkn[i]), ylab = 'Oxygen Value')
  abline(h = 14, col = 'red')
  abline(h = 105, col = 'red')
  
}

dev.off()


#check if sample Id's are repeated causing bimodal distribution of data 


for( i in 1:length(unkn)){
  b <- length(unique(data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == unkn[i]]))/length(data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR== unkn[i]])
  if( b < 1){
    print(paste('Warning, duplicated sample IDs in' , unkn[i]))
  }
}


#CHECK FOR DUPLICATED SAMPLE IDS IN ALL DATA
duplicatedSamples <- list()
for( i in 1:length(uniqMissionID)){
  b <- length(unique(data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == uniqMissionID[i]]))/length(data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR== uniqMissionID[i]])
  if( b < 1){
    print(paste('Warning, duplicated sample IDs in' , uniqMissionID[i]))
    duplicatedSamples[i] <- uniqMissionID[i]
  }
}
duplicatedSamples <- unlist(unique(duplicatedSamples))


for (i in 1:length(duplicatedSamples)){
  plot(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == duplicatedSamples[i]], main = paste(duplicatedSamples[i]), ylab = 'Oxygen Value')
  par(new = T)
  for (j in 1:length(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == duplicatedSamples[i]])){
    g <- grep(data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == duplicatedSamples[i]], pattern = data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == duplicatedSamples[i]][j])
  
    if(length(g) > 1){
      #trying to plot duplicated sample ID points in red, not working properly
    points(y = data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == duplicatedSamples[i]][g[2]], x = g[2], col = 'red')
  }
    }
  }






#CHECKING START AND END DATES FROM SHELLEY SPREADSHEET

G <- grep(master$CR_NUMBER, pattern = '')
master[G,]


#checking duplicate samples

s <- data$DIS_DETAIL_COLLECTOR_SAMP_ID[data$MISSION_DESCRIPTOR == '18HU00001']
d <- data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == '18HU00001']

dup <- cbind(s,d)

#order by sample ID
a <- dup[order(dup[,1]),]

tf <- duplicated(a[,1])
length(tf[tf == TRUE])

#10 duplicated sample IDs (18HU94008)
#1 duplicated sample ID (18HU00001)
#6 duplicated sample IDs (77DN91001)
#45 duplicated sample IDs (181183009)

samps <- a[tf == T,][,1]

w <- list()
for (i in 1:length(samps)){
  g <- a[a[,1] == samps[i],2]
  if (anyDuplicated(g) == 0){
    print(paste("sample Id's match, data values do not", samps[i]))
    w[i] <- samps[i]
  }
}

#4 matched sample Id's with different data (18HU94008)
#1 matched sample Id's with different data (18HU00001)
#6 matched sample Id's with different data (77DN91001)
#0 matched sample Id's with different data (181183009)

#not working to write out data to csv
w <- unlist(w)
sink('18HU00001_mismatchedSamples.txt')
for( i in 1:length(w)){
   print(data[data$MISSION_DESCRIPTOR == '18HU00001' & data$DIS_DETAIL_COLLECTOR_SAMP_ID == 221511,])
}
sink()

#18HU94008
# sampID  value1  value2
# 140283 395.3303 300.1599
# 140460 307.7521 301.0977
# 140523 358.7538 354.9130
# 140606  -4.10872 306.59090

#18HU00001
# 221511  359.0632  353.7040

#77DN91001
# 82445 308.6660 316.4557
# 82446 307.6923 319.3768
# 82447 314.5083 363.1938
# 82448 320.3505 371.9572
# 82449 336.9036 370.9834
# 82450 353.4567 370.0097



