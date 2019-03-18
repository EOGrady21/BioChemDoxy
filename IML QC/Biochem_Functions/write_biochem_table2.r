# save dataframe as table in BioChem

require("RODBC")
Sys.setenv(TZ = "GMT")
Sys.setenv(ORA_SDTZ = "GMT")

mission="HUD2003067"

# path in working directory
wdp=file.path(getwd(),mission)

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


# Jeff's method: write to the Oracle table

require("ROracle")

# Initialize the Oracle Database driver.
drv <- dbDriver("Oracle")

# Create a database connection.
con <- dbConnect(drv, username = biochem.user, password = biochem.password, dbname = "PTRAN")

# create peaces of a string for a statement
col_names=paste(names(bcs),collapse=",")# columns in the dataframe separated by commas
nu=paste0(":", as.character(c(1:53)), sep="") #column numbers from :1 to :53 
col_nums=paste(nu, collapse=", ") # make a section of the string :1, :2, :3  etc (numbers separated by commas)

# string of a statement that will write dataframe to the oracle table
q=paste("INSERT INTO", mission_table,"(", col_names,") values(",col_nums,")")

# run the statement in the database (write data to the oracle table)
dbGetQuery(con, q, data=bcs)

# Commit the changes to the database.
dbCommit(con)

# Close the database connection.
dbDisconnect(con)




# old attempts

con = odbcConnect( dsn="PTRAN", uid="lazing", pwd="Fdg8833p", believeNRows=F)

# copy BCS template table into a new table with name MISSION_BCS (HUD2011043_BCS)
mission_table=paste0("LAZING.",mission,"_BCS")

# SQL statement: drop mission table if it exists
drop_table=paste0("BEGIN EXECUTE IMMEDIATE 'DROP TABLE ",mission_table, "';
                  EXCEPTION
                  WHEN OTHERS THEN
                  IF SQLCODE != -942 THEN
                  RAISE;
                  END IF;
                  END;")


# SQL statement: create table by copiing the template table
copy_template=paste0("create table ", mission_table, " as select * from LAZING.bcs_template;")

# execute SQL statements
sqlQuery(con,drop_table) #drop table if exists
sqlQuery(con,copy_template) #copy template table




# attempt 1
sqlSave(con, bcs, tablename=mission_table apend = FALSE,
        rownames = FALSE, verbose = FALSE,
        safer = TRUE, addPK = FALSE,
        fast = TRUE, test = FALSE, nastring = NULL)

sqlSave(con,bcs, tablename=mission_table)

# attempt 2
sqlUpdate(con, bcs, tablename=mission_table, index="DIS_SAMPLE_KEY_VALUE")

# attempt 3
Lcolumns <- list(h[0,]) 
sqlUpdate(con, h,tablename=mission_table, index=c(Lcolumns))

# attempt 4
col_names=paste(names(bcs),collapse=",") # columns in the dataframe
nu=paste0(":", as.character(c(1:53)), sep="") # column numbers like :1
col_nums=paste(nu, collapse=", ") # make a section of the string :1, :2, :3  etc


q=paste("INSERT INTO", mission_table,"(", col_names,") VALUES(",col_nums,")")

insStr <- "INSERT INTO ODF_DATA (PARAMETER_CODE, SENSOR_NUMBER, ROW_NUMBER, PARAMETER_VALUE, QUALITY_FLAG, SAMPLE_TIME, INST_ID, ODF_FILENAME) VALUES (:1, :2, :3, :4, :5, :6, :7, :8)"

sqlQuery(con,q,bcs)

# attempt 5

values <- paste( " df[  , c(", 
                 paste( names(df),collapse=",") ,
                 ")] ", collapse="" ) 

sqlSave(con, df, tablename = mission_table, append=TRUE)
sqlUpdate(con, df, tablename = mission_table)


# attempt 6: try to insert few fields

q="INSERT INTO HUD2003067_BCS"



append = FALSE,
        rownames = FALSE, verbose = FALSE,
        safer = TRUE, addPK = FALSE,
        fast = TRUE, test = FALSE, nastring = NULL)


odbcCloseAll()
