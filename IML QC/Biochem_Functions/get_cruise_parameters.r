# makes a table of what is loaded for all Lab Sea cruises

azomp_cruises=c("99022", "HUD2000009","HUD2001022","HUD2002032","HUD2002075","HUD2003038",
          "HUD2004016","HUD2005016","HUD2006019","HUD2007011","HUD2008009","HUD2009015",
          "HUD2010014","HUD2011009","MLB2012001")


azmp_cruises=c("99054","HUD2000050","HUD2001061","HUD2002064","HUD2003067","HUD2003078",
               "HUD2004055","HUD2005055","HUD2006052","HUD2007045","HUD2008037","HUD2009048",
               "HUD2010049","HUD2011043","HUD2012042","HUD2013037","HUD2014030","HUD2015030",
               "99003","PAR2000002","HUD2001009","HUD2003005","HUD2004009","NED2005004",
               "HUD2006008","HUD2007001","HUD2008004","HUD2009005","HUD2010006","HUD2011004",
               "HUD2013004","HUD2014004","HUD2015004")

source("loaded_methods.r")
source("check_biochem.r")
source("inventory_files.r")
require(rowr)

cruises=azmp_cruises

# final product
ff=NA

# make csv files for all the cruises
for (i in 1:length(cruises)) {
  bb=loaded_methods(cruises[i])
  ff=cbind.fill(ff,bb,fill=NA)
  }

write.csv(ff,"azmp_parameters_in_biochem.csv")


#loaded_methods("HUD2003078")

# count how many of each method there are in the biochem for cruises

ff=read.csv("azmp_parameters_in_biochem.csv")

# insert counter
ff$V1=seq(1,dim(ff)[1],1)

# melt ff  so all the methods are in the same column
fm=melt(ff,"V1")

# separate "biochem" from "inventory" records
bcr=grep("_biochem",fm$variable)

# dataframe with biochem methods
fbc=fm[bcr,]

inr=grep("_inventory",fm$variable)
# dataframe with inventory parameters
finv=fm[inr,]

# find how many of each unique methods are in biochem
bCTable=as.data.frame(table(fbc$value))

invTable=as.data.frame(table(finv$value))

write.csv( bCTable,"AZOMP_methods_in_biochem_count.csv")


number_cruises=length(cruises)


# ome other chunk of code

tt=read.csv("azmp_methods_freq_count.csv")

desc=read_excel("data_types_loaded_azmp_bc.xlsx",1)
desc=as.data.frame(desc)
desc=desc[,c(1,3)]
desc=unique(desc)

final=merge(tt,desc,by.x="Method", by.y="METHOD", all.x=TRUE, all.y=F)
which(is.na(final$Method))




