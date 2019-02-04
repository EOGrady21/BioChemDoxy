##new data set


newOxy <- read.csv('C:/Users/ChisholmE/Desktop/BIOCHEM/DATA/NewOxyData.csv', header = T)

#compare electrode and winkler

plot(newOxy$Winkler[1:505], newOxy$Electrode.ML.l[1:505], xlab = 'Winkler (ml/L)', ylab = 'Electrode (ml/L)', xlim = c(0,9), ylim = c(0,9))
par(new = TRUE)
plot(newOxy$Winkler[506:541], newOxy$Electrode.ML.l[506:541], xlab = '', ylab = '', axes = F, xlim = c(0,9), ylim = c(0,9), col = 'red')
abline(coef = c(0,1), col = 'blue')

#data points from 1:505 flagged as suspicious, perfect 1:1 relationship with Winklers

#proceed with analysis on data points 506:541
#plot differences
dataDiff <- newOxy$Winkler[506:541] - newOxy$Electrode.ML.l[506:541]
plot(dataDiff, type = 'h', xlab = 'Sample ID', ylab = 'Difference (Winkler - Electrode, ml/L)')
mdd <- mean(dataDiff, na.rm = T)
abline(h = mdd, col = 'red')
#average difference = 0.246667

#plot differences over concentration to confirm pattern

plot(newOxy$Winkler[506:541], dataDiff, xlim = c(2.5, 8.5), ylim = c(-1, 1), xlab = 'DO concentration (ml/L)', ylab = 'Difference (Winkler - electrode, ml/L)')
abline(h = 0, col = 'green', lty = 2)

#agrees with trend of increase over concentration

#attempt to apply conversion equation

convElec <- newOxy$Electrode.ML.l*1.1424 - 0.6171

plot(newOxy$Winkler[506:541], newOxy$Electrode.ML.l[506:541], col = 'red', ylim = c(0,9), xlim = c(0,9), xlab = 'Winkler (ml/L)', ylab = 'Electrode (ml/L)')
par(new = T)
plot(newOxy$Winkler[506:541], convElec[506:541], col = 'blue', ylim = c(0,9), xlim = c(0,9), xlab = '', ylab = '')
abline(coef = c(0,1), col = 'green')


#run some statsitics

newlm <- lm(newOxy$Winkler[506:541] ~ convElec[506:541])
#slope = 0.9860, int = 0.1947

abline(newlm, lty = 3, col = 'blue')

oldlm <- lm(newOxy$Winkler[506:541] ~ newOxy$Electrode.ML.l[506:541])
abline(oldlm, lty = 2, col = 'red')

#attempt to estimate RMSE and RMSD

pred2 <- seq(from = 1, to = 8, by = 0.0129399)


for (i in 1:length(convElec)){
  rmse <- sqrt(1/length(convElec) * sum((as.numeric(convElec)[i] - unlist(pred2)[i])^2))
}

library(seewave)
d <- unlist(convElec) - unlist(pred2)

RMSD <- rms(d, na.rm = T)

#normalize rmse
rmse_norm <- rmse/8
#plot corrected data over concentration

plot(convElec[506:541], dataDiff, xlim = c(2.5, 8.5), ylim = c(-1, 1), xlab = 'DO concentration (ml/L)', ylab = 'Difference (Winkler - electrode, ml/L)')
abline(h = 0, col = 'blue', lty = 2)
par(new = T)
plot(newOxy$Winkler[506:541], dataDiff, col = 'red', xlim = c(2.5, 8.5), ylim = c(-1, 1), xlab = 'DO concentration (ml/L)', ylab = 'Difference (Winkler - electrode, ml/L)')
