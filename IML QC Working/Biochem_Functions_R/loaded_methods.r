# compare what parameters are found in the inventory (created by Emily) and which ones are found in BioChem
# Gordana Lazin, June 13, 2016


loaded_methods <- function(mission) {
  
 # ectract from BioChem which discrete data (methods) are loaded for a mission
  
  bcm=check_biochem(mission)
  
  
  # now check what is in inventory
  inv=inventory_files(mission)
  
  # parameters in inventory
  ip=inv$parameters
  
  # order alphabetically
  ip=ip[order(ip)]
  
  # make ip and bcm same length
  l=max(length(ip),length(bcm))
  length(ip)=l
  length(bcm)=l
  
  # make a data frame with two columns
  
  df=as.data.frame(cbind(ip,bcm))
  
  # replace NA with empty space
  names(df)=c(paste0(mission,"_inventory"),paste0(mission,"_biochem"))
    
  # save it to the csv file
  fn=paste0("parameters_", mission, ".csv")
  
  #fn=file.path(getwd(),mission,fn)
  
  write.csv(df,fn,row.names=FALSE)
  
  # return dataframe with 2 columns
  return(df)
  
  
}