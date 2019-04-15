Station_Name_Lookup <- function(lon, lat) {
  
  # load packages
  library(sp)
    
  # load station info
  df.station <- read.table("c:/Gordana/BioChem-HUD2013004/R/AZMP_Stations_Definition.csv", header=TRUE, sep=",", stringsAsFactors=FALSE)
  df.poly <- read.table("C:/Gordana/BioChem-HUD2013004/R/AZMP_Stations_Polygons.csv", header=TRUE, sep=",", stringsAsFactors=FALSE)
  
  # convert input into data frame
  df <- data.frame("lon"=lon, "lat"=lat)
  
  # find unique lat/lon
  tmp <- unique(df)
  loc <- match(data.frame(t(df)), data.frame(t(tmp)))
  
  # preallocate output
  station <- rep("NA", length(tmp$lon))
  
  for (i in seq(1,nrow(tmp))) {
    
    # get index of station that is closest to location - approximate calculation
    d <- sqrt((df.station$lon-tmp$lon[i])^2+(df.station$lat-tmp$lat[i])^2)
    index <- order(d)
    
    # loop through defined stations to find a match
    matched <- FALSE
    j <- 0
    while (!matched) {
      j <- j+1
      if (j>length(df.station)) {
        break
      }
      matched <- point.in.polygon(tmp$lon[i], tmp$lat[i], df.poly$lon[df.poly$record==index[j]], df.poly$lat[df.poly$record==index[j]], mode.checked=FALSE)
    }
    
    # if match found
    if (matched) {
      station[i] <- df.station$short.name[index[j]]
    }
  }
  
  # output
  return(station[loc])
}
