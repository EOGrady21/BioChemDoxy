###plot summary stats for o2 data###

library(readxl)

data <- read_xlsx('DATA/SHELLEY_NOV14.xlsx')


dates <- data$DIS_HEADER_SDATE

y <- 1:length(dates)
plot(dates,y, type = 'h', xlab = 'Year', ylab = 'Number of data points' )

library(maps)
library(oce)

lat <- data$DIS_HEADER_SLAT
lon <- data$DIS_HEADER_SLON

#x <- lonlat2map(lon, lat, projection = '+proj=merc')

mapPlot( longitudelim = c(-72,-48), latitudelim = c(37.5 , 48), type = 'polygon' , bg = 'blue', col = 'black',  projection = '+proj=merc')
par(new = TRUE)
mapPlot(lon, lat, longitudelim = c(-72,-48), latitudelim = c(37.5 , 48), type = 'p' , bg = 'blue', col = 'green',  projection = '+proj=merc')
#mapImage(lon,lat)



pre70 <- dates[dates < 1970-01-01]
dpre70 <- data[dates < 1970-01-01,]

plot(pre70, dpre70$DIS_DETAIL_DATA_VAL)

plot(dates, data$DIS_DETAIL_DATA_VAL, xlab = 'YEAR', ylab = 'Data Value')

missionID <- data$MISSION_DESCRIPTOR

dup <- duplicated(missionID)

for (i in 1:length(missionID)){
  if (dup[i] == T){
    missionID[i] <- NA
  }
}

missionID_unique <- na.omit(missionID)

missionRanges <- data.frame()

pdf(file = 'O2plots_bycruise.pdf')
for (i in 1:length(missionID_unique)){
  
  g <- grep(data$MISSION_DESCRIPTOR, pattern = missionID_unique[i])
  plot(data$DIS_DETAIL_DATA_VAL[g], xlab = 'sample', ylab = 'Oxygen Data Value')
  par(new = T)
  abline(h = min(data$DIS_DETAIL_DATA_VAL[g]), col = 'red')
  par(new = T)
  abline(h = max(data$DIS_DETAIL_DATA_VAL[g]), col = 'red')
  title(main = paste(missionID_unique[i]))
  # missionRanges[i,1] <- as.numeric(min(data$DIS_DETAIL_DATA_VAL[g]) )
  # missionRanges[i,2] <- as.numeric(max(data$DIS_DETAIL_DATA_VAL[g]) )
  # missionRanges[i,3] <- missionID_unique[i]
}
dev.off()

write.csv(missionRanges, file = 'missionRanges_o2.csv')


range <- read.csv('missionRanges_o2.csv', header = T)
for (i in 1:length(range[,1])){
  if (range$min[i] >= 105.0){
    range$unit_assumed[i] <- as.character('mmol/m3')
  }
  if (range$min[i] < 105 & range$max[i] > 105){
    range$unit_assumed[i] <- as.character('mixed')
  }
  if (range$max[i] <= 14.0){
    range$unit_assumed[i] <- as.character('ml/l')
  }
  if (range$max[i] < 105.0 & range$max[i] > 14.0){
    range$unit_assumed[i] <- as.character('UNKN')
    range$flag[i] <- 2 #suspect unit
  }
}

write.csv(range, file = 'missionRanges_o2.csv')

g <- grep(range$unit_assumed, pattern = 'UNKN')

for (i in 1:length(range[,1])){
  if(range$min[i] < 0 ){
    range$flag[i] <- 4 #impossible value
  } else {
    range$flag[i] <- 0
  }
  if (range$max[i] >600){
    range$flag[i] <- 4 #impossible value
  }
}

write.csv(range, file = 'missionRanges_o2.csv')


####pull out bad cruises####
###flag in master spreadsheet###

mr <- read.csv('missionRanges_o2.csv', header = T)
bad <- mr$missionID[mr$flag != 0]

for (i in 1:length(data$MISSION_DESCRIPTOR)){
if (data$MISSION_DESCRIPTOR[i] %in% bad){
  data$DIS_DETAIL_DATA_QC_CODE[i] <- 4
}
}
write.csv(data, file = 'allData_flagged.csv')



##tests

#plot mmolm3 distribution
#organize data
mmolm3 <- range$missionID[range$unit_assumed == 'mmol/m3']

mmmd <-data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR %in% mmolm3]

#plot( x = data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR %in% mmolm3], type = 'h')

a <- length(mmmd[mmmd < 50])
b <- length(mmmd[mmmd > 50 & mmmd < 100])
c <- length(mmmd[mmmd > 100 & mmmd < 150])
d <- length(mmmd[mmmd > 150 & mmmd < 200])
e <- length(mmmd[mmmd > 200 & mmmd < 250])
f <- length(mmmd[mmmd > 250 & mmmd <300])
g <- length(mmmd[mmmd > 300 & mmmd <350])
h <- length(mmmd[mmmd > 350 & mmmd <400])
i <- length(mmmd[mmmd > 400 & mmmd <450])
j <- length(mmmd[mmmd > 450 & mmmd <500])
k <- length(mmmd[mmmd > 500 & mmmd <550])
l <- length(mmmd[mmmd > 550 & mmmd <600])
m <- length(mmmd[mmmd > 600])

#plot to test for bimodal distribution
grouped <- c(a,b,c,d,e,f,g,h,i,j,k,l,m)
plot(grouped, type = 'h', axes = F, xlab = 'mmol/m3 Oxygen', ylab = 'number of samples')
axis(side= 2)
axis(side = 1, at = c(1:12), labels = c(seq(from = 50, to = 600, by = 50)))

#plot to test ml/l distribution
#organize data
mll <- range$missionID[range$unit_assumed == 'ml/l']
mlld <-data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR %in% mll]

a <- length(mlld[mlld < 0])
b <- length(mlld[mlld > 1 & mlld < 2])
c <- length(mlld[mlld > 2 & mlld < 3])
d <- length(mlld[mlld > 3 & mlld < 4])
e <- length(mlld[mlld > 4 & mlld < 5])
f <- length(mlld[mlld > 5 & mlld <6])
g <- length(mlld[mlld > 6 & mlld <7])
h <- length(mlld[mlld > 7 & mlld <8])
i <- length(mlld[mlld > 8 & mlld <9])
j <- length(mlld[mlld > 9 & mlld <10])
k <- length(mlld[mlld > 10 & mlld <11])
l <- length(mlld[mlld > 11 & mlld <12])
m <- length(mlld[mlld > 12 & mlld <13])
n <- length(mlld[mlld > 13 & mlld <14])
o <- length(mlld[mlld > 14 & mlld <15])
p <- length(mlld[mlld > 15 & mlld <16])
q <- length(mlld[mlld > 16 & mlld <17])
r <- length(mlld[mlld > 17])

#plotting
grouped <- c(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r)
plot(grouped, type = 'h', axes = F, xlab = 'ml/l Oxygen', ylab = 'number of samples')
axis(side= 2)
axis(side = 1, at = c(1:18), labels = c(seq(from = 0, to = 17, by = 1)))


#analyze range of data not in either unit category

unkn <- range$missionID[range$unit_assumed == 'UNKN']
unknd <-data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR %in% unkn]


a <- length(unknd[unknd < 10])
b <- length(unknd[unknd > 10 & unknd < 20])
c <- length(unknd[unknd > 20 & unknd < 30])
d <- length(unknd[unknd > 30 & unknd < 40])
e <- length(unknd[unknd > 40 & unknd < 50])
f <- length(unknd[unknd > 50 & unknd < 60])
g <- length(unknd[unknd > 60 & unknd <70])
h <- length(unknd[unknd > 70 & unknd <80])
i <- length(unknd[unknd > 80 & unknd <90])
j <- length(unknd[unknd > 90 & unknd <100])
k <- length(unknd[unknd > 450 & unknd <500])
l <- length(unknd[unknd > 100])

grouped <- c(a,b,c,d,e,f,g,h,i,j,k,l)
plot(grouped, type = 'h', axes = F, xlab = 'Unknown Oxygen Unit', ylab = 'number of samples')
axis(side= 2)
axis(side = 1, at = c(1:10), labels = c(seq(from = 10, to = 100, by = 10)))

plot(unknd)
abline(h = 14, col = 'red')

for (i in 1:length(unkn)){
  plot(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == unkn[i]], main = unkn[i])
}

#analyze range of mixed data

mix <- range$missionID[range$unit_assumed == 'mixed']
mixd <-data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR %in% mix]

plot(mixd, ylab = 'Oxygen value of unknown unit')
abline(h = 105, col = 'red')

stat <- list()

#check if significant portion of data per cruise is outside unit range

for ( i in 1:length(mix)){
  mixx <-data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == mix[i]]
  plot(mixx, ylab = 'Oxygen values', main = paste('Oxygen data from', mix[i]))
  abline(h = 105, col = 'red')
  stat[i] <- length(mixx[mixx < 105 | mixx > 600])/length(mixx)
  
}

#greater than 10% of data outside range
length(stat[stat > 0.1])

#flag suspicious data

ff <-mix[stat >0.1]
for (i in 1:length(range$missionID)){
  if ( range$missionID[i] %in% ff){
    #data$DIS_DETAIL_DATA_QC_CODE[data$MISSION_DESCRIPTOR == mix[i]] <- 4
    range$flag[i] <- 4
  }
}

write.csv(range, file = 'missionRanges_o2.csv')

#update master sheet
bad <- range$missionID[range$flag != 0]

for (i in 1:length(data$MISSION_DESCRIPTOR)){
  if (data$MISSION_DESCRIPTOR[i] %in% bad){
    data$DIS_DETAIL_DATA_QC_CODE[i] <- 4
  }
}
write.csv(data, file = 'allData_flagged.csv')




#check for duplicate cruises

#by sample ID

`%out%` <- function(a,b) ! a %in% b

percUniqSamp <- length(unique(data$DIS_DETAIL_COLLECTOR_SAMP_ID))/ length(data$DIS_DETAIL_COLLECTOR_SAMP_ID) 

unique <- unique(data$DIS_DETAIL_COLLECTOR_SAMP_ID)

dupd <- matrix(ncol = 4, nrow = length(data$DIS_DETAIL_DATA_VAL))
colnames(dupd) <- c('Sample ID', 'Value 1', 'Value 2', 'Number of duplicates')

for ( i in 1:length(data$DIS_DETAIL_DATA_VAL)){
  if (length(grep(data$DIS_DETAIL_COLLECTOR_SAMP_ID, pattern = data$DIS_DETAIL_COLLECTOR_SAMP_ID[i] )) == 1){
    ;
  }else{
   dupd[i, 1] <- data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]
   dupd[i, 2] <- data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_COLLECTOR_SAMP_ID == data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]][1]
    dupd[i, 3] <- data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_COLLECTOR_SAMP_ID == data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]][2]
     dupd[i, 4] <- length(data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_COLLECTOR_SAMP_ID == data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]])
  }
}
#didn't work, the number of duplicates is inaccurate

write.csv(dupd, file = 'duplicated_ID.csv')


#try a different way
a <- 0
tf <- data$DIS_DETAIL_COLLECTOR_SAMP_ID == -292
for ( i in 1:length(tf)){
  if(!is.na(tf[i])){
  if(tf[i] == T){
    a <- a+1
  }
  }
}
#successful test

for ( i in 1:length(data$DIS_DETAIL_COLLECTOR_SAMP_ID)){
  tf <- data$DIS_DETAIL_COLLECTOR_SAMP_ID == data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]
  a<- 0
  for(i in 1:length(tf)){
    if(!is.na(tf[i])){
      if(tf[i] == T){
        a <- a+1
      }
    }
  }
  dupd[i,1] <- data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]
  dupd[i, 2] <- data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_COLLECTOR_SAMP_ID == data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]][1]
  dupd[i, 3] <- data$DIS_DETAIL_DATA_VAL[data$DIS_DETAIL_COLLECTOR_SAMP_ID == data$DIS_DETAIL_COLLECTOR_SAMP_ID[i]][2]
  dupd[i, 4] <- a
}





# a <- 0
# for ( i in 1:length(range$missionID)){
#    d <- data$DIS_HEADER_SLAT[data$MISSION_DESCRIPTOR == range$missionID[i]]
#    for (k in 1:length(range$missionID)){
#      if ( i != k){
#      g <- data$DIS_HEADER_SLAT[data$MISSION_DESCRIPTOR == range$missionID[k]]
#      
#        
#      if (g == d){
#           a <- a+1
#           print(paste('Potential duplicate cruise', range$missionID[k], 'and', range$missionID[i]))
#      
#      }
#        }
#      }
#    }
sink(file = 'duplicated_cruise.txt')

for ( i in 1:length(range$missionID)){
  d <- data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == range$missionID[i]]
  for ( k in 1:length(range$missionID)){
    if (i != k){
      g <- data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == range$missionID[k]]
      dups <- anyDuplicated(c(g,d))
      if (dups/length(c(g,d)) > 0.6){
        cat(paste( 'Potential duplicate', range$missionID[i], 'and', range$missionID[k], 'with', (dups/length(c(g,d)))*100 , '% overlap.\n'))
      }
      
    }
  }
}
  sink()
plot(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == '90UG76003'], ylim= c(0,600))
par(new = T)
plot(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == '18NE15015'], col = 'red', ylim= c(100,600))
  


sink(file = 'duplicated_cruise_latlon.txt')

for ( i in 1:length(range$missionID)){
  lat <- data$DIS_HEADER_SLAT[data$MISSION_DESCRIPTOR == range$missionID[i]]
  lon <- data$DIS_HEADER_SLON[data$MISSION_DESCRIPTOR == range$missionID[i]]
  
  for ( k in 1:length(range$missionID)){
    if (i != k){
      lat2 <- data$DIS_HEADER_SLAT[data$MISSION_DESCRIPTOR == range$missionID[k]]
      lon2 <- data$DIS_HEADER_SLON[data$MISSION_DESCRIPTOR == range$missionID[k]]
      
      cc <- list(lat,lon)
      dd <- list(lat2, lon2)
      
      if (length(cc[[1]]) - length(dd[[1]]) <0 ){
        short <- cc
      } else{
        short <- dd
      }
      a <- 0
      for (l in 1:length(short[[1]])){
        if(cc[[1]][l] == dd[[1]][l] & cc[[2]][l] == dd[[2]][l]){
          a<- a+1
        }
      }
        if(a > 0 ){
          cat(paste('Duplicated lat lon values, check cruise', range$missionID[i], 'against', range$missionID[k], '\n'))
        }
      }
    }
  }

sink()

##check lat lons
plot(data$DIS_HEADER_SLAT[data$MISSION_DESCRIPTOR == '90UG76003'], data$DIS_HEADER_SLON[data$MISSION_DESCRIPTOR == '90UG76003'], ylim = c(-60, -35), xlim = c(40,60), xlab = 'Latitude' , ylab = 'Longitude')
par(new = T)
plot(data$DIS_HEADER_SLAT[data$MISSION_DESCRIPTOR == '90KE76001'], data$DIS_HEADER_SLON[data$MISSION_DESCRIPTOR == '90KE76001'], ylim = c(-60, -35), xlim = c(40,60), col = 'red', xlab = '', ylab = '')

#check data
plot(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == '90UG76003'], ylim  = c(100,400))
par(new = T)
plot(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == '90KE76001'], col ='red', ylim = c(100,400))

#check dates
dates <- data$DIS_HEADER_SDATE[data$MISSION_DESCRIPTOR == '90UG76003'] == data$DIS_HEADER_SDATE[data$MISSION_DESCRIPTOR == '90KE76001'] 
length(dates[dates ==T])



####check data centre codes####

dc <- unique(data$DATA_CENTER_CODE)
dcl <- list()

for (i in 1:length(dc)){
  dcl[i] <-  length(data$DIS_DETAIL_DATA_VAL[data$DATA_CENTER_CODE == dc[i]])
}
names(dcl) <- dc

tl <- dcl[[1]] + dcl[[2]] + dcl[[3]] +dcl[[4]] + dcl[[5]] + dcl[[6]] 
tl == length(data$DIS_DETAIL_DATA_VAL)
#no data points missing data centre code


