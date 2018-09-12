##search for MCTD oxygen data
library(ncdf4)
path <- '~/MOORED DATA PROCESSING/archiveConverter/v2/mctd/new/'

files <- list.files(path , pattern = '*.nc')
oxyf <- list()

for (i in 1:length(files)){
  
  nc <- nc_open(paste0(path, files[i]))
  g <- grep(nc$var, pattern = "*OXY*")
  if (length(g) > 0 ){
    
    oxyf[i] <- files[i]
  }
    nc_close(nc)
    print(paste( i, "out of", length(files), "completed."))
}

filename <- f
startDate <- list()
endDate <- list()
lat <- list()
lon <- list()

for (i in 1:length(f)){
  nc <- nc_open(paste0(path, f))
  sd <- ncatt_get(nc, 0, 'time_coverage_start')
  startDate[i] <- sd$value
  ed <- ncatt_get(nc, 0, 'time_coverage_end')
  endDate[i] <- ed$value
  la <-  ncatt_get(nc, 0, 'latitude')
   lat[i] <- la$value
 lo <- ncatt_get(nc, 0, 'longitude')
 lon[i] <- lo$value
  nc_close(nc)
}

table <- cbind(filename, startDate, endDate, lat, lon)

write.table(x = table, file = "MCTD_DOXY_SUMMARY.txt")
