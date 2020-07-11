
source("loadData.R")

library(dplyr)

getRawData <- function() {
    #getRawData: this function downloads the zip file with data and unzip it in
    #a folder data in the working directory
    #returns the date in which the current function execution is finished
    
    #Step 1: download the file, which is a zip file
    
    #download file url
    fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    #data dir
    dataDir<-"data"
    #rawZip
    rawZipName<-"rawdataset.zip"
    #destFile
    destFile<-paste(".",dataDir,rawZipName,sep="/")
    
    if(!file.exists(dataDir)){
        dir.create(dataDir)
    }
    download.file(fileUrl, destfile=destFile)
    
    if(!file.exists(destFile)) {
        error("Problem loading file")
    }
    
    #STEP 2: unzip de zip file
    setwd(paste("./",dataDir,sep=""))
    unzip(rawZipName,overwrite=TRUE)
    setwd("./..")
    
    date()
}

composeDataset <- function () {
    #load the features and activities master data files
    dfFeatures<-loadFeatures()
    dfActivities<-loadActivities()
    
    #load all of the files in a data set. In this moment, all of the datasets
    #are independient
    dfXTest<-loadXData("test")
    dfYTest<-loadYData("test")
    dfXTrain<-loadXData("train")
    dfYTrain<-loadYData("train")
    dfSubjectTest<-loadSubject("test")
    dfSubjectTrain<-loadSubject("train")
    
    #third step: compound a data.frame
    #X test and train has a lot of columns with no name. Names are the features
    #So, we assign the colnames to the dataframes
    colnames(dfXTest)<-dfFeatures$Feature
    colnames(dfXTrain)<-dfFeatures$Feature
    
    #we will merge on the right the Y-data for test and train, and after that,
    #will merge again the correspondant subjects
    #This will compound two new datasets: dfTest and dfTrain
    dfTest<-cbind(dfXTest,dfYTest)
    dfTest<-cbind(dfTest,dfSubjectTest)
    dfTrain<-cbind(dfXTrain,dfYTrain)
    dfTrain<-cbind(dfTrain,dfSubjectTrain)
    
    #we need an only data frame, so append test and train data
    dfdata<-rbind(dfTest,dfTrain)
    
    #our resulting dataset is the appended df, adding the ACTIVITY description
    merge(dfdata,dfActivities,by.x="ActivityCode",by.y="ActivityCode")
}

tidyDataset <- function(downloadData) {
    #first step: download files and unzip
    if(downloadData) {
        getRawData()
    }
    
    
    #second step: get the different dataframes and generate an unique one
    df<-composeDataset()
    
    #third step: tiding
    #prepare a list of fields with important dims and mean and std variables
    selectedFields<-c("ActivityCode","SubjectCode","ActivityLabel")
    selectedFields<-c(selectedFields,grep("mean[(]",colnames(df),value=TRUE),
                      grep("std",colnames(df),value=TRUE))
    df<-df[,selectedFields]
    
    #Now, rename the fields
    colnames(df)<-sub("-","_",
                      sub("-std[(][)]","_StdDesv",
                          sub("-mean[(][)]","_Mean",
                              sub("^f","Frequency_",
                                  sub("^t","Time_",
                                      colnames(df))))))
    
    # Extracts only the measurements on the mean and standard deviation for each measurement.:
    #get the variables with select and make a one-by-one rename
    # Uses descriptive activity names to name the activities in the data set
    #already done
    # Appropriately labels the data set with descriptive variable names.
    #step two: renaming
    # From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    #merge the subject?
    #by and summarize
    
    
    
    #grep("mean[(]",dfFeatures$Feature,value=TRUE)
    #grep("std",dfFeatures$Feature,value=TRUE)
    df
}

meansSummary <- function(df) {
    #REturns a dataset with a summarize by ActivityLabel and SubjectCode
    df %>%  group_by(ActivityLabel,SubjectCode) %>% summarize(
        Average_For_Time_BodyAcc_Mean_X=mean(Time_BodyAcc_Mean_X), 
        Average_For_Time_BodyAcc_Mean_Y=mean(Time_BodyAcc_Mean_Y), 
        Average_For_Time_BodyAcc_Mean_Z=mean(Time_BodyAcc_Mean_Z), 
        Average_For_Time_GravityAcc_Mean_X=mean(Time_GravityAcc_Mean_X), 
        Average_For_Time_GravityAcc_Mean_Y=mean(Time_GravityAcc_Mean_Y), 
        Average_For_Time_GravityAcc_Mean_Z=mean(Time_GravityAcc_Mean_Z), 
        Average_For_Time_BodyAccJerk_Mean_X=mean(Time_BodyAccJerk_Mean_X), 
        Average_For_Time_BodyAccJerk_Mean_Y=mean(Time_BodyAccJerk_Mean_Y), 
        Average_For_Time_BodyAccJerk_Mean_Z=mean(Time_BodyAccJerk_Mean_Z), 
        Average_For_Time_BodyGyro_Mean_X=mean(Time_BodyGyro_Mean_X), 
        Average_For_Time_BodyGyro_Mean_Y=mean(Time_BodyGyro_Mean_Y), 
        Average_For_Time_BodyGyro_Mean_Z=mean(Time_BodyGyro_Mean_Z), 
        Average_For_Time_BodyGyroJerk_Mean_X=mean(Time_BodyGyroJerk_Mean_X), 
        Average_For_Time_BodyGyroJerk_Mean_Y=mean(Time_BodyGyroJerk_Mean_Y), 
        Average_For_Time_BodyGyroJerk_Mean_Z=mean(Time_BodyGyroJerk_Mean_Z), 
        Average_For_Time_BodyAccMag_Mean=mean(Time_BodyAccMag_Mean), 
        Average_For_Time_GravityAccMag_Mean=mean(Time_GravityAccMag_Mean), 
        Average_For_Time_BodyAccJerkMag_Mean=mean(Time_BodyAccJerkMag_Mean), 
        Average_For_Time_BodyGyroMag_Mean=mean(Time_BodyGyroMag_Mean), 
        Average_For_Time_BodyGyroJerkMag_Mean=mean(Time_BodyGyroJerkMag_Mean), 
        Average_For_Frequency_BodyAcc_Mean_X=mean(Frequency_BodyAcc_Mean_X), 
        Average_For_Frequency_BodyAcc_Mean_Y=mean(Frequency_BodyAcc_Mean_Y), 
        Average_For_Frequency_BodyAcc_Mean_Z=mean(Frequency_BodyAcc_Mean_Z), 
        Average_For_Frequency_BodyAccJerk_Mean_X=mean(Frequency_BodyAccJerk_Mean_X), 
        Average_For_Frequency_BodyAccJerk_Mean_Y=mean(Frequency_BodyAccJerk_Mean_Y), 
        Average_For_Frequency_BodyAccJerk_Mean_Z=mean(Frequency_BodyAccJerk_Mean_Z), 
        Average_For_Frequency_BodyGyro_Mean_X=mean(Frequency_BodyGyro_Mean_X), 
        Average_For_Frequency_BodyGyro_Mean_Y=mean(Frequency_BodyGyro_Mean_Y), 
        Average_For_Frequency_BodyGyro_Mean_Z=mean(Frequency_BodyGyro_Mean_Z), 
        Average_For_Frequency_BodyAccMag_Mean=mean(Frequency_BodyAccMag_Mean), 
        Average_For_Frequency_BodyBodyAccJerkMag_Mean=mean(Frequency_BodyBodyAccJerkMag_Mean), 
        Average_For_Frequency_BodyBodyGyroMag_Mean=mean(Frequency_BodyBodyGyroMag_Mean), 
        Average_For_Frequency_BodyBodyGyroJerkMag_Mean=mean(Frequency_BodyBodyGyroJerkMag_Mean), 
        Average_For_Time_BodyAcc_StdDesv_X=mean(Time_BodyAcc_StdDesv_X), 
        Average_For_Time_BodyAcc_StdDesv_Y=mean(Time_BodyAcc_StdDesv_Y), 
        Average_For_Time_BodyAcc_StdDesv_Z=mean(Time_BodyAcc_StdDesv_Z), 
        Average_For_Time_GravityAcc_StdDesv_X=mean(Time_GravityAcc_StdDesv_X), 
        Average_For_Time_GravityAcc_StdDesv_Y=mean(Time_GravityAcc_StdDesv_Y), 
        Average_For_Time_GravityAcc_StdDesv_Z=mean(Time_GravityAcc_StdDesv_Z), 
        Average_For_Time_BodyAccJerk_StdDesv_X=mean(Time_BodyAccJerk_StdDesv_X), 
        Average_For_Time_BodyAccJerk_StdDesv_Y=mean(Time_BodyAccJerk_StdDesv_Y), 
        Average_For_Time_BodyAccJerk_StdDesv_Z=mean(Time_BodyAccJerk_StdDesv_Z), 
        Average_For_Time_BodyGyro_StdDesv_X=mean(Time_BodyGyro_StdDesv_X), 
        Average_For_Time_BodyGyro_StdDesv_Y=mean(Time_BodyGyro_StdDesv_Y), 
        Average_For_Time_BodyGyro_StdDesv_Z=mean(Time_BodyGyro_StdDesv_Z), 
        Average_For_Time_BodyGyroJerk_StdDesv_X=mean(Time_BodyGyroJerk_StdDesv_X), 
        Average_For_Time_BodyGyroJerk_StdDesv_Y=mean(Time_BodyGyroJerk_StdDesv_Y), 
        Average_For_Time_BodyGyroJerk_StdDesv_Z=mean(Time_BodyGyroJerk_StdDesv_Z), 
        Average_For_Time_BodyAccMag_StdDesv=mean(Time_BodyAccMag_StdDesv), 
        Average_For_Time_GravityAccMag_StdDesv=mean(Time_GravityAccMag_StdDesv), 
        Average_For_Time_BodyAccJerkMag_StdDesv=mean(Time_BodyAccJerkMag_StdDesv), 
        Average_For_Time_BodyGyroMag_StdDesv=mean(Time_BodyGyroMag_StdDesv), 
        Average_For_Time_BodyGyroJerkMag_StdDesv=mean(Time_BodyGyroJerkMag_StdDesv), 
        Average_For_Frequency_BodyAcc_StdDesv_X=mean(Frequency_BodyAcc_StdDesv_X), 
        Average_For_Frequency_BodyAcc_StdDesv_Y=mean(Frequency_BodyAcc_StdDesv_Y), 
        Average_For_Frequency_BodyAcc_StdDesv_Z=mean(Frequency_BodyAcc_StdDesv_Z), 
        Average_For_Frequency_BodyAccJerk_StdDesv_X=mean(Frequency_BodyAccJerk_StdDesv_X), 
        Average_For_Frequency_BodyAccJerk_StdDesv_Y=mean(Frequency_BodyAccJerk_StdDesv_Y), 
        Average_For_Frequency_BodyAccJerk_StdDesv_Z=mean(Frequency_BodyAccJerk_StdDesv_Z), 
        Average_For_Frequency_BodyGyro_StdDesv_X=mean(Frequency_BodyGyro_StdDesv_X), 
        Average_For_Frequency_BodyGyro_StdDesv_Y=mean(Frequency_BodyGyro_StdDesv_Y), 
        Average_For_Frequency_BodyGyro_StdDesv_Z=mean(Frequency_BodyGyro_StdDesv_Z), 
        Average_For_Frequency_BodyAccMag_StdDesv=mean(Frequency_BodyAccMag_StdDesv), 
        Average_For_Frequency_BodyBodyAccJerkMag_StdDesv=mean(Frequency_BodyBodyAccJerkMag_StdDesv), 
        Average_For_Frequency_BodyBodyGyroMag_StdDesv=mean(Frequency_BodyBodyGyroMag_StdDesv), 
        Average_For_Frequency_BodyBodyGyroJerkMag_StdDesv=mean(Frequency_BodyBodyGyroJerkMag_StdDesv)) 
    
}
