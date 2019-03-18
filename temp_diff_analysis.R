<<<<<<< HEAD
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


plot(x$X__11, w_e_diff, xlab = 'Temperature (degC)', ylab = 'Oxygen Difference (Winkler - electrode) ml/l')
=======
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


plot(x$X__11, w_e_diff, xlab = 'Temperature (degC)', ylab = 'Oxygen Difference (Winkler - electrode) ml/l')
>>>>>>> 8d16c9adec107eab3c9823ff203975da149b937b
##not working yet