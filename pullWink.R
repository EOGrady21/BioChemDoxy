###isolating winkler data from csv

path <- '~/BIOCHEM/'

files <- list.files(path, '*csv')
data <- list()
for(i in 1:length(files)){
  
c <- read.csv(files[i], header = TRUE)

w <- grep(names(c), pattern = 'wink*', ignore.case = TRUE)
  
data[i] <- c[[w]]
}

