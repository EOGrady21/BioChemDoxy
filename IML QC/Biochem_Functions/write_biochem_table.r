# save dataframe as table in BioChem

con = odbcConnect( dsn="PTRAN", uid=biochem.user, pwd=biochem.password, believeNRows=F)



sqlSave(con, h, append = FALSE,
        rownames = FALSE, colnames = TRUE, verbose = FALSE,
        safer = TRUE, addPK = FALSE,
        fast = TRUE, test = FALSE, nastring = NULL)