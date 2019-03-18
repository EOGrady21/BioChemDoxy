<<<<<<< HEAD
##prepare cruise datat to be calibrated


##requires:
#     Concatenated QAT file
#     Oxygen xlsx file


path <- 'C:/Users/ChisholmE/Documents/BIOCHEM/DATA/SOC_calc/'

QAT <- list.files(path = 'C:/Users/ChisholmE/Documents/BIOCHEM/DATA/SOC_calc/QAT/')

#Oxy <- 
#cannot find consistent format oxygen files to work from
#take existing oxygen files and convert into consistent format
#read in concatenated BCD files
oxyDat <- readxl::read_xlsx('C:/Users/ChisholmE/Documents/BIOCHEM/DATA/winkler_2018-2011.xlsx')
cruise <- list('18HU11004', '18HU11043', '18HU12042')
Dat <- list()
#create 3 sub lists of winkler data
for (i in 1:length(cruise)){
  l <- grep(oxyDat$MISSION_DESCRIPTOR, pattern = cruise[i])
  if(cruise[i] == '18HU11004'){
  Dat$HUD11004 <- oxyDat[l,]
  }
  if (cruise[i] =='18HU11043'){
    Dat$HUD11043 <- oxyDat[l,]
  }
  if (cruise[i] == '18HU12042'){
    Dat$HUD12042 <- oxyDat[l,]
  }
}

=======
##prepare cruise datat to be calibrated


##requires:
#     Concatenated QAT file
#     Oxygen xlsx file


path <- 'C:/Users/ChisholmE/Documents/BIOCHEM/DATA/SOC_calc/'

QAT <- list.files(path = 'C:/Users/ChisholmE/Documents/BIOCHEM/DATA/SOC_calc/QAT/')

#Oxy <- 
#cannot find consistent format oxygen files to work from
#take existing oxygen files and convert into consistent format
#read in concatenated BCD files
oxyDat <- readxl::read_xlsx('C:/Users/ChisholmE/Documents/BIOCHEM/DATA/winkler_2018-2011.xlsx')
cruise <- list('18HU11004', '18HU11043', '18HU12042')
Dat <- list()
#create 3 sub lists of winkler data
for (i in 1:length(cruise)){
  l <- grep(oxyDat$MISSION_DESCRIPTOR, pattern = cruise[i])
  if(cruise[i] == '18HU11004'){
  Dat$HUD11004 <- oxyDat[l,]
  }
  if (cruise[i] =='18HU11043'){
    Dat$HUD11043 <- oxyDat[l,]
  }
  if (cruise[i] == '18HU12042'){
    Dat$HUD12042 <- oxyDat[l,]
  }
}

>>>>>>> 8d16c9adec107eab3c9823ff203975da149b937b
