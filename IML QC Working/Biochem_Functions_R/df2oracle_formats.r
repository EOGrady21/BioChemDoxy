# Change data frame column classes so they match required format of the Oracle table


df2oracle_formats <- function(df0,table_formats) {

# re-assign original dataframe
df=df0
  
# find which variables should be character, numeric, or date
dfChar=grep("VARCHAR",table_formats$DATA_TYPE)
dfNum=grep("NUMBER",table_formats$DATA_TYPE)
dfdate=grep("DATE",table_formats$DATA_TYPE)

# Created date has different format so you have to find it first
# crdi=which(names(df)[dfdate]=="CREATED_DATE")
# dfdate=dfdate[-crdi] # remove created date from dates column definition

# if there is more than one column with dates use tapply, otherwise just use as.POSIXct
if (length(dfdate)>1) {
# convert date columns to appropriate formats
df[,dfdate]=lapply(df[,dfdate],function(x) {as.POSIXct(x,"%d-%b-%Y", tz="UTC")})
} else {
  df[,dfdate]=as.POSIXct(df[,dfdate],"%d-%b-%Y", tz="UTC") 
}

# # convert CRETED_DATE to date format
# df$CREATED_DATE=as.POSIXct(df$CREATED_DATE,"%Y-%m-%d %H:%M:%S", tz="UTC")
# df$CREATED_DATE=format(df$CREATED_DATE,"%Y-%m-%d")

# convert columns to characters
df[,dfChar]=lapply(df[,dfChar],function(x) {as.character(x)})

# convert columns to numeric
df[,dfNum]=lapply(df[,dfNum],function(x) {as.numeric(x)})

return(df)

}