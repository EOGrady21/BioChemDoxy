# get list of exl files

setwd("//dcnsbiona01b/BIODataSvcSrc/BIOCHEMInventory/Data_by_Year_and_Cruise")

shell("dir *.xls *.csv /s /b > allfiles_test.txt")

cm=paste("find /n ", shQuote(rb, type = "cmd"), "allfiles_test.txt > reboot_files.txt")

shell("find /n ""1_REBOOT"" allfiles_test.txt > reboot_files.txt")



# second way
shell("dir *.xls *.csv /s /b > allfiles_test.txt")

x=read.csv("allfiles_test.txt", stringsAsFactors=FALSE, header=FALSE)
rb=grep("1_REBOOT",x$V1)





# third way
# pass shell results to R variable cc
cc=shell("dir *.xls* *.csv /s /b",intern=TRUE)

# find lines with 1_REBOOT folders
rblines=grep("1_REBOOT",cc)

# file names with paths in the 1_REBOOT subfolder
rbf=cc[rblines]
