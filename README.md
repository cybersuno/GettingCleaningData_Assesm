---
title: "README"
author: "cybersuno"
date: "5/7/2020"
output: html_document
---


# Objective of the Document
The present document is aimed to document the steps followed to build a tidy dataset corresponding to the week 4 assesment for the course "Getting and Cleaning Data" by Johns Hopkins University, through Coursera

# Preview Information
The description of the dataset can be found on the page for the 
dataset called [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) in the _UC Irvine Machine Learning Repository_

# Tidy Dataset
## Instruction List
The dataset is obtained in three major steps:
- Download raw data
- Compose base dataset
- Tidying of the dataset

To load the dataset, simply run the function tidyDataset()

## Download raw data
This is performed by a function: getRawData
getRawData does not have any parameters and returns the date, to be used to 
control

This has several steps:
* Hardcode the filename as url
* Hardcode target directory and target file, and with them the target file
* Download the file. Previously, creates the target directory if it does not exist
* Unzip the downloaded file

## Compose the base dataset
This is controlled by a function called composeDataSet, and make use of several functions defined in loadData.R script. Each function is responsible to load a specific file. Please find below the description of the functions
The composition follows the following steps:

* Load the features_info.txt file, which contains the labels for the features
    
    dfFeatures<-loadFeatures()

* Load the activity_labels.txt, which contains the labels for the activities

    dfActivities<-loadActivities()

* Load all the three data frames with test data: the X_test.txt, Y_test.txt and subject_tests.txt files from the test folder
* Load all the three data frames with train data: X_train.txt, Y_train.txt and subject_train.txt from the train folder

    #load all of the files in a data set. In this moment, all of the datasets
    #are independient
    dfXTest<-loadXData("test")
    dfYTest<-loadYData("test")
    dfXTrain<-loadXData("train")
    dfYTrain<-loadYData("train")
    dfSubjectTest<-loadSubject("test")
    dfSubjectTrain<-loadSubject("train")
    
* The features data frame is used to name the variables for the test and train X data. So for both of them, features vector is set to colnames

    colnames(dfXTest)<-dfFeatures$Feature
    colnames(dfXTrain)<-dfFeatures$Feature

* The following activities are performed:
    * Y test data are bounded to the right to X test data
    * subjects for test data are bounded to the right to previous step
    * Train data is treated the same way with its corresponding data frames
    * Train data is appended to test data, so all data rows are together now in a new dataframe
    * A new merge is made to add the ActivityLabel column by joining to         ActivityCode from the merged dataframe and the one with activities label
    
    
    dfTest<-cbind(dfXTest,dfYTest)
    dfTest<-cbind(dfTest,dfSubjectTest)
    dfTrain<-cbind(dfXTrain,dfYTrain)
    dfTrain<-cbind(dfTrain,dfSubjectTrain)
    
    dfdata<-rbind(dfTest,dfTrain)
    
    #our resulting dataset is the appended df, adding the ACTIVITY description
    merge(dfdata,dfActivities,by.x="ActivityCode",by.y="ActivityCode")

## Tidy dataset
The final tidying is performed by a new function: tidyDataSet. This is the function to call to perform all steps, since it clals getRawData and composeDataSet as its two first steps

After that, it manages the columns:

* Make a list with the main columns ("ActivityCode", "SubjectCode", "ActivityLabel") and all the columns with mean() or std() in its description (that was got by features.txt). These columns are queried through a grep call


    selectedFields<-c("ActivityCode","SubjectCode","ActivityLabel")
    selectedFields<-c(selectedFields,grep("mean[(]",colnames(df),value=TRUE),
                      grep("std",colnames(df),value=TRUE))
                      
* WIth the list of columns, df is subsetted to this group of columns


    df<-df[,selectedFields]

* Finally, colnames is overriden by nested sub calls to automate the column renaming:

    * -std() is substutited by a more descriptive *StdDesv*
    * mean() is replaced by a more descriptive *Mean*
    * All -X, -Y, -Z are simplified by erasing the hyphen
    * The leading t is replaced by Time, while the leading f by Frequency


    colnames(df)<-sub("-std[(][)]","_StdDesv_",
        sub("mean[(][)]","_Mean_",
        sub("-Z","Z",sub("-Y","Y",
        sub("-X","X",
        sub("^f","Frequency_",
        sub("^t","Time_",
        colnames(df))))))))
    
The result is the dataframe after the execution of the algorithm

## loadData.R
This script has a generic function for any kind of files to load:

* Features
* Activities
* X data
* Y data

### Features
The function is loadFeatures. Has no arguments and returns the dataframe
The filename is hardcoded:

    filename<-"./data/UCI HAR Dataset/features.txt"

The file is loaded as a space separated file. The two columns are named "FeatureCode and "Feature". It has no header
    
    df<-read.table(filename,header=FALSE,sep=" ",
                           col.names = c("FeatureCode","Feature"))

### Activities
It works in a similar way as features. It hardcodes the filename and read the file as space separated values, calling the columns "ActivityCode" and "ActivityLabel"    
    
    filename<-"./data/UCI HAR Dataset/activity_labels.txt"
    
    
    df<-read.table(filename,header=FALSE,sep=" ",
                   col.names = c("ActivityCode","ActivityLabel"))
    
### Subject
The function loadSubject has an input parameter *test_train* in which it is expected "test" or "train" to identify the data. Fortunately, both of the structures are the same. As can be seen, this function is able to load data from test or train
The result is the loaded dataframe:
* filename is pasted with the *test_train* input variable
* full path filename is obtained by concatenation of folder structure
* file is loaded with no header, separated by spaces and naming the only column as SubjectCode


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

### X Data
Both test and train data is loaded through loadXData function. It has as input the *test_train* string.

* filename is pasted with the *test_train* input variable
* full path filename is obtained by concatenation of folder structure
* file is loaded with no header, separated by spaces and naming the only column as SubjectCode
* Load the file as "fixed widht file", in which all the 561 columns are observed to have 16 chars. Again, no header row is in the file.

    
    #file name
    file<-paste("X_",test_train,".txt",sep="")
    filename<-paste(".","data","UCI HAR Dataset",test_train,file,sep="/")
    
    #read space separated file, with understandable name cols
    df<-read.fwf(filename,widths=rep(16,times=561),header=FALSE)

### Y Data
The target figure is in Y file. The files contain one and only column for all the rows.

* filename is pasted with the _test_train_ input variable
* full path filename is obtained by concatenation of folder structure
* file is loaded with no header, separated by spaces and naming the only column as SubjectCode
* Load the file as separated (spaces) values, although there is only one column. The column is called ActivityCode.


    #file name
    file<-paste("Y_",test_train,".txt",sep="")
    filename<-paste(".","data","UCI HAR Dataset",test_train,file,sep="/")
    
    #read space separated file, with understandable name cols
    df<-read.table(filename,header=FALSE,sep=" ",col.names="ActivityCode")
    
## Code Book Tidy dataset
For the dataset, we can find the following columns.

1	ActivityCode	Activity code, coming from Y-test and Y-train files

2	SubjectCode	Code for the observation's subject, coming from subject test and subject train files

3	ActivityLabel	Name of the activity code

4	Time_BodyAcc_Mean_X	Observation on X axis for the  mean  of BodyAcc related to time

5	Time_BodyAcc_Mean_Y	Observation on Y axis for the  mean  of BodyAcc related to time

6	Time_BodyAcc_Mean_Z	Observation on Z axis for the  mean  of BodyAcc related to time

7	Time_GravityAcc_Mean_X	Observation on X axis for the  mean  of GravityAcc related to time

8	Time_GravityAcc_Mean_Y	Observation on Y axis for the  mean  of GravityAcc related to time

9	Time_GravityAcc_Mean_Z	Observation on Z axis for the  mean  of GravityAcc related to time

10	Time_BodyAccJerk_Mean_X	Observation on X axis for the  mean  of BodyAccJerk related to time

11	Time_BodyAccJerk_Mean_Y	Observation on Y axis for the  mean  of BodyAccJerk related to time

12	Time_BodyAccJerk_Mean_Z	Observation on Z axis for the  mean  of BodyAccJerk related to time

13	Time_BodyGyro_Mean_X	Observation on X axis for the  mean  of BodyGyro related to time

14	Time_BodyGyro_Mean_Y	Observation on Y axis for the  mean  of BodyGyro related to time

15	Time_BodyGyro_Mean_Z	Observation on Z axis for the  mean  of BodyGyro related to time

16	Time_BodyGyroJerk_Mean_X	Observation on X axis for the  mean  of BodyGyroJerk related to time

17	Time_BodyGyroJerk_Mean_Y	Observation on Y axis for the  mean  of BodyGyroJerk related to time

18	Time_BodyGyroJerk_Mean_Z	Observation on Z axis for the  mean  of BodyGyroJerk related to time

19	Time_BodyAccMag_Mean	Mean  of BodyAccMag related to time

20	Time_GravityAccMag_Mean	Mean  of GravityAccMag related to time

21	Time_BodyAccJerkMag_Mean	Mean  of BodyAccJerkMag related to time

22	Time_BodyGyroMag_Mean	Mean  of BodyGyroMag related to time

23	Time_BodyGyroJerkMag_Mean	Mean  of BodyGyroJerkMag related to time

24	Frequency_BodyAcc_Mean_X	Observation on X axis for the  mean  of BodyAcc 
related to frequency (Fast fourier transform)

25	Frequency_BodyAcc_Mean_Y	Observation on Y axis for the  mean  of BodyAcc related to frequency (Fast fourier transform)

26	Frequency_BodyAcc_Mean_Z	Observation on Z axis for the  mean  of BodyAcc related to frequency (Fast fourier transform)

27	Frequency_BodyAccJerk_Mean_X	Observation on X axis for the  mean  of BodyAccJerk related to frequency (Fast fourier transform)

28	Frequency_BodyAccJerk_Mean_Y	Observation on Y axis for the  mean  of BodyAccJerk related to frequency (Fast fourier transform)

29	Frequency_BodyAccJerk_Mean_Z	Observation on Z axis for the  mean  of BodyAccJerk related to frequency (Fast fourier transform)

30	Frequency_BodyGyro_Mean_X	Observation on X axis for the  mean  of BodyGyro related to frequency (Fast fourier transform)

31	Frequency_BodyGyro_Mean_Y	Observation on Y axis for the  mean  of BodyGyro related to frequency (Fast fourier transform)

32	Frequency_BodyGyro_Mean_Z	Observation on Z axis for the  mean  of BodyGyro related to frequency (Fast fourier transform)

33	Frequency_BodyAccMag_Mean	Mean  of BodyAccMag related to frequency (Fast fourier transform)

34	Frequency_BodyBodyAccJerkMag_Mean	Mean  of BodyBodyAccJerkMag related to frequency (Fast fourier transform)

35	Frequency_BodyBodyGyroMag_Mean	Mean  of BodyBodyGyroMag related to frequency (Fast fourier transform)

36	Frequency_BodyBodyGyroJerkMag_Mean	Mean  of BodyBodyGyroJerkMag related to frequency (Fast fourier transform)

37	Time_BodyAcc_StdDesv_X	Observation on X axis for the  standard desviation for  of BodyAcc related to time

38	Time_BodyAcc_StdDesv_Y	Observation on Y axis for the  standard desviation for  of BodyAcc related to time

39	Time_BodyAcc_StdDesv_Z	Observation on Z axis for the  standard desviation for  of BodyAcc related to time

40	Time_GravityAcc_StdDesv_X	Observation on X axis for the  standard desviation for  of GravityAcc related to time

41	Time_GravityAcc_StdDesv_Y	Observation on Y axis for the  standard desviation for  of GravityAcc related to time

42	Time_GravityAcc_StdDesv_Z	Observation on Z axis for the  standard desviation for  of GravityAcc related to time

43	Time_BodyAccJerk_StdDesv_X	Observation on X axis for the  standard desviation for  of BodyAccJerk related to time

44	Time_BodyAccJerk_StdDesv_Y	Observation on Y axis for the  standard desviation for  of BodyAccJerk related to time

45	Time_BodyAccJerk_StdDesv_Z	Observation on Z axis for the  standard desviation for  of BodyAccJerk related to time

46	Time_BodyGyro_StdDesv_X	Observation on X axis for the  standard desviation for  of BodyGyro related to time

47	Time_BodyGyro_StdDesv_Y	Observation on Y axis for the  standard desviation for  of BodyGyro related to time

48	Time_BodyGyro_StdDesv_Z	Observation on Z axis for the  standard desviation for  of BodyGyro related to time

49	Time_BodyGyroJerk_StdDesv_X	Observation on X axis for the  standard desviation for  of BodyGyroJerk related to time

50	Time_BodyGyroJerk_StdDesv_Y	Observation on Y axis for the  standard desviation for  of BodyGyroJerk related to time

51	Time_BodyGyroJerk_StdDesv_Z	Observation on Z axis for the  standard desviation for  of BodyGyroJerk related to time

52	Time_BodyAccMag_StdDesv	Standard desviation for  of BodyAccMag related to time

53	Time_GravityAccMag_StdDesv	Standard desviation for  of GravityAccMag related to time

54	Time_BodyAccJerkMag_StdDesv	Standard desviation for  of BodyAccJerkMag related to time

55	Time_BodyGyroMag_StdDesv	Standard desviation for  of BodyGyroMag related to time

56	Time_BodyGyroJerkMag_StdDesv	Standard desviation for  of BodyGyroJerkMag related to time

57	Frequency_BodyAcc_StdDesv_X	Observation on X axis for the  standard desviation for  of BodyAcc related to frequency (Fast fourier transform)

58	Frequency_BodyAcc_StdDesv_Y	Observation on Y axis for the  standard desviation for  of BodyAcc related to frequency (Fast fourier transform)

59	Frequency_BodyAcc_StdDesv_Z	Observation on Z axis for the  standard desviation for  of BodyAcc related to frequency (Fast fourier transform)

60	Frequency_BodyAccJerk_StdDesv_X	Observation on X axis for the  standard desviation for  of BodyAccJerk related to frequency (Fast fourier transform)

61	Frequency_BodyAccJerk_StdDesv_Y	Observation on Y axis for the  standard desviation for  of BodyAccJerk related to frequency (Fast fourier transform)

62	Frequency_BodyAccJerk_StdDesv_Z	Observation on Z axis for the  standard desviation for  of BodyAccJerk related to frequency (Fast fourier transform)

63	Frequency_BodyGyro_StdDesv_X	Observation on X axis for the  standard desviation for  of BodyGyro related to frequency (Fast fourier transform)

64	Frequency_BodyGyro_StdDesv_Y	Observation on Y axis for the  standard desviation for  of BodyGyro related to frequency (Fast fourier transform)

65	Frequency_BodyGyro_StdDesv_Z	Observation on Z axis for the  standard desviation for  of BodyGyro related to frequency (Fast fourier transform)

66	Frequency_BodyAccMag_StdDesv	Standard desviation for  of BodyAccMag related to frequency (Fast fourier transform)

67	Frequency_BodyBodyAccJerkMag_StdDesv	Standard desviation for  of BodyBodyAccJerkMag related to frequency (Fast fourier transform)

68	Frequency_BodyBodyGyroMag_StdDesv	Standard desviation for  of BodyBodyGyroMag related to frequency (Fast fourier transform)

69	Frequency_BodyBodyGyroJerkMag_StdDesv	Standard desviation for  of BodyBodyGyroJerkMag related to frequency (Fast fourier transform)


# Summary dataset
A second dataset is based on the previous one. It has all the averages for the previous.
To run the dataset, run the script:

    meansSummary()

## Load dataset
The dataset is performed through a new function: meansSummary
This function chains two steps: a group_by with the ActivityLabel and SubjectCode followed by a summarize for all the variables


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
    


## CodeBook
1	SubjectCode	Code for the observation's subject, coming from subject test and subject train files

2	ActivityLabel	Name of the activity code

3	Average_For_Time_BodyAcc_Mean_X	Average value by Subject and Activity of the variable: Time_BodyAcc_Mean_X

4	Average_For_Time_BodyAcc_Mean_Y	Average value by Subject and Activity of the variable: Time_BodyAcc_Mean_Y

5	Average_For_Time_BodyAcc_Mean_Z	Average value by Subject and Activity of the variable: Time_BodyAcc_Mean_Z

6	Average_For_Time_GravityAcc_Mean_X	Average value by Subject and Activity of the variable: Time_GravityAcc_Mean_X

7	Average_For_Time_GravityAcc_Mean_Y	Average value by Subject and Activity of the variable: Time_GravityAcc_Mean_Y

8	Average_For_Time_GravityAcc_Mean_Z	Average value by Subject and Activity of the variable: Time_GravityAcc_Mean_Z

9	Average_For_Time_BodyAccJerk_Mean_X	Average value by Subject and Activity of the variable: Time_BodyAccJerk_Mean_X

10	Average_For_Time_BodyAccJerk_Mean_Y	Average value by Subject and Activity of the variable: Time_BodyAccJerk_Mean_Y

11	Average_For_Time_BodyAccJerk_Mean_Z	Average value by Subject and Activity of the variable: Time_BodyAccJerk_Mean_Z

12	Average_For_Time_BodyGyro_Mean_X	Average value by Subject and Activity of the variable: Time_BodyGyro_Mean_X

13	Average_For_Time_BodyGyro_Mean_Y	Average value by Subject and Activity of the variable: Time_BodyGyro_Mean_Y

14	Average_For_Time_BodyGyro_Mean_Z	Average value by Subject and Activity of the variable: Time_BodyGyro_Mean_Z

15	Average_For_Time_BodyGyroJerk_Mean_X	Average value by Subject and Activity of the variable: Time_BodyGyroJerk_Mean_X

16	Average_For_Time_BodyGyroJerk_Mean_Y	Average value by Subject and Activity of the variable: Time_BodyGyroJerk_Mean_Y

17	Average_For_Time_BodyGyroJerk_Mean_Z	Average value by Subject and Activity of the variable: Time_BodyGyroJerk_Mean_Z

18	Average_For_Time_BodyAccMag_Mean	Average value by Subject and Activity of the variable: Time_BodyAccMag_Mean

19	Average_For_Time_GravityAccMag_Mean	Average value by Subject and Activity of the variable: Time_GravityAccMag_Mean

20	Average_For_Time_BodyAccJerkMag_Mean	Average value by Subject and Activity of the variable: Time_BodyAccJerkMag_Mean

21	Average_For_Time_BodyGyroMag_Mean	Average value by Subject and Activity of the variable: Time_BodyGyroMag_Mean

22	Average_For_Time_BodyGyroJerkMag_Mean	Average value by Subject and Activity of the variable: Time_BodyGyroJerkMag_Mean

23	Average_For_Frequency_BodyAcc_Mean_X	Average value by Subject and Activity of the variable: Frequency_BodyAcc_Mean_X

24	Average_For_Frequency_BodyAcc_Mean_Y	Average value by Subject and Activity of the variable: Frequency_BodyAcc_Mean_Y

25	Average_For_Frequency_BodyAcc_Mean_Z	Average value by Subject and Activity of the variable: Frequency_BodyAcc_Mean_Z

26	Average_For_Frequency_BodyAccJerk_Mean_X	Average value by Subject and Activity of the variable: Frequency_BodyAccJerk_Mean_X

27	Average_For_Frequency_BodyAccJerk_Mean_Y	Average value by Subject and Activity of the variable: Frequency_BodyAccJerk_Mean_Y

28	Average_For_Frequency_BodyAccJerk_Mean_Z	Average value by Subject and Activity of the variable: Frequency_BodyAccJerk_Mean_Z

29	Average_For_Frequency_BodyGyro_Mean_X	Average value by Subject and Activity of the variable: Frequency_BodyGyro_Mean_X

30	Average_For_Frequency_BodyGyro_Mean_Y	Average value by Subject and Activity of the variable: Frequency_BodyGyro_Mean_Y

31	Average_For_Frequency_BodyGyro_Mean_Z	Average value by Subject and Activity of the variable: Frequency_BodyGyro_Mean_Z

32	Average_For_Frequency_BodyAccMag_Mean	Average value by Subject and Activity of the variable: Frequency_BodyAccMag_Mean

33	Average_For_Frequency_BodyBodyAccJerkMag_Mean	Average value by Subject and Activity of the variable: Frequency_BodyBodyAccJerkMag_Mean

34	Average_For_Frequency_BodyBodyGyroMag_Mean	Average value by Subject and Activity of the variable: Frequency_BodyBodyGyroMag_Mean

35	Average_For_Frequency_BodyBodyGyroJerkMag_Mean	Average value by Subject and Activity of the variable: Frequency_BodyBodyGyroJerkMag_Mean

36	Average_For_Time_BodyAcc_StdDesv_X	Average value by Subject and Activity of the variable: Time_BodyAcc_StdDesv_X

37	Average_For_Time_BodyAcc_StdDesv_Y	Average value by Subject and Activity of the variable: Time_BodyAcc_StdDesv_Y

38	Average_For_Time_BodyAcc_StdDesv_Z	Average value by Subject and Activity of the variable: Time_BodyAcc_StdDesv_Z

39	Average_For_Time_GravityAcc_StdDesv_X	Average value by Subject and Activity of the variable: Time_GravityAcc_StdDesv_X

40	Average_For_Time_GravityAcc_StdDesv_Y	Average value by Subject and Activity of the variable: Time_GravityAcc_StdDesv_Y

41	Average_For_Time_GravityAcc_StdDesv_Z	Average value by Subject and Activity of the variable: Time_GravityAcc_StdDesv_Z

42	Average_For_Time_BodyAccJerk_StdDesv_X	Average value by Subject and Activity of the variable: Time_BodyAccJerk_StdDesv_X

43	Average_For_Time_BodyAccJerk_StdDesv_Y	Average value by Subject and Activity of the variable: Time_BodyAccJerk_StdDesv_Y

44	Average_For_Time_BodyAccJerk_StdDesv_Z	Average value by Subject and Activity of the variable: Time_BodyAccJerk_StdDesv_Z

45	Average_For_Time_BodyGyro_StdDesv_X	Average value by Subject and Activity of the variable: Time_BodyGyro_StdDesv_X

46	Average_For_Time_BodyGyro_StdDesv_Y	Average value by Subject and Activity of the variable: Time_BodyGyro_StdDesv_Y

47	Average_For_Time_BodyGyro_StdDesv_Z	Average value by Subject and Activity of the variable: Time_BodyGyro_StdDesv_Z

48	Average_For_Time_BodyGyroJerk_StdDesv_X	Average value by Subject and Activity of the variable: Time_BodyGyroJerk_StdDesv_X

49	Average_For_Time_BodyGyroJerk_StdDesv_Y	Average value by Subject and Activity of the variable: Time_BodyGyroJerk_StdDesv_Y

50	Average_For_Time_BodyGyroJerk_StdDesv_Z	Average value by Subject and Activity of the variable: Time_BodyGyroJerk_StdDesv_Z

51	Average_For_Time_BodyAccMag_StdDesv	Average value by Subject and Activity of the variable: Time_BodyAccMag_StdDesv

52	Average_For_Time_GravityAccMag_StdDesv	Average value by Subject and Activity of the variable: Time_GravityAccMag_StdDesv

53	Average_For_Time_BodyAccJerkMag_StdDesv	Average value by Subject and Activity of the variable: Time_BodyAccJerkMag_StdDesv

54	Average_For_Time_BodyGyroMag_StdDesv	Average value by Subject and Activity of the variable: Time_BodyGyroMag_StdDesv

55	Average_For_Time_BodyGyroJerkMag_StdDesv	Average value by Subject and Activity of the variable: Time_BodyGyroJerkMag_StdDesv

56	Average_For_Frequency_BodyAcc_StdDesv_X	Average value by Subject and Activity of the variable: Frequency_BodyAcc_StdDesv_X

57	Average_For_Frequency_BodyAcc_StdDesv_Y	Average value by Subject and Activity of the variable: Frequency_BodyAcc_StdDesv_Y

58	Average_For_Frequency_BodyAcc_StdDesv_Z	Average value by Subject and Activity of the variable: Frequency_BodyAcc_StdDesv_Z

59	Average_For_Frequency_BodyAccJerk_StdDesv_X	Average value by Subject and Activity of the variable: Frequency_BodyAccJerk_StdDesv_X

60	Average_For_Frequency_BodyAccJerk_StdDesv_Y	Average value by Subject and Activity of the variable: Frequency_BodyAccJerk_StdDesv_Y

61	Average_For_Frequency_BodyAccJerk_StdDesv_Z	Average value by Subject and Activity of the variable: Frequency_BodyAccJerk_StdDesv_Z

62	Average_For_Frequency_BodyGyro_StdDesv_X	Average value by Subject and Activity of the variable: Frequency_BodyGyro_StdDesv_X

63	Average_For_Frequency_BodyGyro_StdDesv_Y	Average value by Subject and Activity of the variable: Frequency_BodyGyro_StdDesv_Y

64	Average_For_Frequency_BodyGyro_StdDesv_Z	Average value by Subject and Activity of the variable: Frequency_BodyGyro_StdDesv_Z

65	Average_For_Frequency_BodyAccMag_StdDesv	Average value by Subject and Activity of the variable: Frequency_BodyAccMag_StdDesv

66	Average_For_Frequency_BodyBodyAccJerkMag_StdDesv	Average value by Subject and Activity of the variable: Frequency_BodyBodyAccJerkMag_StdDesv

67	Average_For_Frequency_BodyBodyGyroMag_StdDesv	Average value by Subject and Activity of the variable: Frequency_BodyBodyGyroMag_StdDesv

68	Average_For_Frequency_BodyBodyGyroJerkMag_StdDesv	Average value by Subject and Activity of the variable: Frequency_BodyBodyGyroJerkMag_StdDes

