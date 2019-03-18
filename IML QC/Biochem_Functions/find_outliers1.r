# Identify outliers in data
# Outliers are identified as values exceeding 1.5 inter quartile range.
# Gordana Lazin, April 28, 2016


find_outliers1 <- function(d1) {

  # determine outliers via boxplot
b=boxplot(d1, range=5, plot=FALSE)

# b$out contains all the outliers that are larger than 1.5*IQR
# b$stats[1] is upper whisker and b$stats[5] is lower whisker

# indices of outliers
ob=which(d1 %in% b$out)

# mean value
m1=mean(d1, na.rm=TRUE)

return(ob) #returns the indices of outliers
}