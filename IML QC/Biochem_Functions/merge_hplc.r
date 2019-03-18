# merge HPLC files from the same cruise that have different column order

# create file name

missions=c("PAR2000002","HUD1999054","HUD2000050","HUD2001009","HUD2001061","HUD2009048")

library(gtools)
library(xlsx)

for (i in 1:length(missions)) {

mission=missions[i]
  
fp=file.path(getwd(),"HPLC_merge")

fn1=file.path(fp,paste0(mission,"HPLC_1.xls"))
fn2=file.path(fp,paste0(mission,"HPLC_2.xls"))
outfile=file.path(fp,paste0(mission,"HPLC.xls"))

hp1=get_hplc(mission,fn1)
hp2=get_hplc(mission,fn2)

# check if the datafiles have the same columns
sc=identical(names(hp1),names(hp2))

if (sc) {
  cat("\n","\n")
  cat("-> Column names and order is the same in both HPLC files.")
  hp=rbind(hp1,hp2)
  cat("\n","\n")
  cat(paste("-> Files merged and written to:"),outfile)
  
} else {
  cat("-> *** WARNING ***: columns in HPLC files do not match")
  cat("\n","\n")
  print(cbind(names(hp1),names(hp2)))
  stop()
}

# stack one data frame on top of each other and match column names
#hp=smartbind(hp1,hp2,fill=NA)

names(hp)=toupper(names(hp))
names(hp)=gsub("HPLC_","",names(hp))

write.xlsx(hp, file =outfile,sheetName = "Pigments", row.names = FALSE)
}

