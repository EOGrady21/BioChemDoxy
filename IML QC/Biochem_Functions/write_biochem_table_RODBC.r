# save dataframe as table in BioChem


require("RODBC")
source("RODBC_write_df2oracle.r")
source("df2oracle_formats.r")
Sys.setenv(TZ = "GMT")
Sys.setenv(ORA_SDTZ = "GMT")


# path in working directory
wdp=file.path(getwd(),mission)

# write a message on the screen
cat("\n","\n")
cat(paste("-> Loading BCS file:",file.path(wdp,paste0(mission,"_BCS.csv"))))
cat("\n","\n")
cat(paste("-> Loading BCD file:",file.path(wdp,paste0(mission,"_BCD.csv"))))

# load BCS file and file formats
bcsf=file.path(wdp,paste0(mission,"_BCS.csv"))
bcs=read.csv(bcsf,stringsAsFactors = FALSE)
bcs_formats=read.csv(file.path(getwd(),"bcs_formats.csv"), stringsAsFactors = F)

# Load BCD file and formats
bcdf=file.path(wdp,paste0(mission,"_BCD.csv"))
bcd=read.csv(bcdf,stringsAsFactors = FALSE)
bcd_formats=read.csv(file.path(getwd(),"bcd_formats.csv"),stringsAsFactors = F)

# check if the column names in BCS and BCD are the same as in BioChem
identical(names(bcs),bcs_formats$COLUMN_NAME)
identical(names(bcd),bcd_formats$COLUMN_NAME)

# change formats to the formats required for Oracle table
bcs1=df2oracle_formats(bcs,bcs_formats)
bcd1=df2oracle_formats(bcd,bcd_formats)


# Create a database connection.
con = odbcConnect( dsn="PTRAN", uid=biochem.user, pwd=biochem.password, believeNRows=F)

# write BCS file to Oracle table
RODBC_write_df2oracle(con,bcs1,"AZMP_MISSIONS_BCS")

# write BCD file to oracle table
RODBC_write_df2oracle(con,bcd1,"AZMP_MISSIONS_BCD")

# close connection to database
odbcClose(con)

cat("\n","\n")
cat("-> BCS and BCD sucesfully uploaded to the ORACLE staging tables.")

