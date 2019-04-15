#consolidate oxygen data into single csv from multiple cruise BCD files
#April 2019

#gather all BCD files
files <- list.files('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/BCD/', pattern = '*BCD_flagged', recursive = T)

#get header names
 b <- read.csv(paste0('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/BCD/', files[1]))
 h<- names(b)
x <- NA
# #write csv header for oxy data
 write.csv(x , file = 'oxygenBCD.csv',col.names = h)

#pull only oxygen data
#concecate into csv
#oxy <- as.data.frame(x = NA)
 files <- files[-2]
 
 oxy <- NA
for (i in 1:length(files)){
  #read bcd file
  bcd <- read.csv(paste0('C:/Users/ChisholmE/Documents/BIOCHEM/IML QC/BCD/', files[i]), header = T, row.names = NULL)
  
  #find oxygen data
  o <- grep(unique(bcd$DATA_TYPE_METHOD), pattern = '^O2_', value = T)
 
  oxy <- rbind(oxy, bcd[bcd$DATA_TYPE_METHOD %in% o ,])
 
  
             
 

}

 #add to conc. csv
 write.csv(oxy, file = 'oxygenBCD.csv')
 
 