source("tidyDataset.R")

df<-tidyDataset(FALSE)
dfsum<-meansSummary(df)
write.table(dfsum,row.name=FALSE,file="step5.txt")