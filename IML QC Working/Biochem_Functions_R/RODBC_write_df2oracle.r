# write dataframe to oracle using RODBC package and 32bit version of R:
# 1. check if there are records in the table for that mission
# 2. if there is data then remove those records
# 3. write data frame to oracle table
# con is conection to the databas
# df is dataframe that has to be written
# oracle_table is the table in the database to write to
# writing is much slower that ROracle

RODBC_write_df2oracle <- function(con,df,oracle_table) {
  
  mission_descriptor=unique(df$MISSION_DESCRIPTOR)
  
  # 1. check if there is data in the table for that mission
  
  # SQL statement string:
  qs=paste0("SELECT * from ", oracle_table, " where MISSION_DESCRIPTOR = '",mission_descriptor,"';")
  
  # run SQL statement: res is data frame for that mission
  res=sqlQuery(con,qs)
  
  
  # 2. if there is data in the table for that cruise, remove those records
  if (dim(res)[1]>0) {
    
    # string for SQL delete data statement
    del_data=paste0("DELETE from ", oracle_table, " where MISSION_DESCRIPTOR = '",mission_descriptor,"';")
    
    # run delete data query
    sqlQuery(con,del_data)
  }
  
  
  # 3. write data to the table
  sqlSave(con,df,tablename=oracle_table, rownames=FALSE, append=TRUE)
  
  
}