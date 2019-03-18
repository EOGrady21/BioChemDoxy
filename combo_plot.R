#estimating correction coefficient
source('wink_elec_reg.R')
source('groundfish_O2.R')

#bring together all sample ID difference over concentration

plot(unlist(wd), unlist(H11004_wink_elec_1), ylim = c(-3,3), xlim = c(4, 8), xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
par(new = TRUE)
plot(wd2, unlist(H11043_wink_elec_1), ylim = c(-3,3),xlim = c(4, 8), xlab = '', ylab = '', axes = FALSE, col = 'red')
par(new = TRUE)
plot(unlist(wd3), unlist(H12042_wink_elec_1), ylim = c(-3,3), xlim = c(4, 8), xlab = '', ylab = '', axes = FALSE, col = 'blue')
par(new = TRUE)
plot(conc, DIFF,ylim = c(-3,3), xlim = c(4, 8), xlab = '', ylab = '', axes = FALSE, col = 'green')

l <- c(4: 8)
ll <- l*0.02
lll <- l*0.04

par(new = TRUE)
plot(l, ll, ylim = c(-3, 3), xlim = c(4,8), xlab = '', ylab = '', axes = FALSE, col = 'purple', type = 'l')

par(new = TRUE)
plot(l, lll, ylim = c(-3, 3), xlim = c(4,8), xlab = '', ylab = '', axes = FALSE, col = 'orange', type = 'l')



 O2_DIFF <- cbind(unlist(H11004_wink_elec_1), unlist(H11043_wink_elec_1) , unlist(H12042_wink_elec_1), DIFF )
 O2_diff <- unlist(O2_DIFF)
 O2_diff <- as.vector(c(O2_diff[,1], O2_diff[,2], O2_diff[,3], O2_diff[,4]))
 O2_CONC <- cbind(unlist(wd), wd2, unlist(wd3), conc)
 O2_conc <- unlist(O2_CONC)

 #linear regression
om <- lm(O2_diff ~ O2_conc)

#attempt at non linear pattern , unsuccessful
lo <-loess(O2_diff ~O2_conc)


plot(O2_conc, O2_diff, xlab = 'DO concentration (ml/L)', ylab = 'Difference (Winkler - electrode)')
#lines(predict(lo))
abline(om, col = 'purple', lty = 2)


#plot differences over concentrations
plot(unlist(wd), unlist(H11004_wink_elec_1), ylim = c(-3,3), xlim = c(4, 8), xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
par(new = TRUE)
plot(wd2, unlist(H11043_wink_elec_1), ylim = c(-3,3),xlim = c(4, 8), xlab = '', ylab = '', axes = FALSE )
par(new = TRUE)
plot(unlist(wd3), unlist(H12042_wink_elec_1), ylim = c(-3,3), xlim = c(4, 8), xlab = '', ylab = '', axes = FALSE, col = 'red')
par(new = TRUE)
plot(conc, DIFF,ylim = c(-3,3), xlim = c(4, 8), xlab = '', ylab = '', axes = FALSE)
abline(om, lty = 2)
