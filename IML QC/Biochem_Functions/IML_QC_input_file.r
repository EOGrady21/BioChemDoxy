# This script is to play with the IML test file to see how IML QC script script flags the data.
# It creates file for the input in the IML QC script that is run in matlab.
# Since CTD data is not flagged I am trying to paste CTD data in the bottle columns 
# to see if they get flagged and how.


# load IML test file
iml_file="BTL_01064.txt"

# this is how to read iml txt file
df=read.table(iml_file, stringsAsFactors=FALSE, sep=";")

# subset df1 to have only metadata, and ctd data
df=df[,c(1:18)]


# add columns for Temp and Sal and oxy by copying CTD data columns
df$oxy=df[,grep("DOXY",df[2,])[1]] #find CTD oxygen and add it to data
df$temp=df[,grep("TE90",df[2,])[1]] #find ctd tempand add it to data
df$sal=df[,grep("PSAL",df[2,])[1]] # find ctd salinity

# change CTD to labo
df$oxy[1]="labo"
df$oxy[2]="OXY_XX"

df$sal[1]="labo"
df$sal[2]="SSAL_BS"
df$sal[3]="(g/kg)"

# df$sal[1]="labo"
# df$sal[2]="PSAL_BS"


df$temp[1]="terrain"
df$temp[2]="TEMP_RT"



# define the name and path to output file
outfile=file.path("C:/ODS_Toolbox/ODS1/MLI_Toolbox/IML_QC_2017/Rosette/Exemple","test_iml.txt")

# this is how to write it out in correct format
write.table(df,file=outfile,sep=";",col.names=FALSE, row.names=FALSE, quote=FALSE)

# ---- next step -- run after QC is done ----

# check the QC utput file
qcfile=file.path("C:/ODS_Toolbox/ODS1/MLI_Toolbox/IML_QC_2017/Rosette/Exemple","QC_test_iml.txt")
qc=read.table(qcfile, stringsAsFactors=FALSE, sep=";")
head(qc)


