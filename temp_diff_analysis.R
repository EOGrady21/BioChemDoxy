#idea from kimiko analyze winkler - electrode over lab - insitu temp diffs

x <- readxl::read_xlsx('C:/Users/ChisholmE/Desktop/BIOCHEM/hud2011004_tdiff_exercise.xlsx')

w_e_diff <- x$`W - E difference`
t_diff <- x$`lab - in situ temp (mean)`

plot(t_diff, w_e_diff, xlab = 'Temperature difference (lab - in situ) degC', ylab = 'Oxygen difference (Winkler - Electrode) ml/l')
abline(h = 0, lty = 2)
