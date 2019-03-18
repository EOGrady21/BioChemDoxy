##IML QC TESTING##

#separate data file by cruise

sepByCruise <- function(cruiseName, data = data){
  data[data$MISSION_DESCRIPTOR == cruiseName, ]
}


test <- sepByCruise(cruiseName = '77DN91001', data = data)

