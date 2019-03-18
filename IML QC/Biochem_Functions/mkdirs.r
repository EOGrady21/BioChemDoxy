# create new directory. check first if there is existing directory.
# copied from the internet
# Gordana Lazin, 2015

mkdirs <- function(fp) {
  if(!file.exists(fp)) {
    mkdirs(dirname(fp))
    dir.create(fp)
  }
} 