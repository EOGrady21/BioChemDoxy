#read in groundfish data
data <- readxl::read_xlsx('C:/Users/ChisholmE/Desktop/BIOCHEM/GROUNDFISH OXYGEN DATA.xlsx' )
#isolate by cruise
NED2013022 <- (5:935)
NED2014018 <- (937:1669)
NED2015017 <- (1674:2161) #CAUTIOUS OF DUPLICATE VALUE, x__4 IS ELECTRODE VALUE AVERAGED BETWEEN REPS


#read data column containing difference (Winkler- electrode)
DIFF <- as.numeric(as.character(data$X__6[-1]))
diff <- na.omit(DIFF)
length(diff)

#plot differences over both cruises due to minimal data points
plot(diff, type = 'h', xlab = 'Sample ID', ylab = 'Difference between methods (Winkler - Electrode)', main = 'Difference in O2 measurments from Groundfish surveys')
m <- mean(diff)
abline(h = m, col = 'red')

#isolate concentrations from Winkler measurments for relevant sample IDs
conc <- list()
for ( i in 1:2648){
  if(is.na(data$X__6[-1][i]) ){
    conc[i] <- NA
  }else{
    conc[i] <- as.numeric(data$X__5[-1][i]) 
  }
}
  

c <- na.omit(unlist(conc))
#conc <- data$X__5[!is.na(DIFF) ]

#plot differences over concentration
plot(conc, DIFF, xlab = 'Dissolved Oxygen Concentration (ml/L)', ylab = 'Difference between measurements (Winkler - electrode)')
abline(h = 0, col = 'blue')
#linear regression
cm <- lm(unlist(DIFF) ~unlist(conc))
abline(cm, col = 'red')

#plot potential correction factors 
#of 2, 4, 6 %
twoperc <- list()
for (i in 1:length(conc)){
  twoperc[i] <- as.numeric(conc[i]) *0.02
}

pm <- lm(unlist(twoperc)~unlist(conc))
abline(pm, col = 'green')

fourperc <- list()
for (i in 1:length(conc)){
  fourperc[i] <- as.numeric(conc[i]) *0.04
}

fm <- lm(unlist(fourperc)~unlist(conc))
abline(fm, col = 'orange')

sixperc <- list()
for (i in 1:length(conc)){
  sixperc[i] <- as.numeric(conc[i]) *0.06
}

sm <- lm(unlist(sixperc)~unlist(conc))
abline(sm, col = 'purple')

legend('bottomright', legend = c('2%', '4%', '6%'), col = c('green', 'orange', 'purple'), lty = 2, cex = 0.5 )
