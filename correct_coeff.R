source('combo_plot.R')

#typical O2 concentrations

o <- seq(from = 4, to =8, by = 0.25)

#write om as equation for linear regression
x <- o

y <- 0.253*x - 1.254

x <- as.numeric(data$X__3)

oo <- na.omit(y)

#apply adjustment to data
oc <- list()
for (i in 1:length(data$X__3)){
  oc[i] <- as.numeric(data$X__3[i]) + y[i]
}

occ <- na.omit(unlist(oc))

#plot original vs corrected
plot(data$X__5, oc, xlim = c(0,8), ylim = c(0,8), xlab = 'Winkler measurements (ml/L)', ylab = 'Electrode measurements (ml/L)')
abline(coef = c(0,1))
par(new = TRUE)
#add original for reference
plot(data$X__5, data$X__3, xlim = c(0,8), ylim = c(0,8), col = 'red', axes = FALSE, xlab = '', ylab = '')

#regress original and corrected
gflmorg <- lm(as.numeric(data$X__5) ~ as.numeric(data$X__3))
gflmcorr <- lm(as.numeric(data$X__5) ~ unlist(oc))
abline(gflmorg, col = 'red', lty = 2)
abline(gflmcorr, col = 'black', lty = 2)

#apply regression of original data as correction coefficient
ggg <- as.numeric(data$X__3) * 1.1170 - 0.3888
par(new = TRUE)
#plot for reference on original and previously corrected data
plot(data$X__5, ggg, xlab = '', ylab = '', xlim = c(0,8), ylim = c(0,8), axes = FALSE, col = 'blue')
gflmcorr2 <- lm(data$X__5 ~ ggg)
abline(gflmcorr2, col = 'blue', lty = 2)
#cc <- cbind(x, y)
mtext(side = 3, 'Original Data (red) slope = 1.1170, 
      Corrected data (Eqn 2- black) slope = 0.8914, 
      Corrected data (Eqn 4- blue) slope = 1.00')

#combine other data sources in correct order
ordered11004 <- list()
for (i in 1:175){
  if(!is.null(match[[i]])){
    ordered11004[i] <-  H11004_elec_data[[match[[i]]]]
  }else{
    ordered11004[i] <- NA
  }
}
ordered11043 <- list()
for (i in 1:309){
  if(!is.null(match2[[i]])){
    ordered11043[i] <-  H11043_elec_data[[match2[[i]]]]
  }else{
    ordered11043[i] <- NA
  }
}


ordered12042 <- list()
for (i in 1:486){
  if(!is.null(match3[[i]])){
    ordered12042[i] <-  H12042_elec_data[[match3[[i]]]]
  }else{
    ordered12042[i] <- NA
  }
}

#combine into single vector for each measurement method from AZMP cruises
ww <- as.vector(cbind(
H11004_wink_data,
H11043_wink_data,
H12042_wink_data
))

ee <- as.vector(cbind(
unlist(ordered11004),
unlist(ordered11043),
unlist(ordered12042)
))

#plot AZMP cruises
plot(ww, ee, xlim = c(0,10), ylim = c(0,10), col = 'red', xlab  = 'Winkler measurements', ylab = 'Electrode measurements')
par(new = TRUE)



#use method 1 of correction
xx <- ee
y <- 0.253*xx - 1.254

ec <- list()
for (i in 1:length(ee)){
ec[i] <- ee[i] + y[i]
}

#plot for reference
plot(ww, ec, xlim = c(0,10), ylim = c(0,10), xlab = '', ylab = '', axes = FALSE)
abline(coef = c(0,1))
#issue with previous data, not plotting properly

#try again, ensure samples are matching

#use data that has been fully QC, remove outliers and flagged values

H1 <- read.csv('H11004.csv', header = TRUE)
H2 <- read.csv('H11043.csv', header = TRUE)
H3 <- read.csv('H12042.csv', header = TRUE)

plot(H1$DIS_DETAIL_DATA_VALUE, H1$DIS_DETAIL_DATA_VALUE.1, xlim = c(3,9), ylim = c(3,9), xlab = 'Winkler', ylab = 'Electrode')
par(new = TRUE)
plot(H2$DIS_DETAIL_DATA_VALUE, H2$DIS_DETAIL_DATA_VALUE.1, xlim = c(3,9), ylim = c(3,9), axes = FALSE, xlab = '', ylab = '')
par(new = TRUE)
plot(H3$DIS_DETAIL_DATA_VALUE, H3$DIS_DETAIL_DATA_VALUE.1, xlim = c(3,9), ylim = c(3,9),  axes = FALSE, xlab = '', ylab = '')
abline(coef = c(0,1))

#combine into single vectors
wink <- as.vector(c(H1$DIS_DETAIL_DATA_VALUE, H2$DIS_DETAIL_DATA_VALUE, H3$DIS_DETAIL_DATA_VALUE))
elec <- as.vector(c(H1$DIS_DETAIL_DATA_VALUE.1, H2$DIS_DETAIL_DATA_VALUE.1, H3$DIS_DETAIL_DATA_VALUE.1))

#apply method 1 adjustment
xxx <- elec
y <- 0.253*xxx - 1.254

eec <- list()
for (i in 1:length(elec)){
  eec[i] <- elec[i] + y[i]
}

#plot for reference
plot(wink, elec, xlab = 'Winkler', ylab = 'Electrode', xlim = c(0,10), ylim = c(0,10), col = 'red')
par(new = TRUE)
plot(wink, eec, xlab = '', ylab = '', axes = FALSE, xlim = c(0,10), ylim = c(0,10))
abline(coef = c(0,1), col = 'blue')

#regression on original and corrected
corrlm <- lm(wink~unlist(eec))
orglm <- lm(wink~elec)

abline(orglm, col = 'red', lty = 2)
abline(corrlm, lty = 2 )

mtext(side = 3, 'Original Data (red) slope = 1.144,
      Corrected using eqn 2 (black) slope = 0.9133,
      Corrected using eqn 3 (blue) slope = 1.00')

corrlm
orglm

#correct using regression on original data
eee <- list()

for (i in 1:length(elec)){
  eee[i] <- elec[i] *1.1444 -0.6477
}
#plot for reference
par(new = TRUE)
plot(wink, eee, axes = FALSE, xlim = c(0,10), ylim = c(0,10), xlab = '', ylab = '', col = 'blue')

newcorrlm <- lm(wink ~ unlist(eee))
abline(newcorrlm, col = 'purple', lty = 2)


#combine all data from AZMP and groundfish
wt <- as.vector(c(data$X__5[-1], wink))
et <- as.vector(c(data$X__3[-1], elec))

#plot original data
plot(wt, et, xlim = c(0, 10), ylim = c(0,10), col = 'red', xlab = 'Winkler (ml/L)', ylab = 'Electrode (ml/L)')
#regression of original data
ttlm <- lm(wt ~as.numeric(et))
abline(ttlm, col = 'red', lty = 2)
#plot 1:1 line reference
abline(coef = c(0,1), col = 'blue')

#apply correction factor following ttlm regression equation
eet <- list()
for (i in 1:length(et)){
  eet[i] <- as.numeric(et[i])*1.1424 - 0.6171
}
#plot corrected data for comparision
par(new = TRUE)
plot(wt, eet, xlim = c(0,10), ylim = c(0,10), xlab = '', ylab = '', axes = FALSE, col = 'blue')
mtext(side = 3, 'Original data (red), Corrected data (blue)')
#regress corrected data to ensure high correlation and 1.00 slope
ttcor <- lm(wt ~ unlist(eet))

#calculate original and corrected differences
wt_et <- list()
for (i in 1:length(wt)){
  wt_et[i] <- as.numeric(wt)[i] - as.numeric(et)[i]
}
wt_eet <- list()
for (i in 1:length(wt)){
  wt_eet[i] <- as.numeric(wt[i]) - as.numeric(eet[i])
}

#plot differences
plot(unlist(wt_et), type = 'h', ylim = c(-1,1), col = 'red', xlab = 'Sample ID', ylab = 'Difference (Winkler - electrode)')
par(new = TRUE)
plot(unlist(wt_eet), type = 'h', ylim = c(-1,1), axes = FALSE, xlab = '', ylab = '')

etm <- mean(unlist(wt_et), na.rm = TRUE)
eetm <- mean(unlist(wt_eet), na.rm = TRUE)

abline(h = etm, col = 'red', lty = 2)
abline(h = eetm, col = 'black', lty = 2)
mtext(side = 3, 'Original data differences (red), corrected data differences (black)')


#plot new corrected data over DO concentration


plot(eet, wt_eet, xlim = c(2,9), ylim = c(-1,1), ylab = 'Differences (Winkler - Electrode**corrected)', xlab = "Dissolved oxygen concentration (ml/L)")
#

#attempt to estimate RMSE and RMSD
pred <- list()
for (i in 1:length(eet)){
pred[i] <- as.numeric(eet)[i] - 2.494e-05
}

for (i in 1:length(eet)){
rmse <- sqrt(1/length(eet) * sum((as.numeric(eet)[i] - unlist(pred)[i])^2))
}

library(seewave)
d <- unlist(eet) - unlist(pred)

RMSD <- rms(d, na.rm = T)

# n <- 0
# for (i in 1:length(hhh)){
#   if (!is.na(hhh[i])){
#     if (hhh[i] == TRUE){
#         n <- n+1
#     }
#   }
# }





