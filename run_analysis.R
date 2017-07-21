# load plyr & data.table packages
library(dplyr)
library(data.table)
# read in test set with subject & activity
test <- read.table("test/X_test.txt")
test$subject <- as.numeric(readLines("test/subject_test.txt"))
test$activity <- readLines("test/y_test.txt")
# read in train set with subject & activity
train <- read.table("train/X_train.txt")
train$subject <- as.numeric(readLines("train/subject_train.txt"))
train$activity <- readLines("train/y_train.txt")
# merge train & test set & assign variable names
combined <- merge(test, train, all = TRUE)
names(combined) <- c(readLines("features.txt"), "subject", "activity")
# extract only mean & standard deviation variables, keeping subject & activity
mean_std <- select(combined, subject, activity, grep("[Mm]ean|std", names(combined))) %>% arrange(subject, activity)
# provide descriptive names for activity variable
activity_labels <- tolower(sapply(sapply(readLines("activity_labels.txt"), strsplit, " "), function(x){x[2]}))
mean_std$activity <- activity_labels[as.numeric(mean_std$activity)]
# simplify variable names
names(mean_std) <- gsub("\\()", "", c("subject", "activity", sapply(sapply(names(mean_std)[3:88], strsplit, " "), function(x){x[2]})))
# clean environment
rm(test, train, combined, activity_labels)
# melt & cast result for data tidy set of mean value for each subject by activity
HARmean <- melt(mean_std, id = c("subject", "activity")) %>% dcast(subject + activity ~ variable, mean)
