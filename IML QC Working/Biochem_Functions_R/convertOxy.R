#' Convert Oxygen data from mmol/m**3 to ml/l
#' Accepts data in BCD format
#' Converts oxygen data using standard 44.66 conversion factor



convertOxy <- function(data, missions) {
  for (i in 1:length(missions)) {
    g <-
      grep(unique(data$DATA_TYPE_METHOD[data$MISSION_DESCRIPTOR == missions[i]]),
           pattern = '^O2_Winkler',
           value = T)
    key <- data[data$MISSION_DESCRIPTOR == missions[i],]
    key <- key[key$DATA_TYPE_METHOD %in% g , ]
    
    key$DIS_DETAIL_DATA_VALUE <- key$DIS_DETAIL_DATA_VALUE / 44.66
    
    data$DIS_DETAIL_DATA_VALUE[data$MISSION_DESCRIPTOR == missions[i] & data$DATA_TYPE_METHOD %in% g] <- key$DIS_DETAIL_DATA_VALUE
    
    data$DIS_DETAIL_DATA_VALUE[data$MISSION_DESCRIPTOR == missions[i] & data$DATA_TYPE_METHOD %in% g]
    
    return(data)
    #not ouputting converted data 
    
    }
}