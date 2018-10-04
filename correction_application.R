##general template for applying correction to oxy data

#read in oxy data
filename <- 
  
csv <- read.csv(filename)

#isolate electrode values

electrode_data <- csv$O2_electrode_mll

#apply correction algorithm


####function####
oxyCorrect <- function(oxy){
  newOxy <- oxy*1.1424 - 0.6171
  return(newOxy)
}
####end function####

#correct data
corrected_electrode <- oxyCorrect(electrode_data)

#combine with old data
new_data <- as.data.frame(c(csv, corrected_electrode))

#add new column name
col_names <- names(csv)
col_names[length(col_names)+1] <- O2_electrode_mll_corr

#write new csv file
write.csv(file = paste0(filename, '_ver2'), x = new_data, col.names = col_names)



