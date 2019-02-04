#wink_probe_plots


source('wink_probe.R')


#Plot 1:1 relationship

#hud2011004
H11004_winkelec <- matrix(NA, nrow = 175, ncol = 2)
for( i in 1:175){
  if(!is.null(match[[i]])){
    H11004_winkelec[i,1] <- H11004_wink_data[[i]] 
    H11004_winkelec[i,2] <- H11004_elec_data[[match[[i]]]]
  # }else{
  #   H11004_winkelec[i,] <- NULL
   }
}

plot(H11004_winkelec[,1], H11004_winkelec[,2], xlim = c(0,7), ylim = c(0,7),xlab = 'Winkler Data', ylab = 'Electrode Data')
par(new = TRUE)
lm <- lm(H11004_winkelec[,1] ~ H11004_winkelec[,2])
abline(lm)
abline(coef = c(0, 1), col = 'red')
title(main = 'HUD2011004')
title(sub = 'R^2 = 0.9844')
plot(lm)

#hud2011043
H11043_winkelec <- matrix(NA, nrow = 310, ncol = 2)
for( i in 1:309){
  if(!is.null(match2[[i]])){
    H11043_winkelec[i,1] <- H11043_wink_data[[i]] 
    H11043_winkelec[i,2] <- H11043_elec_data[[match2[[i]]]]
  # }else{
  #   H11043_winkelec[i,] <- NULL
   }
}

plot(H11043_winkelec[,1], H11043_winkelec[,2], xlim = c(0, 7), ylim = c(0,7), xlab = 'Winkler Data', ylab = 'Electrode Data')
par(new = TRUE)
lm2 <- lm(H11043_winkelec[,1] ~ H11043_winkelec[,2])
abline(lm2)
abline(coef = c(0, 1), col = 'red')
title(main = 'HUD2011043')
title(sub = 'R^2 = 0.3697')

plot(lm2)

#hud2012042
length(H12042_elec_data) <- 486

H12042_winkelec <- matrix(NA, nrow = 486, ncol = 2)
for( i in 1:486){
  if(!is.null(match3[[i]])){
    H12042_winkelec[i,1] <- H12042_wink_data[[i]] 
    H12042_winkelec[i,2] <- H12042_elec_data[[match3[[i]]]]
   # }else{
   #   H12042_winkelec[i,] <- NULL
   }
}

plot(H12042_winkelec[,1], H12042_winkelec[,2],xlim = c(0,7), ylim = c(0,7), xlab = 'Winkler Data', ylab = 'Electrode Data')
par(new = TRUE)
lm3 <- lm(H12042_winkelec[,1] ~ H12042_winkelec[,2])
abline(lm3)
abline(coef = c(0, 1), col = 'red')
title(main = 'HUD2012042')
title(sub = 'R^2 = 0.4968')

plot(lm3)



#eliminate pressure dpendent relationship 

length(H11004_wink_dpth) <- 131
plot( H11004_wink_dpth, unlist(H11004_wink_elec_1), ylim = c(-2, 2), xlab = 'Depth (m)', ylab = 'Difference (Winkler - electrode)')
abline(h = 0, col = 'blue')
ll <- lm( unlist(H11004_wink_elec_1) ~ H11004_wink_dpth)
abline(ll, col = 'red')
title(main = 'HUD2011004', sub = 'R^2 = 0.01128')

summary(ll)
plot(ll)

dp2 <- list()
for (i in 1:length(H11043_wink_elec_1)){
  if(is.null(H11043_wink_elec_1[[i]])){
    dp2[i] <- NULL
  } else{
    dp2[i] <- H11043_wink_dpth[[i]]
  }
}
plot(unlist(dp2), unlist(H11043_wink_elec_1), ylim = c(-2, 2), xlab = 'Depth (m)', ylab = 'Difference (Winkler - Electrode)')
abline(h = 0, col = 'blue')
ll2 <- lm(unlist(H11043_wink_elec_1) ~ unlist(dp2))
abline(ll2, col = 'red')
title(main = 'HUD2011043', sub = 'R^2 = 0.00944')

summary(ll2)
plot(ll2)


dp3 <- list()
for (i in 1:length(H12042_wink_elec_1)){
  if(is.null(H12042_wink_elec_1[[i]])){
    dp3[i] <- NULL
  } else{
    dp3[i] <- H12042_wink_dpth[[i]]
  }
}
plot(unlist(dp3), unlist(H12042_wink_elec_1), ylim = c(-2, 2), xlab = 'Depth (m)', ylab = 'Difference (Winkler - Electrode)')
abline(h = 0, col = 'blue')
ll3 <- lm(unlist(H12042_wink_elec_1) ~ unlist(dp3))
abline(ll3, col = 'red')
title(main = 'HUD2012042', sub = 'R^2 = 0.7767')

summary(ll3)
plot(ll3)


#plot differences over concentrations

wd <- list()
for (i in 1:length(H11004_wink_data)){
  if (is.null(H11004_wink_elec_1[[i]])){
    wd[[i]] <- NULL
  } else{
    wd[[i]] <- H11004_wink_data[[i]]
  }
}

length(H11004_wink_elec_1) <- length(wd)

plot(unlist(wd), unlist(H11004_wink_elec_1), ylim = c(-3,3), xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
abline(h = 0, col = 'blue')
lh <- lm(unlist(H11004_wink_elec_1) ~ unlist(wd))
abline(lh, col = 'red')
title(main = 'HUD2011004')

summary(lh)

wd2 <- list()
for (i in 1:length(H11043_wink_elec_1)){
  if (is.null(H11043_wink_elec_1[[i]])){
    wd2[[i]] <- NULL
  } else{
    wd2[[i]] <- H11043_wink_data[[i]]
  }
}

wd2 <- unlist(wd2)
length(wd2) <- 56
plot(wd2, unlist(H11043_wink_elec_1), ylim = c(-3,3), xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
abline(h = 0, col = 'blue')
lh2 <- lm(unlist(H11043_wink_elec_1) ~ wd2)
abline(lh2, col = 'red')
title(main = 'HUD2011043')


summary(lh2)


wd3 <- list()

for (i in 1:length(H12042_wink_elec_1)){
  if (is.null(H12042_wink_elec_1[[i]])){
    wd3[[i]] <- NULL
    }
  else{
    wd3[[i]] <- H12042_wink_data[[i]]
  }
}

plot(unlist(wd3), unlist(H12042_wink_elec_1), ylim = c(-3,3), xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
abline(h = 0, col = 'blue')
lh3 <- lm(unlist(H12042_wink_elec_1) ~ unlist(wd3))
abline(lh3, col = 'red')
title(main = 'HUD2012042')


summary(lh3)


plot(unlist(wd), unlist(H11004_wink_elec_1), ylim = c(-3,3), xlim = c(4, 8), xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
abline(h = 0, col = 'black', lty = 2)
abline(lh, col = 'red')
par(new = TRUE)
plot(wd2, unlist(H11043_wink_elec_1), ylim = c(-3,3),xlim = c(4, 8), axes = FALSE,  xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
abline(lh2, col = 'blue')
par(new = TRUE)
plot(unlist(wd3), unlist(H12042_wink_elec_1), ylim = c(-3,3),xlim = c(4, 8), axes = FALSE, xlab = 'DO Concentrations, ml/l', ylab = 'Difference (Winkler - electrode)')
abline(lh3, col = 'green')

ALL_wink_elec_1 <- c(unlist(H11004_wink_elec_1), unlist(H11043_wink_elec_1), unlist(H12042_wink_elec_1))
ALL_wd <- c(unlist(wd), unlist(wd2), unlist(wd3))
l <- lm(ALL_wink_elec_1 ~ ALL_wd)
abline(l, col = 'purple')
legend('bottomright', c('R^2 = 0.8459', 'R^2 = 0.1072', 'R^2 = 0.3055', 'R^2 = 0.575'), col = c('red', 'blue', 'green', 'purple'), lty = 2, cex = 0.5)
