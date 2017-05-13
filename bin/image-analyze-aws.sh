#!/bin/bash

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2

inputFileName=$3

AWS_PATH=$(dirname $3)
FILE_NAME=$(echo "${inputFileName##*/}")
FILE_NAME=$(echo "${FILE_NAME%.*}")

echo "Analyzing file: $3"
echo "AWS path: $AWS_PATH"
echo "File name: $FILE_NAME"

aws s3 cp $3 /$FILE_NAME.GPR
aws s3 cp $AWS_PATH/$FILE_NAME.json /$FILE_NAME.json

# This is necessary to run Matlab Runtime Environment
# But causes some conflicts with awscli
# This is why we delete the LD_LIBRARY_PATH after the call
export LD_LIBRARY_PATH="/opt/mcr/v901/runtime/glnxa64:/opt/mcr/v901/bin/glnxa64:/opt/mcr/v901/sys/os/glnxa64"
/analyzeImage /$FILE_NAME.GPR "path" "/data"
export LD_LIBRARY_PATH=""

aws s3 cp $FILE_NAME"_labels.png" $AWS_PATH/$FILE_NAME"_labels.png"
aws s3 cp $FILE_NAME.json $AWS_PATH/$FILE_NAME.json