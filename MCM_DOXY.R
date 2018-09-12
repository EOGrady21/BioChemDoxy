###pull oxygen data from MCM (RCM-11) in scotian shelf


files <- list.files('.', 'MCM*')
inst <- list()
doxy <- list()
file_name <- list()

for (i in 1:length(files)){
  nc <- nc_open(files[i])
  #check if RCM-11
  it <- ncatt_get(nc,0, 'model')
  inst[i] <- it$value
  g <- grep(names(nc$var), pattern = "*OXY*")
  if (length(g) > 0 ){
    
    oxy <- TRUE
  }else{
    oxy <- FALSE
  }
  doxy[i] <- oxy
  file_name[i] <- files[i]
  nc_close(nc)
  remove(nc)
  print(paste(i, "of", length(files), "files checked."))
}
file_name <- unlist(file_name)
inst <- unlist(inst)
doxy <- unlist(doxy)

data <- as.data.frame(cbind(file_name, inst, doxy))

data[doxy == TRUE]


ff <- grep(data$inst, pattern = 'RCM-11')
varnames <- list()

for (f in ff){
  nc <- nc_open(files[f])
  eval(parse(text = paste0(files[f],' <- as.character(names(nc$var))')))
  nc_close(nc)
}
oo <- rbind(unlist(grep(ls(), pattern = 'MCM*', value = TRUE)))

for ( f in 1:length(oo)){
eval(parse(text = paste0("s <- grep(", oo[f], ", pattern = 'DOXY*')")))
}
