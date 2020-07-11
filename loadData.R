loadFeatures <- function() {
    #this function reads the file features.txt, which contains the different 
    #measures contained in the files
    #Returns a dataset with the code and description of features, according to
    #the file
    
    #file name
    filename<-"./data/UCI HAR Dataset/features.txt"
    
    #read space separated file, with understandable name cols
    df<-read.table(filename,header=FALSE,sep=" ",
                   col.names = c("FeatureCode","Feature"))
    
    #returns the df
    df
}

loadActivities <- function() {
    #this function reads the file activity_labels.txt, which contains the  
    #codes for activities, contained in Y-data files and the label
    #Returns a dataset with the code and description of activities, according to
    #the file
    
    #file name
    filename<-"./data/UCI HAR Dataset/activity_labels.txt"
    
    #read space separated file, with understandable name cols
    df<-read.table(filename,header=FALSE,sep=" ",
                   col.names = c("ActivityCode","ActivityLabel"))
    
    #returns the df
    df
}

loadSubject <- function(test_train) {
    #this function reads the file for subjects from the corresponding folder, 
    #which contains the people to which belongs observations
    #Returns a dataset with the codes for subjects, according to
    #the file
    file<-paste("subject_",test_train,".txt",sep="")
    filename<-paste(".","data","UCI HAR Dataset",test_train,file,sep="/")
    
    #read space separated file, with understandable name cols
    df<-read.table(filename,header=FALSE,sep=" ",
                   col.names = c("SubjectCode"))
    
    #returns the df
    df    
}

loadXData <- function(test_train) {
    #this function reads the file X_train.txt from the "train" folder, 
    #which contains the different observations reserved for training
    #Returns a dataset with the file loaded
    
    #file name
    file<-paste("X_",test_train,".txt",sep="")
    filename<-paste(".","data","UCI HAR Dataset",test_train,file,sep="/")
    
    #read space separated file, with understandable name cols
    #the format is fixed width file. Each field is 16 chars length
    df<-read.fwf(filename,widths=rep(16,times=561),header=FALSE)
    
    #returns the df
    df    
}

loadYData <- function(test_train) {
    #this function reads the file Y_test.txt from the "test" folder, 
    #which contains the resultant activities for the data
    #Returns a dataset with the file loaded
    
    #file name
    file<-paste("Y_",test_train,".txt",sep="")
    filename<-paste(".","data","UCI HAR Dataset",test_train,file,sep="/")
    
    #read space separated file, with understandable name cols
    #the format is fixed width file. Each field is 16 chars length
    df<-read.table(filename,header=FALSE,sep=" ",col.names="ActivityCode")
    
    #returns the df
    df    
}
