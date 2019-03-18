# find rows where all records are na (I think)

ind <- apply(x, 1, function(x) all(is.na(x)))
R> x <- x[ !ind, ]