# check which files are in the 1_REBOOT directories


# current working directory
wd="C:/Gordana/Biochem_reload/working" # at work

# Biochem inventory directory
# bcd="Z:/dcnsbiona01b/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise"

bcd=("Z:/BIOCHEMInventory/Data_by_Year_and_Cruise")

# set directory to Source data on network
setwd(bcd)

# pass shell results to R variable cc
cc=shell("dir *.xls* *.csv /s /b",intern=TRUE)

# find lines with 1_REBOOT folders
rblines=grep("1_REBOOT",cc)

# file names with paths in the 1_REBOOT subfolder
rbf=cc[rblines]

setwd(wd)

write.table(rbf,file="bc_reboot_files.txt",row.names=FALSE, col.names=FALSE)

# parse paths from file names

# find locations of the breaks
breaks=gregexpr("\\\\",rbf)

# find last break in eac=h line
last_break=unlist(lapply(breaks, function(x) tail(x,n=1)))
twoback=unlist(lapply(breaks, function(x) tail(x,n=2)))
threeback=unlist(lapply(breaks, function(x) tail(x,n=3)))

# extract file names
filenames=substr(rbf,last_break+2, nchar(rbf))
paths=substr(rbf,1,last_break)

# another way


