Write_Database_Table <- function(data, table_name, host, port, sid, username, password) {

  # Function to ...
  #
  # Input: data : data to write to table - dataframe
  #        table_name : name of table to write - string
  #        ....
  #        data_source : data source name for database - string
  #        username : username - string
  #        password: user password - string
  #
  # Last update: 20141015
  # Benoit.Casault@dfo-mpo.gc.ca
  
  # load odbc library
  library(ROracle)
  
  # create an Oracle Database instance and create connection
  drv <- dbDriver("Oracle")
  
  # connect string specifications
  connect.string <- paste(
    "(DESCRIPTION=",
    "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
    "(CONNECT_DATA=(SID=", sid, ")))", sep = "")

  # use username/password authentication
  conn <- ROracle::dbConnect(drv, username=username, password=password, dbname = connect.string)
  
  ## check if table already exixts
  tf <- dbExistsTable(conn, name=table_name, schema = NULL)
  if(tf){
    status <- dbRemoveTable(conn, name=table_name, purge=TRUE, schema=NULL)
  }
  
  ## write data to table
  status <- dbWriteTable(conn, name=table_name, value=data, row.names=FALSE, overwrite=TRUE,
                         append=FALSE, ora.number=TRUE, schema=NULL)
    
  # close database connection
  conn <- dbDisconnect(conn)

  return()
}
