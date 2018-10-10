#idea from kimiko analyze winkler - electrode over lab - insitu temp diffs

x <- readxl::read_xlsx('C:/Users/ChisholmE/Desktop/BIOCHEM/hud2011004_tdiff_exercise.xlsx' )

w_e_diff <- x$`W - E difference`
t_diff <- x$`lab - in situ temp (mean)`


plot(t_diff, w_e_diff, xlab = 'Temperature difference (lab - in situ) degC', ylab = 'Oxygen difference (Winkler - Electrode) ml/l')
abline(h = 0, lty = 2)


#hud2011043

x <- readxl::read_xlsx('C:/Users/ChisholmE/Desktop/BIOCHEM/hud2011043_temp_ex.xlsx')


w_e_diff <- x$O2_Winkler_Auto - x$o2_ml
t_diff <- x$`temp diff`


plot(t_diff, w_e_diff, xlab = 'Temperature difference (lab - in situ) degC', ylab = 'Oxygen difference (Winkler - Electrode) ml/l')
abline(h = 0, lty = 2)


#PLOT OVER TEMPERATURE

#GET TEMPERATURE PER SAMPLE
t <- list()
for (i in 3:359){
  if (x$X__1[i] == x$X__1[i +1]){
    t[i] <- (as.numeric(x$X__2[i]) + as.numeric(x$X__2[i+1])) /2
  } 
}
length(t) <- 360

names(t) <- x$X__1

tnew <- list()
for (i in 1:length(x$X__10)){
l <- grep(names(t), pattern = x$X__10)
  if (!is.na(l)){
  tnew[i] <- t[l]
  }
}

##not working yet