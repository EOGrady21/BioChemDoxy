<<<<<<< HEAD
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
=======
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
>>>>>>> 8d16c9adec107eab3c9823ff203975da149b937b
}