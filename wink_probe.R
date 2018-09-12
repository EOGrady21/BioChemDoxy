#pull wink vs probe

#read in BCD files
H11004_bcd <- read.csv('HUD2011004/HUD2011004_BCD_flagged.csv')
H11043_bcd <- read.csv('HUD2011043/HUD2011043_BCD_flagged.csv')
H12042_bcd <- read.csv('HUD2012042/HUD2012042_BCD_flagged.csv')

#find rows with winkler data
H11004_wink <- grep(H11004_bcd$DATA_TYPE_METHOD, pattern = 'O2_Winkler_Auto')
H11043_wink <- grep(H11043_bcd$DATA_TYPE_METHOD, pattern = 'O2_Winkler_Auto')
H12042_wink <- grep(H12042_bcd$DATA_TYPE_METHOD, pattern = 'O2_Winkler_Auto')

#find rows with probe data
H11004_elec <- grep(H11004_bcd$DATA_TYPE_METHOD, pattern = 'O2_Electrode_mll')
H11043_elec <- grep(H11043_bcd$DATA_TYPE_METHOD, pattern = 'O2_Electrode_mll')
H12042_elec <- grep(H12042_bcd$DATA_TYPE_METHOD, pattern = 'O2_Electrode_mll')

#pull winkler data
H11004_wink_data <- H11004_bcd$DIS_DETAIL_DATA_VALUE[H11004_wink]
H11004_wink_dpth <- H11004_bcd$DIS_HEADER_START_DEPTH[H11004_wink]

H11043_wink_data <- H11043_bcd$DIS_DETAIL_DATA_VALUE[H11043_wink]
H11043_wink_dpth <- H11043_bcd$DIS_HEADER_START_DEPTH[H11043_wink]

H12042_wink_data <- H12042_bcd$DIS_DETAIL_DATA_VALUE[H12042_wink]
H12042_wink_dpth <- H12042_bcd$DIS_HEADER_START_DEPTH[H12042_wink]

#pull probe data
H11004_elec_data <- H11004_bcd$DIS_DETAIL_DATA_VALUE[H11004_elec]
H11004_elec_dpth <- H11004_bcd$DIS_HEADER_START_DEPTH[H11004_elec]

H11043_elec_data <- H11043_bcd$DIS_DETAIL_DATA_VALUE[H11043_elec]
H11043_elec_dpth <- H11043_bcd$DIS_HEADER_START_DEPTH[H11043_elec]

H12042_elec_data <- H12042_bcd$DIS_DETAIL_DATA_VALUE[H12042_elec]
H12042_elec_dpth <- H12042_bcd$DIS_HEADER_START_DEPTH[H12042_elec]


#plots
plot(H11004_wink_data, H11004_wink_dpth, ylim = c(5000, 0), xlim = c(3, 9), col = 'blue', ylab = 'Depth (m)', xlab = 'O2 concentration (ml/l)',main = 'Oxygen data from HUD2011004', sub = 'Winkler vs Probe(Orion 842)')
par(new = TRUE)
plot(H11004_elec_data, H11004_elec_dpth, ylim = c(5000, 0), xlim = c(3, 9), axes = FALSE, col = 'black', xlab = '', ylab = '')
legend('bottomleft', legend = c('WINKLER', 'PROBE'), col = c('blue', 'black'), lty = 1, cex = 0.6)


plot(H11043_wink_data, H11043_wink_dpth, ylim = c(5000, 0), xlim = c(2, 9), col = 'blue', ylab = 'Depth (m)', xlab = 'O2 concentration (ml/l)',main = 'Oxygen data from HUD2011043', sub = 'Winkler vs Probe(Orion 842)')
par(new = TRUE)
plot(H11043_elec_data, H11043_elec_dpth, ylim = c(5000, 0), xlim = c(2, 9), axes = FALSE, col = 'black', xlab = '', ylab = '')
legend('bottomleft', legend = c('WINKLER', 'PROBE'), col = c('blue', 'black'), lty = 1, cex = 0.6)


plot(H12042_wink_data, H12042_wink_dpth, ylim = c(5000, 0), xlim = c(1, 9), col = 'blue', ylab = 'Depth (m)', xlab = 'O2 concentration (ml/l)',main = 'Oxygen data from HUD2012042', sub = 'Winkler vs Probe(Orion 842)')
par(new = TRUE)
plot(H12042_elec_data, H12042_elec_dpth, ylim = c(5000, 0), xlim = c(1, 9), axes = FALSE, col = 'black', xlab = '', ylab = '')
legend('bottomleft', legend = c('WINKLER', 'PROBE'), col = c('blue', 'black'), lty = 1, cex = 0.6)



#isolate individual bottles
#hud2011004
#pull sample ids
H11004_wink_id <- H11004_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[H11004_wink] #length = 137
H11004_elec_id <- H11004_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[H11004_elec] #length = 176
#These are different lengths meaning not all sample ids can match

length(H11004_wink_id) <- 176 #fix length issue
#combine lists
H11004_id <- cbind(H11004_wink_id, H11004_elec_id)
#compare lists
H11004_id_match <- H11004_wink_id == H11004_elec_id #useless
#most sample id's match but they are ordered differently, must compare 1 by 1

#create matching list wink:elec
match <- list()
for (i in 1:176){
  h <- H11004_wink_id[i] == H11004_elec_id
  m <- grep(h, pattern = TRUE)
  #m <- grep(pattern = H11004_wink_id[i], H11004_elec_id)
  if(length(m >0)){
  match[i] <- m
  }else{
    match[i] <- NULL
  }
}

#name list wink:elec
    #why is list only 175 items, should be 176, last is NULL?
names(match) <- c(1:175)

H11004_wink_elec <- list()
for (i in 1:175){
  if(!is.null(match[[i]])){
H11004_wink_elec[i] <- H11004_wink_data[[i]] - H11004_elec_data[[match[[i]]]]
  }else{
  H11004_wink_elec[i] <- NULL
}
}
#keeps subtracting one from length?
length(H11004_wink_elec) <- 175


#plot differences (wink-elec)

plot(unlist(match), unlist(H11004_wink_elec), type = 'h', xlab = 'sample ID', ylab = 'Winkler - electrode value')
mtext('Difference between Winkler and Electrode values 
      (HUD2011004)')
#stats

H11004_mean <- mean(unlist(H11004_wink_elec))


#hud2011043

#pull sample ids
H11043_wink_id <- H11043_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[H11043_wink] #length = 310
H11043_elec_id <- H11043_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[H11043_elec] #length = 71
#These are different lengths meaning not all sample ids can match

length(H11043_elec_id) <- 310 #fix length issue
#combine lists
H11043_id <- cbind(H11043_wink_id, H11043_elec_id)
#compare lists
H11043_id_match <- H11043_wink_id == H11043_elec_id #useless
#most sample id's match but they are ordered differently, must compare 1 by 1

#create matching list wink:elec
match2 <- list()
for (i in 1:310){
  h <- H11043_wink_id[i] == H11043_elec_id
  m <- grep(h, pattern = TRUE)
  #m <- grep(pattern = H11004_wink_id[i], H11004_elec_id)
  if(length(m >0)){
    match2[i] <- m
  }else{
    match2[i] <- NULL
  }
}

#name list wink:elec
#why is list one short of full length?
names(match2) <- c(1:309)

H11043_wink_elec <- list()
for (i in 1:309){
  if(!is.null(match2[[i]])){
    H11043_wink_elec[i] <- H11043_wink_data[[i]] - H11043_elec_data[[match2[[i]]]]
  }else{
    H11043_wink_elec[i] <- NULL
  }
}
#keeps subtracting one from length?
length(H11043_wink_elec) <- 310


#plot differences (wink-elec)

plot(unlist(match2), unlist(H11043_wink_elec), type = 'h', xlab = 'sample ID', ylab = 'Winkler - electrode value')
mtext('Difference between Winkler and Electrode values 
      (HUD2011043)')
#stats

H11043_mean <- mean(unlist(H11043_wink_elec))


#Hud2012042
#pull sample ids
H12042_wink_id <- H12042_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[H12042_wink] #length = 486
H12042_elec_id <- H12042_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID[H12042_elec] #length = 207
#These are different lengths meaning not all sample ids can match

length(H12042_elec_id) <- 486 #fix length issue
#combine lists
H12042_id <- cbind(H12042_wink_id, H12042_elec_id)
#compare lists
H12042_id_match <- H12042_wink_id == H12042_elec_id #useless
#most sample id's match but they are ordered differently, must compare 1 by 1

#create matching list wink:elec
match3 <- list()
for (i in 1:486){
  h <- H12042_wink_id[i] == H12042_elec_id
  m <- grep(h, pattern = TRUE)
  #m <- grep(pattern = H11004_wink_id[i], H11004_elec_id)
  if(length(m >0)){
    match3[i] <- m
  }else{
    match3[i] <- NULL
  }
}

#name list wink:elec
#why is list only 175 items, should be 176, last is NULL?
names(match3) <- c(1:486)

H12042_wink_elec <- list()
for (i in 1:486){
  if(!is.null(match3[[i]])){
    H12042_wink_elec[i] <- H12042_wink_data[[i]] - H12042_elec_data[[match3[[i]]]]
  }else{
    H12042_wink_elec[i] <- NULL
  }
}
#keeps subtracting one from length?
length(H12042_wink_elec) <- 486


#plot differences (wink-elec)

plot(unlist(match3), unlist(H12042_wink_elec), type = 'h', xlab = 'sample ID', ylab = 'Winkler - electrode value')
mtext('Difference between Winkler and Electrode values 
      (HUD2012042)')
#stats

H12042_mean <- mean(unlist(H12042_wink_elec))

##more stats

sd(unlist(H11004_wink_elec))

sd(unlist(H11043_wink_elec))

sd(unlist(H12042_wink_elec))

max(abs(unlist(H12042_wink_elec)))

max(abs(unlist(H11004_wink_elec)))

max(abs(unlist(H11043_wink_elec)))

##is the mean difference significantly diffrent from zero?
  #t test

a <- 0.01

H12042_t <- t.test(x = unlist(H12042_wink_elec))

H11043_t <- t.test(x = unlist(H11043_wink_elec))

H11004_t <- t.test(x = unlist(H11004_wink_elec))

ci1 <- H11004_t$conf.int
ci2 <- H11043_t$conf.int
ci3 <- H12042_t$conf.int

x <- c(1: 200)

a <- unlist(H11004_wink_elec)
b <- unlist(H11043_wink_elec)
c <- unlist(H12042_wink_elec)

length(a) <- 200
length(b) <- 200
length(c) <- 200
plot(x, a, col = 'black', ylim = c(-2.5, 2.5), xlab = 'Sample ID', ylab = "Difference Winkler - Electrode (ml/l)" )
mtext('Difference between 
      Winkler and Electrode Methods')
mtext("Black: HUD2011004,
  Blue: HUD2011043, 
  Red: HUD2012042", side = 1, cex = 0.8, line = -2)
par(new = TRUE)
plot(x, b, col = 'blue', ylim = c(-2.5, 2.5), axes = FALSE, xlab = '', ylab = '')
par(new = TRUE)
plot(x, c, col = 'red', ylim = c(-2.5, 2.5), axes = FALSE, xlab = '', ylab = '')

#confidence interval lines
abline(h = ci1[[1]], col = 'black')
abline(h = ci1[[2]], col = 'black')
abline(h = ci2[[1]], col = 'blue')
abline(h = ci2[[2]], col = 'blue')
abline(h = ci3[[1]], col = 'red')
abline(h = ci3[[2]], col = 'red')
# #legend
# legend('topright', c('HUD2011004', 'HUD2011043', 'HUD2012042'), col = c('black', 'blue', 'red'), lty = 2, cex = 0.8, title = 'Cruise Number')

#linear regression of differences (?)
# alm <- lm(a~x)
# abline(alm, col = 'black', lty = 2)
# 
# blm <- lm(b~x)
# abline(blm, col = 'blue', lty = 2)
# 
# clm <- lm(c~x)
# abline(clm, col = 'red', lty = 2)

##find outliers
# > max(abs(unlist(H12042_wink_elec)), na.rm = TRUE)
# [1] 2.457
# > grep(H12042_wink_elec, pattern = 2.457)
# [1] 477
# > match3[[477]]
# [1] 198
# > match3[477]
# $`477`
# [1] 198
# 
# > H12042_elec_data[[198]]
# [1] 5.757
# > H12042_wink_data[[477]]
# [1] 3.3
# > H12042_elec_id[[198]]
# [1] 386345
# > H12042_wink_id[[477]]
# [1] 386345

# max(abs(unlist(H11043_wink_elec)), na.rm = TRUE)
# grep(H11043_wink_elec, pattern = 2.813)
# match2[67]
# H11043_elec_data[[13]]
# H11043_wink_data[[67]]
# H11043_elec_id[[13]]
# H11043_wink_id[[67]]



H11004_wink_flags <- H11004_bcd$DIS_DETAIL_DATA_QC_CODE[H11004_bcd$DATA_TYPE_METHOD == 'O2_Winkler_Auto']
H11004_wink_1 <- H11004_wink_data[H11004_wink_flags == 1]
H11004_wink_id_1 <- H11004_wink_id[H11004_wink_flags == 1]

#create matching list wink:elec
# mm <- list()
# for (i in 1:75){
#   h <- H11004_wink_id_1[i] == H11004_elec_id
#   m <- grep(h, pattern = TRUE)
#   #m <- grep(pattern = H11004_wink_id[i], H11004_elec_id)
#   if(length(m >0)){
#     mm[i] <- m
#   }else{
#     mm[i] <- NULL
#   }
# }
# names(mm) <- c(1:75)
# 
# H11004_wink_elec_1 <- list()
# for (i in 1:75){
#   if(!is.null(mm[[i]])){
#     H11004_wink_elec_1[i] <- H11004_wink_data[[i]] - H11004_elec_data[[mm[[i]]]]
#   }else{
#     H11004_wink_elec_1[i] <- NULL
#   }
# }
#plot()



#create data frame

H11004 <- as.data.frame(cbind(H11004_bcd$DIS_HEADER_START_DEPTH, as.character(H11004_bcd$DATA_TYPE_METHOD), H11004_bcd$DIS_DETAIL_DATA_VALUE, H11004_bcd$DIS_DETAIL_DATA_QC_CODE, H11004_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID))
w <- grep(H11004$V2, pattern = 'O2_Winkler_Auto')
e <- grep(H11004$V2, pattern = 'O2_Electrode_mll')

k <- c(w, e)

H11004 <- H11004[k,,]

H11043 <- as.data.frame(cbind(H11043_bcd$DIS_HEADER_START_DEPTH, as.character(H11043_bcd$DATA_TYPE_METHOD), H11043_bcd$DIS_DETAIL_DATA_VALUE, H11043_bcd$DIS_DETAIL_DATA_QC_CODE, H11043_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID))
w <- grep(H11043$V2, pattern = 'O2_Winkler_Auto')
e <- grep(H11043$V2, pattern = 'O2_Electrode_mll')

k <- c(w, e)

H11043 <- H11043[k,,]

H12042 <- as.data.frame(cbind(H12042_bcd$DIS_HEADER_START_DEPTH, as.character(H12042_bcd$DATA_TYPE_METHOD), H12042_bcd$DIS_DETAIL_DATA_VALUE, H12042_bcd$DIS_DETAIL_DATA_QC_CODE, H12042_bcd$DIS_DETAIL_COLLECTOR_SAMP_ID))
w <- grep(H12042$V2, pattern = 'O2_Winkler_Auto')
e <- grep(H12042$V2, pattern = 'O2_Electrode_mll')

k <- c(w, e)

H12042 <- H12042[k,,]

#write as csv's

# write.csv(H11004, file = 'H11004.csv')
# write.csv(H11043, file = 'H11043.csv')
# write.csv(H12042, file = 'H12042.csv')


#eliminate outliers (past 1.5 IQT, and flagged values)

#calculate iqt
H11004_iqr<- IQR(H11004_wink_data, na.rm = TRUE)
H11043_iqr <- IQR(H11043_wink_data, na.rm = TRUE)
H12042_iqr <- IQR(H12042_wink_data, na.rm = TRUE)

#calculate 1.5 iqt
H11004_iqr_1.5 <- 1.5*(H11004_iqr)
H11043_iqr_1.5 <- 1.5*(H11043_iqr)
H12042_iqr_1.5 <- 1.5*(H12042_iqr)

#calculate mean
H11004_wink_mean <- mean(H11004_wink_data)
H11043_wink_mean <- mean(H11043_wink_data)
H12042_wink_mean <- mean(H12042_wink_data)

#plot cruise by cruise
#hud2011004
plot( c(1:length(H11004_wink_data)), unlist(H11004_wink_data), xlab = 'Sample ID', ylab = 'Oxygen COncentration (ml/L)')
mtext('Dissolved Oxygen Winkler Measurements
      HUD2011004')
par(new = TRUE)
abline(h = H11004_wink_mean, col = 'blue')
uiqr <- 0.5*(H11004_iqr_1.5) + H11004_wink_mean
liqr <- H11004_wink_mean - 0.5*(H11004_iqr_1.5) 
abline(h = uiqr, col = 'red')
abline(h = liqr, col = 'red')

#null values outside 1.5 iqt
H11004_wink_data[H11004_wink_data > uiqr] <- NA
H11004_wink_data[H11004_wink_data < liqr] <- NA

plot(c(1:length(H11004_wink_data)), unlist(H11004_wink_data), ylim = c(3,9), xlab = 'Sample ID', ylab = 'Dissolved OXygen (ml/L)')
mtext('Winkler Oxygen Measurements after QC
      HUD2011004')
mtext('Red lines represent 1.5 IQT', side = 1, cex = 0.8)
abline(h = uiqr, col = 'red')
abline(h = liqr, col = 'red')

#hud2011043
plot( c(1:length(H11043_wink_data)), unlist(H11043_wink_data), xlab = 'Sample ID', ylab = 'Oxygen COncentration (ml/L)')
mtext('Dissolved Oxygen Winkler Measurements
      HUD2011043')
par(new = TRUE)
abline(h = H11043_wink_mean, col = 'blue')
uiqr2 <- 0.5*(H11043_iqr_1.5) + H11043_wink_mean
liqr2 <- H11043_wink_mean - 0.5*(H11043_iqr_1.5) 
abline(h = uiqr2, col = 'red')
abline(h = liqr2, col = 'red')

#null values outside 1.5 iqt
H11043_wink_data[H11043_wink_data > uiqr2] <- NA
H11043_wink_data[H11043_wink_data < liqr2] <- NA

plot(c(1:length(H11043_wink_data)), unlist(H11043_wink_data), ylim = c(3, 7), xlab = 'Sample ID', ylab = 'Dissolved OXygen (ml/L)')
mtext('Winkler Oxygen Measurements after QC
      HUD2011043')
mtext('Red lines represent 1.5 IQT', side = 1, cex = 0.8)
abline(h = uiqr2, col = 'red')
abline(h = liqr2, col = 'red')

#hud2012042
plot( c(1:length(H12042_wink_data)), unlist(H12042_wink_data), xlab = 'Sample ID', ylab = 'Oxygen Concentration (ml/L)')
mtext('Dissolved Oxygen Winkler Measurements
      HUD2012042')
par(new = TRUE)
abline(h = H12042_wink_mean, col = 'blue')
uiqr3 <- 0.5*(H12042_iqr_1.5) + H12042_wink_mean
liqr3 <- H12042_wink_mean - 0.5*(H12042_iqr_1.5) 
abline(h = uiqr3, col = 'red')
abline(h = liqr3, col = 'red')

#null values outside 1.5 iqt
H12042_wink_data[H12042_wink_data > uiqr3] <- NA
H12042_wink_data[H12042_wink_data < liqr3] <- NA

plot(c(1:length(H12042_wink_data)), unlist(H12042_wink_data), ylim = c(2,7), xlab = 'Sample ID', ylab = 'Dissolved Oxygen (ml/L)')
mtext('Winkler Oxygen Measurements after QC
      HUD2012042')
mtext('Red lines represent 1.5 IQT', side = 1, cex = 0.8)
abline(h = uiqr3, col = 'red')
abline(h = liqr3, col = 'red')



#plot differences after removal
#hud2011004
H11004_wink_elec_1 <- list()
for( i in 1:175){
  if(!is.null(match[[i]])){
    H11004_wink_elec_1[i] <- H11004_wink_data[[i]] - H11004_elec_data[[match[[i]]]]
  }else{
    H11004_wink_elec_1[i] <- NULL
  }
}
plot(unlist(match), unlist(H11004_wink_elec_1), type = 'h', xlab = 'Sample ID', ylab = 'Winkler - Electrode (DO , ml/L)')
mtext('Difference between Winkler and Electrode values (post QC)
      HUD2011004')



#hud2011043
H11043_wink_elec_1 <- list()
for( i in 1:310){
  if(!is.null(match2[[i]])){
    H11043_wink_elec_1[i] <- H11043_wink_data[[i]] - H11043_elec_data[[match2[[i]]]]
  }else{
    H11043_wink_elec_1[i] <- NULL
  }
}
plot(unlist(match2), unlist(H11043_wink_elec_1), type = 'h', xlab = 'Sample ID', ylab = 'Winkler - Electrode (DO , ml/L)')
mtext('Difference between Winkler and Electrode values (post QC)
      HUD2011043')

#hud2012042
H12042_wink_elec_1 <- list()
for( i in 1:486){
  if(!is.null(match3[[i]])){
    H12042_wink_elec_1[i] <- H12042_wink_data[[i]] - H12042_elec_data[[match3[[i]]]]
  }else{
    H12042_wink_elec_1[i] <- NULL
  }
}
plot(unlist(match3), unlist(H12042_wink_elec_1), type = 'h', xlab = 'Sample ID', ylab = 'Winkler - Electrode (DO , ml/L)')
mtext('Difference between Winkler and Electrode values (post QC)
      HUD2012042')


##post QC depth profiles

plot(H11004_wink_data, H11004_wink_dpth, ylim = (c(5000, 0)), xlim = c(4,9), xlab = 'DO ml/L', ylab = 'Depth (m)', main = 'HUD2011004')
par(new = TRUE)
plot(H11004_elec_data, H11004_elec_dpth, ylim = (c(5000, 0)),xlim = c(4,9), axes = FALSE, col = 'blue', xlab = '', ylab = '')
legend('bottomright',  c('Winkler', 'Electrode'), col = c('black', 'blue'), lty = 1)

plot(H11043_wink_data, H11043_wink_dpth, ylim = (c(5000, 0)), xlim = c(4,9), xlab = 'DO ml/L', ylab = 'Depth (m)', main = 'HUD2011043')
par(new = TRUE)
plot(H11043_elec_data, H11043_elec_dpth, ylim = (c(5000, 0)),xlim = c(4,9), axes = FALSE, col = 'blue', xlab = '', ylab = '')
legend('bottomright',  c('Winkler', 'Electrode'), col = c('black', 'blue'), lty = 1)

plot(H12042_wink_data, H12042_wink_dpth, ylim = (c(5000, 0)), xlim = c(4,9), xlab = 'DO ml/L', ylab = 'Depth (m)', main = 'HUD2012042')
par(new = TRUE)
plot(H12042_elec_data, H12042_elec_dpth, ylim = (c(5000, 0)),xlim = c(4,9), axes = FALSE, col = 'blue', xlab = '', ylab = '')
legend('bottomright',  c('Winkler', 'Electrode'), col = c('black', 'blue'), lty = 1)


#average by depth

#combine data and depth
H11004_wink_dpth_x <- cbind(H11004_wink_data, H11004_wink_dpth)
#sort by depth
H11004_wink_dpth_srtd <- H11004_wink_dpth_x[order(H11004_wink_dpth_x[,2]),]

#caluclate moving average
mavg <- list()
for (i in 1:271){
    mavg[i] <- mean(H11004_wink_dpth_srtd[1][i: i+3], na.rm = TRUE)
}
