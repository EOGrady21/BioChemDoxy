# get files for all missions of interest

require("inventory_files.r")

wdpath='C:/Gordana/Biochem_reload/working'
setwd(wdpath)

# list of all the cruises that have to reloaded
fn="cruise_list_reboot.xlsx"
path="//dcnsbiona01a/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise"

# name of the file with path
file=file.path(path,fn)

cruise_list=read_excel(file,sheet="cruise_list")

cruise_list=as.data.frame(cruise_list)

# replace empty spaces in the names with the underscore
names(cruise_list)=gsub(" ","_",names(cruise_list))

missions=cruise_list$Regional_Mission_ID

# remove NA
missions=missions[!is.na(missions)]


# get all the fies for the missions on the list
l=inventory_files(missions) # list of 2 dataframes, fdf has file names, par has parameters

# save both dataframes
write.csv(l$fdf,"mission_files.csv")
write.csv(l$par,"mission_parameters.csv")

# make a file with data filenames that will be used as reference for reload

read.csv("")