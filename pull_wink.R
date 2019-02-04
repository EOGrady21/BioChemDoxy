#pull winkler data from bcd files

#set working directory to BCD files

files <- list.files('.', pattern = '*')


#search for winkler data

for ( i in 1:length(files)){
  csv <- read.csv(files[i])
  l <- grep(csv$DATA_TYPE_METHOD, pattern = 'O2_Winkler*')
  #create new csv
  new <- csv[l,]
  write.csv(new, file = 'O2_Winkler.csv', append = T)
}