#
# Requires the file getdata-projectfiles-UCI HAR Dataset.zip in the current working directory
# Download from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
library(data.table)

read_table_from_dataset <- function(filename, ...) {
    read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", filename), ...)
}

# Get activity and feature names
activity_names <- read_table_from_dataset("UCI HAR Dataset/activity_labels.txt", col.names = c("index", "Activity"))
feature_names <- read_table_from_dataset("UCI HAR Dataset/features.txt", col.names = c("index", "Feature"))

# Read only the mean and std features
columns_to_read <- rep("NULL", 561)
columns_to_read[grep("-(mean|std)\\(", feature_names$Feature)] = "numeric"

# Read training set
subjects_in_training_set <- read_table_from_dataset("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
activities_in_training_set <- read_table_from_dataset("UCI HAR Dataset/train/y_train.txt", col.names = "Activity")
activities_in_training_set$Activity <- activity_names$Activity[activities_in_training_set$Activity]
training_set <- read_table_from_dataset("UCI HAR Dataset/train/X_train.txt",
                                        colClasses = columns_to_read, col.names = feature_names$Feature, check.names = FALSE)

training_set <- cbind(subjects_in_training_set, activities_in_training_set, training_set)

# Read test set
subjects_in_test_set <- read_table_from_dataset("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
activities_in_test_set <- read_table_from_dataset("UCI HAR Dataset/test/y_test.txt", col.names = "Activity")
activities_in_test_set$Activity <- activity_names$Activity[activities_in_test_set$Activity]
test_set <- read_table_from_dataset("UCI HAR Dataset/test/X_test.txt",
                                    colClasses = columns_to_read, col.names = feature_names$Feature, check.names = FALSE)

test_set <- cbind(subjects_in_test_set, activities_in_test_set, test_set)

# Combine sets
combined_set <- rbind(training_set, test_set)

# Get average of each variable per activity and subject
DT = data.table(combined_set)
averages <- DT[, sapply(.SD, function(x) list(mean(x))), by=.(Activity, Subject)]
write.table(averages, "averages.txt", row.names = FALSE)
