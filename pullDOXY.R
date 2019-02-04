###pull oxygen from CTD ODF files

library(oce)

path <- '~/BIOCHEM/'

files <- list.files(path, 'CTD*...*odf', ignore.case = TRUE)

data <- list()
metadata <- list()

for (i in 1:length(files)){
  

  o <- read.odf(paste0(path, files[i]), header = 'list')
  
  d <- grep(o[['dataNamesOriginal']], pasttern = 'DOXY')
  
  if( length(d) > 0){
    oxy <- o@data$oxygen
    data[i] <- oxy
    containsOxygen <- TRUE
  } else {
    data[i] <- NA
    containsOxygen <- FALSE
  }
  
  metadata[i] <- list(cruiseName = o[['cruiseName']], startDate = o[['startDate']], endDate = o[['endDate']], latitude = o[['latitude']], longitude = o[['longitude']], scientist = o[['scientist']], dataRow = i, oxygenMeasured = containsOxygen)
  
  
}