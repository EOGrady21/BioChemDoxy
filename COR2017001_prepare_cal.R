#' Prepare the COR2017001 discrete data for calibrating the CTD data.

#' Bedford Institute of Oceanography, Fisheries and Oceans Canada.
#' You may distribute under the terms of either the GNU General Public
#' License or the Apache v2 License, as specified in the README file.

#' Script to prepare the discrete CTD data and bottle oxygen and conductivity data 
#' to be used in calibrating the CTD data.
#' 
#' Output:
#'   COR2017001_Prepared_Data.RData: a copy of the workspace containing the 
#'   variables created and resulting calibration coefficients.
#'
#' IMPORTANT NOTES:
#' 
#'   Added .Rprofile to the project directory in order to set up some required settings to make 
#'   this code run correctly.  Especially running the command: options(stringsAsFactors = FALSE) 
#'   because this kept factor levels from being assigned to the data frame which was causing a lot
#'   of issues with the conductivity processing.
#'
#'   Report any bugs to DataServicesDonnees@@calDFo-mpo.gc.ca
#' 
#' ODSToolbox Version: 2.0
#' 
#' Author: Jeff Jackson
#' Created: 16-JAN-2018
#' Last Updated: 29-JAN-2018
#' 
#' @export 
#' @examples
#' COR2017001_prepare_cal()
#' 
#' @details 
#' Source:
#'   Ocean Data and Information Services,
#'   BecalDFord Institute of Oceanography, DFO, Canada.
#'   DataServicesDonnees@@calDFo-mpo.gc.ca
#' 
#' @author Ocean Data and Information Services
#'

# ------------------------------------------------------------------------
#   Updates:
# 
#     Jeff Jackson (29-JAN-2018)
#     - Fixed code to include secondary CTD sensor data.
#     
#     Emily Chisholm (24-OCT-2018)
#     - Updated to read from BCD source file
# ------------------------------------------------------------------------

####  The oxygen and conductivity outlier calculations were done based on the 1.5 IQR 

library(xlsx)
library(dplyr)
library(gsw)
library(oce)

# setwd("D:/Data/AZMP/2017/COR2017001/DATASHOP_PROCESSING/Calibrations")

cat("Preparing the data has started ...")

# ------------------------------------------------------------------------
#   Read the Discrete CTD Data (Concatenated QAT files)
# ------------------------------------------------------------------------

qatFile <- "DATA/SOC_calc/QAT/HUD2011004_QAT.csv"

# Read in the discrete CTD data (concatenated QAT files).
 colClassQ <- c("character","character","integer",rep("numeric",2),rep("integer",2),
              "character","character",rep("numeric",4),"integer",rep("numeric",3),
               "integer",rep("numeric", 11)) #updated for length of cols
# qatDF <- read.xlsx2(qatFile, 1, colIndex=1:35, colClasses=colClassQ)
qatDF <- read.csv(qatFile,  colClasses = colClassQ)
#producing error from RJavaTools
#read in as csv instead

#rm(colClassQ)

Event <- qatDF$station
Sample_ID <- qatDF$sample_id

qatDF <- qatDF %>%
  dplyr::arrange(Event,Sample_ID) %>% #properly orders oxygen report by event and sample ID
  dplyr::mutate(ID=row.names(qatDF)) #Adds a new variable called ID that can be used to plot the data and/or keep it sorted properly

# ------------------------------------------------------------------------
#   Read the Winkler Dissolved Oxygen Data
# ------------------------------------------------------------------------

#oxyFile <- "Oxygen_COR2017001.xlsx"

# Read in the discrete oxygen data.
#colClassO <- c("character","integer",rep("numeric",4),rep("character",4),rep("numeric",3),"character")
#oxyDF <- read.xlsx2(oxyFile, 1, colIndex=1:14, colClasses=colClassO, startRow = 9)
#rm(colClassO)
#edit to prep from BCD source
oxyDF <- Dat$HUD11004          #sub list for each cruise

# Find which oxygen values are NaN and change them to NA.
#inan <- which(oxyDF$O2_Concentration.ml.l. == "NaN")
#oxyDF$O2_Concentration.ml.l.[inan] <- NA

# Get the unique Oxygen Sample IDs.
#oxyID <- as.numeric(substr(oxyDF$Sample, 1, 6))
oxyID <- as.numeric(oxyDF$DIS_DETAIL_COLLECTOR_SAMP_ID)


# Identify the indices for the unique and duplicate Oxygen Sample IDs.
UO <- !duplicated(oxyID)
DO <- duplicated(oxyID)

# Get the Oxygen IDs that are unique and duplicate(s).
oxyUniqID <- oxyID[which(UO == TRUE)]
oxyDupID <- oxyID[which(DO == TRUE)]

# Get the unique Oxygen values.
#oxyUniqBottle <- oxyDF$O2_Concentration.ml.l.[UO]
oxyUniqBottle <- oxyDF$DIS_DETAIL_DATA_VAL[UO]

# Create an bottle oxygen duplicate array the same size as the
# unique oxygen array. Put the duplicate values in the corresponding
# index for the identical Sample ID.
oxyDupBottle <- array(data=NA,dim=length(oxyUniqID))
for (i in 1:length(oxyDupID)) {
  j <- which((oxyID == oxyDupID[i]) == TRUE)
  
  # Get the values for each ID.
  dupOxy <- oxyDF$O2_Concentration[j[2]]
  
  # Find the index for the current ID in oxyDupID.
  k <- which((oxyUniqID == oxyDupID[i]) == TRUE)
  
  # Put the duplicate oxygen value into the oxyDupBottle array.
  oxyDupBottle[k] <- dupOxy
}

# Clear temporary variables.
rm(i, j, k, UO, DO, oxyID, dupOxy)

####SALINITY####
# ------------------------------------------------------------------------
#   Read the Autosal Salinity Data
# ------------------------------------------------------------------------
#NO SALINITY DATA ONLY OXYGEN

# salFile <- "Salinity_COR2017001_final.xlsx"
# 
# # Get the discrete salinity data.
# colClassS <- c("character",rep("integer",2),rep("character",3),rep("numeric",6),"character")
# condDF <- read.xlsx2(salFile, 1, colIndex=1:13, colClasses=colClassS)
# rm(colClassS)
# 
# # Where the Bottle_Label value is blank assign it as "NA".
# condDF$Bottle.Label[condDF$Bottle.Label==""] <- NA
# 
# # Get the indices of the records that contain a Sample ID or Standard Batch Number.
# x <- which(!is.na(condDF$Bottle.Label) == TRUE)
# 
# # Get the indices that only refer to a numeric Sample ID.
# y1 <- which(condDF$Bottle.Label[x] != "Conditioning sample") 
# y2 <- which(condDF$Bottle.Label[x] != "P158")
# y <- intersect(y1, y2)
# 
# # Drop all records except those containing a numeric Sample ID.
# condDF <- condDF[x[y],]
# 
# # Update the data frame by dropping all clevels that no longer exist
# condDF <- droplevels(condDF)
# 
# condID <- as.numeric(condDF$Bottle.Label)
# condBottle <- as.numeric(condDF$Adjusted.Ratio)
# salBottle <- as.numeric(condDF$Calculated.Salinity)
# 
# # Standard Batch P158
# Standard_K15 <- 0.99970
# KCl_Conductivity <- 42.914
# Standard_Salinity <- 34.998
# Standard_Conductivity <- KCl_Conductivity * Standard_K15
# condBottle <- condBottle * Standard_Conductivity # mS/cm
# 
# # Clear temporary variables.
# rm(Standard_K15, KCl_Conductivity, Standard_Salinity, Standard_Conductivity)
# rm(x, qatFile, oxyFile, salFile)
# rm(y, y1, y2)
####   ####


# Now create vectors for the Bottle Oxygen and Conductivity data that are
# the same size as the CTD vectors.
sampleID <- qatDF$Sample.id
y = length(sampleID)
oxygenBottleID <- array(data=NA,dim=y)
oxygenBottle <- array(data=NA,dim=y)
oxygenBottleDuplicate <- array(data=NA,dim=y)
#conductivityBottleID <- array(data=NA,dim=y)
#conductivityBottle <- array(data=NA,dim=y)
#salinityBottle <- array(data=NA,dim=y)
rm(y)

# Find the indices for each Oxygen ID.
for (i in 1:length(oxyUniqID)) {
  j <- which((sampleID == oxyUniqID[i]) == TRUE)

  # Put the Oxygen information into the correct spots in the full vectors.
  oxygenBottleID[j] <- oxyUniqID[i]
  oxygenBottle[j] <- oxyUniqBottle[i]
  oxygenBottleDuplicate[j] <- oxyDupBottle[i]
}
rm(i, j, oxyUniqID, oxyUniqBottle, oxyDupID, oxyDupBottle)

# Find the indices for each Conductivity ID.
# for (i in 1:length(condID)) {
#   j <- which((sampleID == condID[i]) == TRUE)
# 
#   # Put the Conductivity information into the correct spots in the full vectors.
#   conductivityBottleID[j] <- condID[i]
#   conductivityBottle[j] <- condBottle[i]
#   salinityBottle[j] <- salBottle[i]
# }
# rm(i, j, condID, condBottle, salBottle)

nrows <- length(sampleID)

# Create a data.frame to hold the oxygen data.
# nrows = length(sampleID)
# oxyReportDF <- data.frame()
station_number <- qatDF$Station.number
oxyReportDF <- data.frame(station_number)
oxyReportDF$Event <- qatDF$Station.number
oxyReportDF$SAMPLE_ID <- sampleID
oxyReportDF$Start_Depth <- qatDF$Pressure
oxyReportDF$Oxy_CTD_P <- qatDF$Primary.Oxygen.ML.L
oxyReportDF$Oxy_CTD_S <- qatDF$Secondary.Oxygen.ML.L
oxyReportDF$Oxy_W_Rep1 <- oxygenBottle
oxyReportDF$Oxy_W_Rep2 <- oxygenBottleDuplicate

# Output the Oxygen report.
write.table(oxyReportDF, file = "HUD2011004_Oxygen_Rpt.csv", quote = FALSE, sep = ",", row.names = FALSE, na = "")

# Create a data.frame to hold the salinity data.
# salReportDF <- data.frame(station_number)
# salReportDF$Event <- qatDF$station
# salReportDF$SAMPLE_ID <- sampleID
# salReportDF$Start_Depth <- qatDF$PrdM
# salReportDF$Temp_CTD_P <- qatDF$T068C # IPTS-68
# salReportDF$Temp_CTD_S <- qatDF$T168C # IPTS-68
# salReportDF$Cond_CTD_P <- qatDF$C0S.m # S/m
# salReportDF$Cond_CTD_S <- qatDF$C1S.m # S/m
# salReportDF$Sal_CTD_P <- qatDF$Sal00 # PSU
# salReportDF$Sal_CTD_S <- qatDF$Sal11 # PSU
# salReportDF$Sal_Rep1 <- salinityBottle # PSU
# salReportDF$Sal_Rep2 <- array(data=NA,dim=length(sampleID))

# Output the Oxygen report.
#write.table(salReportDF, file = "COR2017001_Salinity_Rpt.csv", quote = FALSE, sep = ",", row.names = FALSE, na = "")

# rm(conductivityBottle, conductivityBottleID)
rm(oxygenBottleID, oxygenBottle, oxygenBottleDuplicate)
rm(conductivityBottleID, conductivityBottle, salinityBottle)
rm(station_number, inan, nrows, sampleID)

# Save the workspace variables to the file 'COR2017001_Prepared_Data.RData'.
save.image(file = 'HUD2011004_Prepared_Data.RData')

cat('The prepared data has been saved to the file HUD2011004_Prepared_Data.R')
