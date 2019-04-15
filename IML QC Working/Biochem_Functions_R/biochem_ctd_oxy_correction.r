# part of the BCD script that performs oxygen correction
# it takes winkler data from biolsum and ctd oxygen data from qat file, makes regresion and
# corrects CTD oxygen
# it was decided that CTD oxygen will not be corrected for BioChem historical data 
# so that part of the script was taken out
# the script does not work without main script (it was not converted to function)
# Gordana Lazin, June 27, 2016

# =============== #
#  OXY correction
# =============== #

# introduce oxy_flag to track if oxy correction
# oxy_flag=0 no oxy correction was made to qat file
# oxy_flag=1 oxy correction is aplied to qat oxy using winkler
oxy_flag=0

# check if BiolSum has o2_winkler

wb=grep("winkler",names(bsum),ignore.case=TRUE)

# if winkler exsists proceede with correction

if (length(wb)>0) {
  
  
  #  merge biolsum and qat based on the sample ID
  bsq=merge(bsum,qf, by.x="id",by.y="id", all=TRUE)
  
  # find out which oxy sensor is in qat file. 
  # This works for qat file that has oxy1, oxy2 or just oxy
  oxs=names(qf)[grep("oxy",names(qf))] # name of the oxy sensor (oxy1 or oxy2 or oxy)
  oxy_sensor=gsub("[[:alpha:]]","",original_sensors[grep("oxy",original_sensors)]) # original oxy sensor
  
  # define winkler and ctd oxy vectors
  winkler=bsq[,grep("winkler",names(bsq),ignore.case=TRUE)]
  ctd_oxy=bsq[,grep("oxy",names(bsq))]
  
  # correct CTD oxy sensor using "correct_oxy.r" function
  # corrected oxy is oxyc
  bsq$oxyc=correct_oxy(ctd_oxy,winkler, mission,oxy_sensor=oxy_sensor) 
  
  # add corrected oxy to qat dataframe qf
  qfc=merge(bsq[,c("id","oxyc")],qf,by="id",all.x=T,all.y=T)
  
  # replace original qat oxy with corrected oxy
  qf$oxy=qfc$oxyc
  
  oxy_flag=1
  
}

# qf is final qat file that has only one column for each sensor.
# the sensors used for each variable are stored in the "original_sensors" variable
# if correction of CTD oxygen data is applied using winkler "oxy_flag" is set to 1
# if there was no CTD oxy correction "oxy_flag" is set to 0

