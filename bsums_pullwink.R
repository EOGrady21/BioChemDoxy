<<<<<<< HEAD
###

# bsums <- list.files('DATA/biolsums/')
# 
# 
# for (i in 1:length(bsums)){
#   bsum <- readxl::read_xls(path = paste0('DATA/biolsums/', bsums[i]),col_names = T )
#   g <- grep(bsum, pattern = 'winkler', ignore.case = T )
#   f <- grep(bsum[c(g)], pattern = 'ml', ignore.case = T)
#   w <- bsum[g[f]]
#   for (l in 1:length(w$Oxygen__3)){
#   if (!is.na(w$Oxygen__3[l])){
#     newset <- write.csv(x = bsum[l,], file = 'newWinkOxy.csv', append = T)
#   }
#   }
=======
###

# bsums <- list.files('DATA/biolsums/')
# 
# 
# for (i in 1:length(bsums)){
#   bsum <- readxl::read_xls(path = paste0('DATA/biolsums/', bsums[i]),col_names = T )
#   g <- grep(bsum, pattern = 'winkler', ignore.case = T )
#   f <- grep(bsum[c(g)], pattern = 'ml', ignore.case = T)
#   w <- bsum[g[f]]
#   for (l in 1:length(w$Oxygen__3)){
#   if (!is.na(w$Oxygen__3[l])){
#     newset <- write.csv(x = bsum[l,], file = 'newWinkOxy.csv', append = T)
#   }
#   }
>>>>>>> 8d16c9adec107eab3c9823ff203975da149b937b
# }