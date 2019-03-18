winkler <- c('O2_Winkler', 'O2_Winkler_Auto')

for (i in 1:length(unique(data$MISSION_DESCRIPTOR))) {
  #isolate by mission
  miss <- unique(data$MISSION_DESCRIPTOR)[i]
  
  #determine range
  if (max(data$DIS_DETAIL_DATA_VAL[data$MISSION_DESCRIPTOR == miss &
                                   data$DATA_TYPE_METHOD %in% winkler]) <= 14) {
  }else {
    #rename data_type_method for molar
    data$DATA_TYPE_METHOD[data$MISSION_DESCRIPTOR == miss &
                            data$DATA_TYPE_METHOD %in% winkler] <-
      as.factor('O2_Winkler_Molar')
  }
}

#write out new file
write.csv(data, file = 'Oxy_corrected.csv')