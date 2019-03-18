<<<<<<< HEAD
####FLAGGING REPORT ON IML QC####


#FIND FLAG FILES

path <- 'D:/DATA/REBOOT_flags/'
files <- list.files(path, pattern = '*BCD_flagged.csv', recursive = T)

#flagReview <- function(path){}
#files <- list.files(path, pattern = '*BCD_flagged.csv', recursive = T)

#READ Files

for ( i in 1:length(files)){
  
#read flags
  
  d <- read.csv(paste0(path , files[[i]]))

#COMPILE INVESTIGATION REQUIRED FLAGS
  flag7 <- d[d$DIS_DETAIL_DATA_QC_CODE == 7,]

#GROUP SUSPECTED CAUSES OF ERROR
  #constant values, check all profiles to ensure water column is not just v well
  #mixed, then flag as bad
  
  #if it is very different from CTD value, 
      #check is offset is consistent due to calibration error
      #check if CTD values are valid
      #other
  
  

#MAKE DECISIONS 


#MODIFY FLAGS
  
}
=======
####FLAGGING REPORT ON IML QC####


#FIND FLAG FILES

path <- 'D:/DATA/REBOOT_flags/'
files <- list.files(path, pattern = '*BCD_flagged.csv', recursive = T)

#flagReview <- function(path){}
#files <- list.files(path, pattern = '*BCD_flagged.csv', recursive = T)

#READ Files

for ( i in 1:length(files)){
  
#read flags
  
  d <- read.csv(paste0(path , files[[i]]))

#COMPILE INVESTIGATION REQUIRED FLAGS
  flag7 <- d[d$DIS_DETAIL_DATA_QC_CODE == 7,]

#GROUP SUSPECTED CAUSES OF ERROR
  #constant values, check all profiles to ensure water column is not just v well
  #mixed, then flag as bad
  
  #if it is very different from CTD value, 
      #check is offset is consistent due to calibration error
      #check if CTD values are valid
      #other
  
  

#MAKE DECISIONS 


#MODIFY FLAGS
  
}
>>>>>>> 8d16c9adec107eab3c9823ff203975da149b937b
