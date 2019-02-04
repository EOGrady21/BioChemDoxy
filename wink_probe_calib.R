#attempting to bring probe in line with winklers


source('wink_elec_reg.R')

H11004_slope <- lh$coefficients[2]
H11043_slope <- lh2$coefficients[2]
H12042_slope <- lh3$coefficients[2]

avg_slope <- mean(c(H11004_slope, H11043_slope, H12042_slope))

H11004_int <- lh$coefficients[1]
H11043_int <- lh2$coefficients[1]
H12042_int <- lh3$coefficients[1]

avg_int <- mean(c(H11004_int, H11043_int, H12042_int))
