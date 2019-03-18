# write dataframe to oracle:
# 1. check if there are records in the table for that mission
# 2. if there is data then remove those records
# 3. write data frame to oracle table
# con is conection to the databas
# df is dataframe that has to be written
# oracle_table is the table in the database to write to

write_df2oracle <- function(con,df,oracle_table) {
  
  # 1. check if there is a data in oracle table for that mission
  
  # send query to extract data for that mission
  ino=dbSendQuery(con, paste0("SELECT * from ", oracle_table, " where MISSION_DESCRIPTOR = :1"), 
                  data = data.frame(MISSION_DESCRIPTOR=unique(df$MISSION_DESCRIPTOR)))
  
  # data frame with records
  dd1=fetch(ino)
  
  # 2. if there is data in the oracle table for this mission, delete the records
  if (dim(dd1)[1]>0) {
  inb=dbSendQuery(con, paste0("DELETE from ", oracle_table, " where MISSION_DESCRIPTOR = :1"), 
                  data = data.frame(MISSION_DESCRIPTOR=unique(df$MISSION_DESCRIPTOR)))
  dbCommit(con)
  }
  
  # 3. write dataframe to oracle table
  # create pieces of a string for a statement
  col_names=paste(names(df),collapse=",") #columns in the dataframe separated by commas
  nu=paste0(":", as.character(c(1:length(names(df)))), sep="") #column numbers from :1 to :last column number 
  col_nums=paste(nu, collapse=", ") # make a section of the string :1, :2, :3  etc (numbers separated by commas)
  
  # string of a statement that will write dataframe to the oracle table
  q=paste("INSERT INTO", oracle_table,"(", col_names,") values(",col_nums,")")
  
  # run the statement in the database (write data to the oracle table)
  dbGetQuery(con, q, data=bcs)
  
  # Commit the changes to the database.
  dbCommit(con)
  
}